# frozen_string_literal: true

require "json"
require "spec_helper"

RSpec.describe "repository documentation drift guards" do
  let(:root) { File.expand_path("..", __dir__) }

  def read_repo_file(path)
    File.read(File.join(root, path))
  end

  it "keeps generated setup notes upstream links pointed at existing onboarding docs" do
    template = read_repo_file("lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md")
    linked_paths = template.scan(%r{https://github\.com/matsuo-haruhito/rails_fields_kit/blob/main/([^>\s)]+)}).flatten

    expect(linked_paths).to include(
      "README.md",
      "doc/setup.md",
      "doc/public_api.md",
      "doc/configuration.md",
      "doc/field_helpers.md",
      "doc/controller_helpers.md",
      "doc/visual_references.md"
    )

    missing_paths = linked_paths.reject { |path| File.file?(File.join(root, path)) }

    expect(missing_paths).to eq([])
  end

  it "keeps support boundary docs aligned with gem metadata, package metadata, and representative CI rows" do
    support_boundary = read_repo_file("doc/support_boundary.md")
    development_doc = read_repo_file("doc/development.md")
    gemspec = read_repo_file("rails_fields_kit.gemspec")
    package_json = JSON.parse(read_repo_file("package.json"))
    workflow = read_repo_file(".github/workflows/ci.yml")

    ruby_requirement = gemspec[/spec\.required_ruby_version = "([^"]+)"/, 1]
    rails_requirements = gemspec[/spec\.add_dependency "rails", (.+)$/, 1].scan(/"([^"]+)"/).flatten
    node_engine = package_json.fetch("engines").fetch("node")
    node_majors = node_engine.scan(/(\d+)\.x/).flatten
    representative_rows = workflow.scan(/rails: "([^"]+)"\n\s+ruby-version: "([^"]+)"\n\s+gemfile: (gemfiles\/[^\s]+)/)

    expect(support_boundary).to include("- Ruby: `#{ruby_requirement}`")
    expect(support_boundary).to include("- Rails: #{rails_requirements.map { |requirement| "`#{requirement}`" }.join(", ")}")
    expect(support_boundary).to include("Node #{node_engine}")
    expect(development_doc).to include("Node #{node_engine}")
    expect(development_doc).to include("`package.json`", "GitHub Actions `javascript` job")
    node_majors.each do |node_major|
      expect(workflow).to include("\"#{node_major}\"")
    end

    representative_rows.each do |rails_version, ruby_version, gemfile|
      expect(support_boundary).to include("| #{rails_version} | #{ruby_version} | `#{gemfile}` |")
    end
  end

  it "keeps open PR freshness review guidance visible without GitHub API automation" do
    development_doc = read_repo_file("doc/development.md")

    expect(development_doc).to include("## Open PR freshness checks")
    expect(development_doc).to include("latest workflow run state")
    expect(development_doc).to include("PR metadata `mergeable` value")
    expect(development_doc).to include("behind, diverged, or superseded")
    expect(development_doc).to include("Do not add a GitHub API-dependent CI job")
  end
end
