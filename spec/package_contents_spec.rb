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
  let(:visual_references_path) { File.expand_path("../doc/visual_references.md", __dir__) }
  let(:visual_references) { File.read(visual_references_path) }
  let(:textarea_autosize_path) { File.expand_path("../doc/textarea_autosize.md", __dir__) }
  let(:textarea_autosize) { File.read(textarea_autosize_path) }
  let(:field_helpers_path) { File.expand_path("../doc/field_helpers.md", __dir__) }
  let(:field_helpers) { File.read(field_helpers_path) }
  let(:tom_select_class_names_path) { File.expand_path("../doc/tom_select_class_names.md", __dir__) }
  let(:tom_select_class_names) { File.read(tom_select_class_names_path) }
  let(:styling_boundary_path) { File.expand_path("../doc/styling_boundary.md", __dir__) }
  let(:styling_boundary) { File.read(styling_boundary_path) }
  let(:controller_helpers_path) { File.expand_path("../doc/controller_helpers.md", __dir__) }
  let(:controller_helpers) { File.read(controller_helpers_path) }
  let(:token_suggestions_path) { File.expand_path("../doc/token_suggestions.md", __dir__) }
  let(:token_suggestions) { File.read(token_suggestions_path) }
  let(:saved_search_token_suggestion_evidence_path) { File.expand_path("../doc/saved_search_token_suggestion_evidence.md", __dir__) }
  let(:saved_search_token_suggestion_evidence) { File.read(saved_search_token_suggestion_evidence_path) }
  let(:shared_metadata_navigation_path) { File.expand_path("../doc/shared_metadata_navigation.md", __dir__) }
  let(:shared_metadata_navigation) { File.read(shared_metadata_navigation_path) }
  let(:shared_metadata_runnable_guide_path) { File.expand_path("../doc/shared_metadata_runnable_guide.md", __dir__) }
  let(:shared_metadata_runnable_guide) { File.read(shared_metadata_runnable_guide_path) }
  let(:configuration_profiles_path) { File.expand_path("../doc/configuration_profiles.md", __dir__) }
  let(:configuration_profiles) { File.read(configuration_profiles_path) }
  let(:sample_app_checklist_path) { File.expand_path("../doc/sample_app_checklist.md", __dir__) }
  let(:sample_app_checklist) { File.read(sample_app_checklist_path) }
  let(:sample_app_results_path) { File.expand_path("../doc/sample_app_results.md", __dir__) }
  let(:sample_app_results) { File.read(sample_app_results_path) }
  let(:sample_app_results_route_guide_path) { File.expand_path("../doc/sample_app_results_route_guide.md", __dir__) }
  let(:sample_app_results_route_guide) { File.read(sample_app_results_route_guide_path) }
  let(:package_root_helper_release_evidence_path) { File.expand_path("../doc/package_root_helper_release_evidence.md", __dir__) }
  let(:package_root_helper_release_evidence) { File.read(package_root_helper_release_evidence_path) }
  let(:datalist_boundary_path) { File.expand_path("../doc/datalist_boundary.md", __dir__) }
  let(:datalist_boundary) { File.read(datalist_boundary_path) }
  let(:slug_helper_boundary_path) { File.expand_path("../doc/slug_helper_boundary.md", __dir__) }
  let(:slug_helper_boundary) { File.read(slug_helper_boundary_path) }
  let(:form_builder_paths) do
    %w[
      form_builder.rb
      form_builder_check_box.rb
      form_builder_radio_button.rb
      form_builder_file_field.rb
      form_builder_native_date_time_fields.rb
    ].map { |filename| File.expand_path("../lib/rails_fields_kit/#{filename}", __dir__) }
  end
  let(:form_builder_source) { form_builder_paths.map { |path| File.read(path) }.join("\n") }

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
      "current helper list, return shapes, and responsibility boundaries"
    )

    expect(setup_doc).to include(
      "The package root also exposes read-only rendered-field contract helpers",
      "Use [`public_api.md#javascript-exports`](public_api.md#javascript-exports) as the current source of truth for the helper list and return shape"
    )
  end

  it "keeps Tom Select class names focused docs packaged and routed from styling docs" do
    expect(specification.files).to include("doc/tom_select_class_names.md")

    expect(tom_select_class_names).to include(
      "`tom_select_class_names:` is a field-level pass-through",
      "`wrapper_html:`",
      "production CSS or theme presets",
      "Host apps remain responsible"
    )

    expect(styling_boundary).to include(
      "[`tom_select_class_names:`](tom_select_class_names.md)",
      "Passing field-level `tom_select_class_names:` through",
      "Production CSS"
    )

    expect(field_helpers).to include(
      "### Shared Tom Select class names option",
      "[`tom_select_class_names.md`](tom_select_class_names.md)",
      "This option is separate from Rails Fields Kit wrapper customization"
    )
  end

  it "keeps token and shared metadata evidence guides packaged without promoting new ownership" do
    expect(specification.files).to include(
      "doc/saved_search_token_suggestion_evidence.md",
      "doc/shared_metadata_navigation.md",
      "doc/shared_metadata_runnable_guide.md"
    )

    expect(token_suggestions).to include(
      "[`saved_search_token_suggestion_evidence.md`](saved_search_token_suggestion_evidence.md)",
      "saved-search token suggestions",
      "suggestion option JSON",
      "not currently provide an independent saved search selector helper"
    )

    expect(saved_search_token_suggestion_evidence).to include(
      "Use this guide when a release or narrow PR needs representative evidence",
      "token suggestion option JSON for `rfk_token_search`",
      "not a separate saved-search selector helper",
      "The host app owns parser behavior, search execution, saved-search storage, permissions, and any saved-search management UI"
    )

    expect(shared_metadata_navigation).to include(
      "[`shared_metadata_runnable_guide.md`](shared_metadata_runnable_guide.md)",
      "app-owned metadata source",
      "not a Rails Fields Kit-owned registry or query execution path"
    )

    expect(shared_metadata_runnable_guide).to include(
      "one host-app-owned metadata source",
      "RailsFieldsKit::TokenSuggestions.build",
      "RailsFieldsKit::RansackSuggestions.build",
      "RailsFieldsKit::TableFilterInput.ransack_filter",
      "Do not treat this guide as a registry API"
    )
  end

  it "keeps focused boundary sample evidence packaged without promoting proposal helpers" do
    expect(specification.files).to include(
      "doc/datalist_boundary_sample_evidence.html",
      "doc/slug_helper_boundary_sample_evidence.html",
      "doc/native_character_counter_boundary_sample_evidence.html"
    )

    expect(datalist_boundary).to include(
      "[`datalist_boundary_sample_evidence.html`](datalist_boundary_sample_evidence.html)",
      "not a new public helper or production CSS contract",
      "Do not list `rfk_datalist_field` in `doc/public_api.md` unless a later implementation PR actually adds and tests the helper"
    )

    expect(slug_helper_boundary).to include(
      "[`slug_helper_boundary_sample_evidence.html`](slug_helper_boundary_sample_evidence.html)",
      "does not currently provide a dedicated title-to-slug helper such as `rfk_slug_field`",
      "no current `rfk_slug_field` public helper"
    )

    expect(visual_references).to include(
      "[`native_character_counter_boundary_sample_evidence.html`](native_character_counter_boundary_sample_evidence.html)",
      "host-owned counter copy",
      "without presenting `character_counter:` or any helper option as current API"
    )
  end

  it "keeps text override visual reference packaged and mapped as a copy review lane" do
    expect(specification.files).to include("doc/tom_select_text_override_visual_reference.html")
    expect(visual_references).to include(
      "[`tom_select_text_override_visual_reference.html`](tom_select_text_override_visual_reference.html)",
      "Configured `no_results_text`, `loading_text`, and `create_text` copy states",
      "without confusing it with locale ownership or request behavior"
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

  it "keeps blank-query remote search policies readable without moving host-app responsibilities" do
    blank_query_policy = markdown_section(controller_helpers, "### Blank query policy")

    expect(blank_query_policy).to include(
      "Choose the blank-query behavior deliberately",
      "Allow a scoped initial option list",
      "Block empty or too-short server requests",
      "FormBuilder's field-level `min_length:` is a browser-side loading hint",
      "`minimum_query_length:` is the server endpoint policy",
      "such as `{ \"options\": [] }`",
      "The host app remains responsible for authorization, tenant scoping, query parsing, search execution"
    )
  end

  it "keeps allow_clear public option docs aligned with the Tom Select clear plugin boundary" do
    tom_select_helpers = markdown_section(field_helpers, "## Tom Select-backed helpers")
    public_api_form_builder = markdown_section(public_api, "## FormBuilder helpers")

    expect(tom_select_helpers).to include(
      "allow_clear: true",
      "adds `clear_button` to the effective plugin list",
      "ordinary Rails select options such as `include_blank:` or `prompt:` still own the empty-state wording"
    )
    expect(public_api_form_builder).to include(
      "field-level `allow_clear: true`",
      "Tom Select's `clear_button` affordance",
      "empty-state wording remain host-app or Rails select-option responsibility",
      "Explicit `plugins:` values still replace initializer defaults"
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
      rfk_check_box
      rfk_radio_button
      rfk_file_field
      rfk_date_field
      rfk_time_field
      rfk_datetime_local_field
      rfk_color_field
    ])
    expect(documented_native_helpers).to eq(native_helpers)
    expect(quick_chooser).to include(
      "native browser input with shared wrapper, hint, error, affix, and accessibility behavior for text, textarea, or search",
      "A native password, checkbox, radio, file, or range control with focused ownership boundaries",
      "Native numeric, money, percent, email, URL, or phone inputs",
      "Native date, time, datetime-local, or color controls"
    )
  end

  it "keeps README configuration profile route aligned with the docs-only boundary" do
    docs_map = markdown_section(readme, "## Docs map")
    configuration_profiles_boundary = markdown_section(configuration_profiles, "## Boundary")

    expect(specification.files).to include("doc/configuration_profiles.md")
    expect(docs_map).to include(
      "[`doc/configuration.md`](doc/configuration.md)",
      "field-level override precedence",
      "[`doc/configuration_profiles.md`](doc/configuration_profiles.md)",
      "docs-only copyable profile examples"
    )
    expect(configuration_profiles).to include(
      "does not ship named initializer profiles",
      "starting points for app-owned configuration",
      "not presets, modes, or design system policy owned by the gem"
    )
    expect(configuration_profiles_boundary).to include(
      "avoid a Ruby profile API, generator option, or preset registry",
      "separate feature decision"
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
    plugin_contract_lane = markdown_section(package_root_helper_release_evidence, "## Tom Select plugin contract reader")

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
      "Package-root helper lanes checked:",
      "helper-specific examples such as native accessibility, Tom Select plugin contract, or selected preload config stayed tied to the selected evidence lane"
    )

    expect(plugin_contract_lane).to include(
      "tomSelectPluginContract(element)",
      "import { tomSelectPluginContract } from \"rails_fields_kit\"",
      "allow_clear: true",
      "hasClearButton",
      "hasRemoveButton",
      "unrelated element returned null",
      "Plugin assets, styling, mutation, empty-state copy, and Tom Select plugin lifecycle remained host-app or Tom Select responsibilities"
    )
  end

  it "keeps sample app evidence result vocabulary aligned with the route guide" do
    route_guide_visual_words = markdown_section(sample_app_results_route_guide, "## Visual Reference Result Words")
    visual_reference_results = markdown_section(sample_app_results, "## Visual reference render checks")

    expect(specification.files).to include("doc/sample_app_results_route_guide.md")
    expect(sample_app_results).to include(
      "`doc/sample_app_results_route_guide.md`",
      "when to update this evidence log",
      "without treating CI success or source review as browser approval"
    )
    expect(sample_app_results_route_guide).to include(
      "Use this companion note when a release or PR needs manual evidence",
      "Record in PR comment",
      "SOURCE REVIEW ONLY",
      "DEFERRED"
    )

    ["PASS", "FAIL", "SOURCE REVIEW ONLY", "DEFERRED"].each do |result_word|
      expect(route_guide_visual_words).to include("`#{result_word}`")
      expect(visual_reference_results).to include("`#{result_word}`")
    end

    expect(route_guide_visual_words).to include(
      "A real browser checked the named artifact, viewport, and lane",
      "Do not use `PASS` for GitHub Actions success",
      "not visual approval"
    )
    expect(visual_reference_results).to include(
      "Browser review result",
      "Evidence location",
      "Do not treat CI success or source review alone as visual approval",
      "not new helper behavior"
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
      helper_name if body.include?("rfk_native_field(") || body.include?("check_box(method") || body.include?("radio_button(method")
    end
  end

  def repository_local_path_from_metadata(uri, repository_root_uri)
    uri.delete_prefix(repository_root_uri)
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
