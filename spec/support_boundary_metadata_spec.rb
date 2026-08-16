# frozen_string_literal: true

require "json"
require "rubygems"
require "spec_helper"
require "yaml"

RSpec.describe "support boundary metadata" do
  let(:repository_root) { File.expand_path("..", __dir__) }
  let(:gemspec) { Gem::Specification.load(File.join(repository_root, "rails_fields_kit.gemspec")) }
  let(:package_metadata) { JSON.parse(File.read(File.join(repository_root, "package.json"))) }
  let(:ci_workflow) do
    YAML.safe_load(
      File.read(File.join(repository_root, ".github/workflows/ci.yml")),
      aliases: false
    )
  end
  let(:support_boundary) { File.read(File.join(repository_root, "doc/support_boundary.md")) }
  let(:development_guide) { File.read(File.join(repository_root, "doc/development.md")) }
  let(:release_guide) { File.read(File.join(repository_root, "doc/release.md")) }

  it "keeps support docs aligned with gemspec, package metadata, and representative CI lanes" do
    rails_dependency = gemspec.dependencies.find { |dependency| dependency.name == "rails" }
    expect(rails_dependency).not_to be_nil

    ruby_requirement = gemspec.required_ruby_version.to_s
    rails_requirements = rails_dependency.requirement.requirements.map do |operator, version|
      "#{operator} #{version}"
    end
    node_engine = package_metadata.fetch("engines").fetch("node")
    node_major_versions = node_engine.scan(/\d+/)

    rails_matrix = ci_workflow.fetch("jobs").fetch("rails_matrix").fetch("strategy").fetch("matrix").fetch("include")
    node_matrix = ci_workflow.fetch("jobs").fetch("javascript").fetch("strategy").fetch("matrix").fetch("node-version").map(&:to_s)

    expect(support_boundary).to include("Ruby: `#{ruby_requirement}`")
    rails_requirements.each do |requirement|
      expect(support_boundary).to include("`#{requirement}`")
    end
    expect(support_boundary).to include("The source of truth for these install-time boundaries is `rails_fields_kit.gemspec`")

    expect(node_matrix).to match_array(node_major_versions)
    expect(support_boundary).to include("Node #{node_major_versions.map { |major| "#{major}.x" }.join(" || ")}")
    node_major_versions.each do |major|
      expect(support_boundary).to include("Node #{major}.x")
    end

    rails_matrix.each do |lane|
      expect(support_boundary).to include(
        "| #{lane.fetch("rails")} | #{lane.fetch("ruby-version")} | `#{lane.fetch("gemfile")}` |"
      )
      expect(release_guide).to include("Rails #{lane.fetch("rails")} / Ruby #{lane.fetch("ruby-version")}")
    end

    expect(development_guide).to include(
      "`doc/support_boundary.md` plus this development guide must stay aligned with the Ruby / Rails / Node version values declared in gem metadata, package metadata, and representative CI rows"
    )
    expect(support_boundary).to include(
      "not a Tom Select runtime support policy",
      "package manager policy",
      "host-app runtime responsibility"
    )
  end
end
