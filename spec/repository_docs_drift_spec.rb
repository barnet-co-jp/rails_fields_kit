# frozen_string_literal: true

require "json"
require "spec_helper"

RSpec.describe "repository docs drift guards" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:configuration_source) { read_repo_file("lib/rails_fields_kit/configuration.rb") }
  let(:configuration_doc) { read_repo_file("doc/configuration.md") }
  let(:configuration_profiles) { read_repo_file("doc/configuration_profiles.md") }
  let(:support_boundary) { read_repo_file("doc/support_boundary.md") }
  let(:development_doc) { read_repo_file("doc/development.md") }
  let(:gemspec) { read_repo_file("rails_fields_kit.gemspec") }
  let(:package_metadata) { JSON.parse(read_repo_file("package.json")) }
  let(:ci_workflow) { read_repo_file(".github/workflows/ci.yml") }

  it "keeps support boundary docs aligned with gem, package, and CI version signals" do
    ruby_requirement = gemspec.match(/spec\.required_ruby_version = "([^"]+)"/)[1]
    rails_requirements = gemspec.match(/spec\.add_dependency "rails", "([^"]+)", "([^"]+)"/).captures
    node_boundary = package_metadata.fetch("engines").fetch("node")
    workflow_node_versions = ci_workflow.match(/node-version:\s+\[([^\]]+)\]/)[1].scan(/"([^"]+)"/).flatten
    expected_node_versions = node_boundary.scan(/\d+/).uniq
    rails_matrix_rows = ci_workflow.scan(/rails: "([^"]+)"\n\s+ruby-version: "([^"]+)"\n\s+gemfile: ([^\n]+)/)

    expect(support_boundary).to include("- Ruby: `#{ruby_requirement}`")
    expect(support_boundary).to include("- Rails: `#{rails_requirements[0]}`, `#{rails_requirements[1]}`")
    expect(support_boundary).to include("The package metadata boundary is Node #{node_boundary}")
    expect(development_doc).to include("The package metadata boundary is Node #{node_boundary}")
    expect(workflow_node_versions).to eq(expected_node_versions)

    rails_matrix_rows.each do |rails_version, ruby_version, gemfile|
      expect(support_boundary).to include("| #{rails_version} | #{ruby_version} | `#{gemfile}` |")
    end

    expect(development_doc).to include(
      "support_boundary.md",
      "rails_fields_kit.gemspec",
      "package.json",
      ".github/workflows/ci.yml"
    )
    expect(support_boundary).to include(
      "representative CI coverage, not a separate host-app setup step or a full Rails/Ruby support matrix",
      "not a Tom Select runtime support policy for host applications"
    )
  end

  it "keeps configuration profile examples on current initializer keys without promoting profiles to API" do
    configuration_keys = configuration_source.match(/attr_accessor(?<body>.*?)\n\n/m)[:body].scan(/:([a-z_]+)/).flatten
    profile_keys = configuration_profiles.scan(/config\.([a-z_]+)\s*=/).flatten.uniq

    expect(profile_keys).not_to be_empty
    expect(profile_keys - configuration_keys).to eq([])

    profile_keys.each do |configuration_key|
      expect(configuration_doc).to include("`#{configuration_key}`")
    end

    expect(configuration_doc).to include(
      "[`configuration_profiles.md`](configuration_profiles.md)",
      "docs-only patterns, not named profiles, preset APIs, generator options, or design system policy owned by the gem"
    )
    expect(configuration_profiles).to include(
      "does not ship named initializer profiles",
      "starting points for app-owned configuration",
      "not presets, modes, or design system policy owned by the gem",
      "avoid a Ruby profile API, generator option, or preset registry"
    )
  end

  def read_repo_file(path)
    File.read(File.join(root, path))
  end
end
