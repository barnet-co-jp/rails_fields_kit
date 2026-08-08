# frozen_string_literal: true

require "json"
require "spec_helper"

RSpec.describe "repository documentation drift guards" do
  let(:root) { File.expand_path("..", __dir__) }

  def read_repo_file(path)
    File.read(File.join(root, path))
  end

  def markdown_section(source, heading)
    start_index = source.index(heading)
    raise "missing heading #{heading}" unless start_index

    next_heading = source.index(/^#{Regexp.escape(heading[/^#+/])} /, start_index + heading.length)
    source[start_index...(next_heading || source.length)]
  end

  it "keeps generated setup notes upstream links pointed at first-pass onboarding docs" do
    template = read_repo_file("lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md")
    linked_paths = template.scan(%r{https://github\.com/matsuo-haruhito/rails_fields_kit/blob/main/([^>\s)]+)}).flatten

    expect(linked_paths).to contain_exactly(
      "README.md",
      "doc/configuration_profiles.md",
      "doc/package_root_helper_release_evidence.md",
      "doc/selected_preload_release_gate.md",
      "doc/setup.md",
      "doc/setup_doctor_output_review.md",
      "doc/tom_select_text_override_visual_reference.html"
    )

    missing_paths = linked_paths.reject { |path| File.file?(File.join(root, path)) }

    expect(missing_paths).to eq([])
  end

  it "keeps repository-local docs link check scope explicit for HTML fragment links" do
    development_doc = read_repo_file("doc/development.md")
    readme = read_repo_file("README.md")
    visual_references = read_repo_file("doc/visual_references.md")

    expect(development_doc).to include(
      "lightweight repository-local documentation link check",
      "relative file targets",
      "repository-local Markdown heading anchors",
      "same-file HTML fragment links",
      "repository-local static HTML fragment links",
      "doc/*.html#id",
      "external URLs, browser-rendered routes, JavaScript-generated dynamic ids, and visual approval remain intentionally outside its scope",
      "external URL checker, browser crawler, or screenshot approval workflow"
    )
    expect(readme).to include(
      "[`doc/visual_references.md`](doc/visual_references.md)",
      "[`doc/visual_reference_index.html`](doc/visual_reference_index.html)"
    )
    expect(visual_references).to include(
      "[`visual_reference_index.html`](visual_reference_index.html)",
      "[`public_api.md#javascript-exports`](public_api.md#javascript-exports)"
    )
  end

  it "keeps visual reference HTML artifacts structurally reviewable" do
    visual_references = read_repo_file("doc/visual_references.md")
    artifact_paths = visual_references.scan(/\]\(([^)#]+\.html)(?:#[^)]+)?\)/).flatten.uniq.sort

    expect(artifact_paths).to include(
      "visual_reference_index.html",
      "tom_select_visual_reference.html",
      "native_field_visual_reference.html",
      "table_metadata_visual_reference.html"
    )

    artifact_paths.each do |artifact_path|
      artifact = read_repo_file("doc/#{artifact_path}")

      expect(artifact).to match(/<html[\s>]/i), "expected #{artifact_path} to contain an html root"
      expect(artifact).to match(/<title[\s>]/i), "expected #{artifact_path} to contain a title"
      expect(artifact).to match(/<body[\s>]/i), "expected #{artifact_path} to contain a body"
      expect(artifact).to match(/<h1[\s>]/i), "expected #{artifact_path} to contain a primary heading"
    end
  end

  it "keeps README direct import helper guidance lightweight and tied to the public API source of truth" do
    readme = read_repo_file("README.md")
    public_api = read_repo_file("doc/public_api.md")
    development_doc = read_repo_file("doc/development.md")

    direct_imports_section = markdown_section(readme, "### Direct imports and package exports")
    javascript_exports_section = markdown_section(public_api, "## JavaScript exports")

    expect(direct_imports_section).to include(
      "rails_fields_kit/tom_select_controller",
      "rails_fields_kit/index.js",
      "doc/public_api.md",
      "#javascript-exports",
      "doc/package_root_helper_release_evidence.md"
    )
    expect(direct_imports_section).to include("readRenderedSelectedPreloadConfig")
    expect(javascript_exports_section).to include("readRenderedSelectedPreloadConfig")

    public_helper_names = javascript_exports_section.scan(/`([a-z][A-Za-z0-9]+\([^`]*\))`/).flatten
    readme_helper_names = direct_imports_section.scan(/`([a-z][A-Za-z0-9]+\([^`]*\))`/).flatten

    expect(readme_helper_names).to include("readRenderedSelectedPreloadConfig(...)")
    expect(readme_helper_names).not_to match_array(public_helper_names)
    expect(development_doc).to include(
      "The package export smoke derives package-root named-export expectations from the JavaScript exports table in `doc/public_api.md`"
    )
  end

  it "keeps support boundary docs aligned with gem metadata, package metadata, and representative CI rows" do
    support_boundary = read_repo_file("doc/support_boundary.md")
    development_doc = read_repo_file("doc/development.md")
    release_doc = read_repo_file("doc/release.md")
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
    expect(release_doc).to include("doc/support_boundary.md")
    expect(release_doc).to include("Rails 7.0 and newer")
    expect(release_doc).to include("Rails 7 and Rails 8")
    node_majors.each do |node_major|
      expect(workflow).to include("\"#{node_major}\"")
      expect(release_doc).to include("Node #{node_major}.x")
    end

    representative_rows.each do |rails_version, ruby_version, gemfile|
      expect(support_boundary).to include("| #{rails_version} | #{ruby_version} | `#{gemfile}` |")
      expect(release_doc).to include("Rails #{rails_version} / Ruby #{ruby_version}")
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
