# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "package metadata documentation URI" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }
  let(:setup_guide) { File.read(File.expand_path("../doc/setup.md", __dir__)) }

  it "keeps RubyGems metadata pointed at maintained repository documentation" do
    homepage = specification.homepage

    expect(specification.metadata).to include(
      "source_code_uri" => homepage,
      "changelog_uri" => "#{homepage}/blob/main/CHANGELOG.md",
      "documentation_uri" => "#{homepage}/blob/main/doc/setup.md"
    )
  end

  it "keeps the documentation URI entrypoint connected to the broader docs map" do
    expect(specification.files).to include(
      "README.md",
      "doc/setup.md",
      "doc/public_api.md",
      "doc/field_helpers.md",
      "doc/controller_helpers.md",
      "doc/visual_references.md",
      "doc/release.md"
    )

    expect(setup_guide).to include(
      "This guide is the maintained setup walkthrough for Rails Fields Kit.",
      "This `doc/setup.md` file is the detailed setup reference and source of truth for examples."
    )

    expect(readme).to include(
      "| Set up a host app | [`doc/setup.md`](doc/setup.md) |",
      "| Review stable public API and package-root JavaScript exports | [`doc/public_api.md`](doc/public_api.md) |",
      "| Choose a helper or migrate from `collection_select` | [`doc/field_helpers.md`](doc/field_helpers.md)",
      "| Build remote search, selected preload, create, or token suggestion endpoints | [`doc/controller_helpers.md`](doc/controller_helpers.md)",
      "| See or compare rendered UI states quickly | [`doc/visual_references.md`](doc/visual_references.md)",
      "| Prepare or verify a release | [`doc/release.md`](doc/release.md)"
    )
  end
end
