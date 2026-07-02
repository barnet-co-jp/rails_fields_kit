# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "support boundary docs inventory" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:readme_path) { File.expand_path("../README.md", __dir__) }
  let(:readme) { File.read(readme_path) }
  let(:support_boundary_path) { File.expand_path("../doc/support_boundary.md", __dir__) }
  let(:support_boundary) { File.read(support_boundary_path) }

  it "keeps the support boundary packaged and routed from the README setup path" do
    docs_map = markdown_section(readme, "## Docs map")

    expect(specification.files).to include("doc/support_boundary.md")
    expect(docs_map).to include(
      "[`doc/setup.md`](doc/setup.md)",
      "[`doc/support_boundary.md`](doc/support_boundary.md)",
      "supported Ruby / Rails and repository JavaScript boundaries"
    )
  end

  it "keeps version sources and host-app Tom Select ownership separated" do
    expect(support_boundary).to include(
      "Ruby: `>= 3.1`",
      "Rails: `>= 7.0`, `< 9.0`",
      "The source of truth for these install-time boundaries is `rails_fields_kit.gemspec`",
      "Node 22.x || 24.x",
      "`package.json` declares `engines.node` as `22.x || 24.x`",
      "repository-local JavaScript checks and package export smoke tests"
    )

    expect(support_boundary).to include(
      "not a Tom Select runtime support policy for host applications",
      "does not publish a required Tom Select package version",
      "plugin list, plugin asset policy, or package-manager lockfile policy",
      "Host applications choose and review those Tom Select runtime dependencies through their own JavaScript toolchain"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
