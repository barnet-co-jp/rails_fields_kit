# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "package contents" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:readme_path) { File.expand_path("../README.md", __dir__) }
  let(:readme) { File.read(readme_path) }
  let(:setup_doc_path) { File.expand_path("../doc/setup.md", __dir__) }
  let(:setup_doc) { File.read(setup_doc_path) }
  let(:public_api_path) { File.expand_path("../doc/public_api.md", __dir__) }
  let(:public_api) { File.read(public_api_path) }
  let(:textarea_autosize_path) { File.expand_path("../doc/textarea_autosize.md", __dir__) }
  let(:textarea_autosize) { File.read(textarea_autosize_path) }
  let(:field_helpers_path) { File.expand_path("../doc/field_helpers.md", __dir__) }
  let(:field_helpers) { File.read(field_helpers_path) }
  let(:controller_helpers_path) { File.expand_path("../doc/controller_helpers.md", __dir__) }
  let(:controller_helpers) { File.read(controller_helpers_path) }
  let(:sample_app_checklist_path) { File.expand_path("../doc/sample_app_checklist.md", __dir__) }
  let(:sample_app_checklist) { File.read(sample_app_checklist_path) }
  let(:sample_app_results_path) { File.expand_path("../doc/sample_app_results.md", __dir__) }
  let(:sample_app_results) { File.read(sample_app_results_path) }
  let(:form_builder_path) { File.expand_path("../lib/rails_fields_kit/form_builder.rb", __dir__) }
  let(:form_builder_source) { File.read(form_builder_path) }

  it "ships the documented JavaScript package entrypoints" do
    expect(specification.files).to include(
      "package.json",
      "app/javascript/rails_fields_kit/index.js",
      "app/javascript/rails_fields_kit/tom_select_controller.js"
    )
  end

  it "ships the install-flow docs and generator artifacts described by README and setup" do
    expect(specification.files).to include(
      "README.md",
      "doc/setup.md",
      "doc/sample_app_checklist.md",
      "lib/generators/rails_fields_kit/install_generator.rb",
      "lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md"
    )
  end

  it "keeps README and setup JavaScript helper summaries pointed at the public API source of truth" do
    javascript_exports = markdown_section(public_api, "## JavaScript exports")
    readme_js_setup = markdown_section(readme, "### Direct imports and package exports")

    expect(javascript_exports).to include(
      "### Current package-root exports",
      "`TomSelectController`",
      "rendered-field contract reader",
      "Future package-root helpers should follow the same boundary"
    )

    expect(readme_js_setup).to include(
      "`rails_fields_kit/index.js` re-exports the same controller",
      "direct `rails_fields_kit/tom_select_controller` entrypoint",
      "read-only rendered-field contract helpers",
      "[`doc/public_api.md`](doc/public_api.md#javascript-exports)",
      "source of truth",
      "current helper list and responsibility boundary"
    )

    expect(setup_doc).to include(
      "The package root also exposes read-only rendered-field contract helpers",
      "Use [`public_api.md#javascript-exports`](public_api.md#javascript-exports) as the current source of truth for the helper list and return shape"
    )
  end

  it "ships the maintained public reference docs linked from README and setup" do
    expect(specification.files).to include(
      "doc/public_api.md",
      "doc/select_migration.md",
      "doc/field_helpers.md",
      "doc/textarea_autosize.md",
      "doc/controller_helpers.md",
      "doc/configuration.md",
      "doc/events.md",
      "doc/tom_select_turbo_lifecycle.md",
      "doc/token_suggestions.md",
      "doc/ransack_suggestions.md",
      "doc/table_adapters.md",
      "doc/tom_select_visual_reference.html",
      "doc/native_field_visual_reference.html",
      "doc/table_metadata_visual_reference.html"
    )
  end

  it "keeps textarea autosize boundary docs packaged and linked from public API" do
    expect(specification.files).to include("doc/textarea_autosize.md")
    expect(public_api).to include("[`textarea_autosize.md`](textarea_autosize.md)")
    expect(textarea_autosize).to include(
      "Autosize remains host-app owned",
      "does not add an `autosize:` option",
      "Turbo reconnect behavior for any autosize controller",
      "default `rfk_text_area` behavior remains unchanged"
    )
  end

  it "keeps remote workflow request option examples visible across representative docs" do
    option_names = %w[
      query_params
      selected_query_params
      create_params
      selected_param
      selected_multiple_param
      create_param
    ]
    controller_reference = [
      markdown_section(controller_helpers, "## `rfk_find_with`"),
      markdown_section(controller_helpers, "## `rfk_create_with`"),
      markdown_section(controller_helpers, "## Fixed request params and scoping")
    ].join("\n")
    remote_field_helper_section = markdown_section(field_helpers, "## Remote option options")

    option_names.each do |option_name|
      expected_signal = "#{option_name}:"

      expect(controller_reference).to include(expected_signal)
      expect(remote_field_helper_section).to include(expected_signal)
      expect(readme).to include(expected_signal)
    end

    expect(controller_reference).to include(
      "request-shaping helpers",
      "host app controller/model layer"
    )
    expect(remote_field_helper_section).to include(
      "request-shaping options",
      "Rails Fields Kit appends `query_params:` as fixed query string scope",
      "Selected values still use `selected_url:` with `selected_param:` or `selected_multiple_param:`",
      "create input text still uses `create_url:` with JSON `create_params:` plus `create_param:`"
    )
  end

  it "keeps native FormBuilder helpers aligned with public docs without making the quick chooser exhaustive" do
    native_helpers = native_helper_names_from(form_builder_source)
    native_section = public_api.match(/Native input helpers:\n\n(?<list>(?:- `rfk_[a-z_]+`\n)+)/)[:list]
    documented_native_helpers = native_section.scan(/`(rfk_[a-z_]+)`/).flatten
    quick_chooser = markdown_section(field_helpers, "## Quick chooser")

    expect(native_helpers).to eq(%w[
      rfk_text_field
      rfk_text_area
      rfk_number_field
      rfk_range_field
      rfk_money_field
      rfk_percent_field
      rfk_email_field
      rfk_url_field
      rfk_phone_field
      rfk_search_field
      rfk_password_field
    ])
    expect(documented_native_helpers).to eq(native_helpers)
    expect(quick_chooser).to include("the matching native helper such as")
  end

  it "ships the release-facing verification docs linked from README" do
    expect(specification.files).to include(
      "doc/development.md",
      "doc/sample_app_results.md",
      "doc/final_release_checklist.md",
      "doc/selected_preload_release_gate.md",
      "doc/release.md",
      "doc/release_notes_0_1_1.md",
      "doc/release_notes_0_1_0.md"
    )
  end

  it "keeps gemspec metadata URLs pointed at repository-local package docs" do
    repository_root_uri = "#{specification.homepage}/blob/main/"

    expect(specification.metadata.fetch("source_code_uri")).to eq(specification.homepage)

    {
      "changelog_uri" => "CHANGELOG.md",
      "documentation_uri" => "doc/setup.md"
    }.each do |metadata_key, expected_path|
      metadata_uri = specification.metadata.fetch(metadata_key)
      local_path = repository_local_path_from_metadata(metadata_uri, repository_root_uri)

      expect(metadata_uri).to eq("#{repository_root_uri}#{expected_path}")
      expect(local_path).to eq(expected_path)
      expect(specification.files).to include(expected_path)
      expect(File.file?(File.expand_path("../#{local_path}", __dir__))).to be(true)
    end
  end

  it "keeps sample app package-root evidence placement docs aligned" do
    checklist_chooser = markdown_section(sample_app_checklist, "## Choose where to record evidence")
    narrow_pr_chooser = markdown_section(sample_app_checklist, "### Choose the representative lane for a narrow PR")
    results_route_map = sample_app_results.split("\n## Target release\n", 2).first
    javascript_setup_results = markdown_section(sample_app_results, "## JavaScript setup checks")

    expect(checklist_chooser).to include(
      "sample_app_results.md",
      "For a narrow PR that is not a release candidate, a PR comment is enough",
      "package_root_helper_release_evidence.md",
      "choose representative helper checks before recording the result"
    )

    expect(narrow_pr_chooser).to include(
      "package-root helper import/read-only contract",
      "the helper-specific evidence guide",
      "PR comment for narrow docs/spec work",
      "sample_app_results.md` for release candidates"
    )

    expect(results_route_map).to include(
      "JavaScript setup and package-root helper evidence",
      "read-only rendered-field helper evidence",
      "not a new release gate or runtime contract"
    )

    expect(javascript_setup_results).to include(
      "package-root helper lanes in release scope were selected from `doc/package_root_helper_release_evidence.md`",
      "matched the current `doc/public_api.md#javascript-exports` helper list",
      "Package-root helper lanes checked:"
    )
  end

  it "keeps grouped select sample app evidence lanes aligned" do
    checklist_lane = markdown_section(
      sample_app_checklist,
      "## Verify `rfk_grouped_select` representative optgroup-preserving lane"
    )
    results_lane = markdown_section(
      sample_app_results,
      "## `rfk_grouped_select` representative optgroup-preserving lane checks"
    )

    expect(checklist_lane).to include(
      "optgroup-preserving contract end to end",
      "ordinary selected ID or value lane rather than a remote-search or token-metadata lane",
      "does not depend on `url:`, `selected_url:`, or `create_url:`"
    )
    expect(results_lane).to include(
      "optgroup-preserving lane",
      "ordinary selected ID or value lane rather than a remote-search or token-metadata lane",
      "stayed independent from `url:`, `selected_url:`, and `create_url:`"
    )
  end

  def native_helper_names_from(source)
    source.scan(/^    def (rfk_[a-z_]+).*?\n(.*?)^    end/m).filter_map do |helper_name, body|
      helper_name if body.include?("rfk_native_field(")
    end
  end

  def repository_local_path_from_metadata(uri, repository_root_uri)
    uri.delete_prefix(repository_root_uri)
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
