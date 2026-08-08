# frozen_string_literal: true

require "json"
require "rubygems"
require "spec_helper"

RSpec.describe "docs package inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:package_json) { JSON.parse(File.read(File.join(root, "package.json"))) }
  let(:readme) { read_doc("README.md") }
  let(:setup_doc) { read_doc("doc/setup.md") }
  let(:setup_doctor_machine_readable) { read_doc("doc/setup_doctor_machine_readable.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:sample_app_results) { read_doc("doc/sample_app_results.md") }
  let(:sample_app_results_route_guide) { read_doc("doc/sample_app_results_route_guide.md") }
  let(:token_table_sample_app_evidence) { read_doc("doc/token_table_sample_app_evidence.md") }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:visual_reference_index) { read_doc("doc/visual_reference_index.html") }
  let(:styling_boundary) { read_doc("doc/styling_boundary.md") }
  let(:configuration_doc) { read_doc("doc/configuration.md") }
  let(:configuration_wrapper_class_visual_reference) { read_doc("doc/configuration_wrapper_class_visual_reference.html") }
  let(:native_character_counter_boundary) { read_doc("doc/native_character_counter_boundary_sample_evidence.html") }
  let(:native_select_boundary) { read_doc("doc/native_select_boundary_sample_evidence.html") }
  let(:collection_group_helpers) { read_doc("doc/collection_group_helpers.md") }
  let(:collection_group_boundary_sample_evidence) { read_doc("doc/collection_group_boundary_sample_evidence.html") }
  let(:grouped_select) { read_doc("doc/grouped_select.md") }
  let(:range_field) { read_doc("doc/range_field.md") }
  let(:native_date_time_color_fields) { read_doc("doc/native_date_time_color_fields.md") }
  let(:file_field) { read_doc("doc/file_field.md") }
  let(:tom_select_request_failure_visual_reference) { read_doc("doc/tom_select_request_failure_visual_reference.html") }
  let(:tom_select_no_event_boundary) { read_doc("doc/tom_select_no_event_boundary_review.html") }
  let(:dropdown_parent_release_evidence) { read_doc("doc/dropdown_parent_release_evidence.md") }
  let(:release_doc) { read_doc("doc/release.md") }
  let(:product_profile) { read_doc("Product Profile.md") }

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
      "doc/tom_select_text_override_visual_reference.html",
      "doc/native_field_visual_reference.html",
      "doc/table_metadata_visual_reference.html"
    )
  end

  it "ships the release-facing verification docs linked from README" do
    expect(specification.files).to include(
      "doc/development.md",
      "doc/sample_app_results.md",
      "doc/sample_app_results_route_guide.md",
      "doc/final_release_checklist.md",
      "doc/selected_preload_release_gate.md",
      "doc/release.md",
      "doc/release_notes_0_1_1.md",
      "doc/release_notes_0_1_0.md"
    )
  end

  it "keeps documented direct subpath examples aligned with package exports" do
    direct_exports = package_json.fetch("exports").keys.grep_v(".").map { |path| path.delete_prefix("./") }
    documented_direct_examples = %w[
      tom_select_controller
      tom_select_text_override_contract
      native_field_accessibility_contract
      native_field_constraint_contract
    ]

    expect(direct_exports).to include(*documented_direct_examples)

    documented_direct_examples.each do |entrypoint|
      expect(readme).to include("rails_fields_kit/#{entrypoint}")
      expect(setup_doc).to include("rails_fields_kit/#{entrypoint}")
    end

    expect(readme).to include(
      "Do not treat the representative helper-family table below as the full package-root export inventory",
      "Check [`doc/public_api.md#javascript-exports`](doc/public_api.md#javascript-exports) for the complete current package-root surface"
    )
    expect(setup_doc).to include(
      "direct helper subpath examples in this setup guide are intentionally limited",
      "Do not extend the alias or importmap examples by copying every package-root helper name from the public API table"
    )
    expect(public_api).to include("## JavaScript exports")
  end

  it "keeps setup doctor machine-readable guide packaged and scoped to Ruby JSON usage" do
    expect(specification.files).to include("doc/setup_doctor_machine_readable.md")
    expect(readme).to include("[`doc/setup_doctor_machine_readable.md`](doc/setup_doctor_machine_readable.md)")
    expect(setup_doctor_machine_readable).to include(
      "RailsFieldsKit::SetupDoctor.new.run(io: output, format: :json)",
      "\"schema_version\": 1",
      "`manual`: advisory host-app check",
      "Rails Fields Kit does not define a universal pass/fail policy",
      "Do not treat this evidence lane as a CLI `--json` contract"
    )
  end

  it "keeps visual reference index packaged and scoped as a reviewer entrypoint" do
    expect(specification.files).to include("doc/visual_reference_index.html")
    expect(readme).to include(
      "[`doc/visual_references.md`](doc/visual_references.md)",
      "[`doc/visual_reference_index.html`](doc/visual_reference_index.html)"
    )
    expect(visual_references).to include(
      "one-screen reviewer entrypoint",
      "artifact links",
      "helper-family picker",
      "task picker",
      "narrow viewport readability check",
      "CI green as visual approval"
    )
    expect(visual_reference_index).to include(
      "Visual Reference Index",
      "Pick by artifact",
      "Pick by helper family",
      "Pick by reviewer task",
      "Narrow",
      "Public API source",
      "runtime behavior, search execution, authorization, and persistence out of scope"
    )
  end

  it "keeps the select migration visual reference packaged, routed, and scoped" do
    migration_reference = read_doc("doc/tom_select_migration_visual_reference.html")

    expect(specification.files).to include("doc/tom_select_migration_visual_reference.html")
    expect(visual_references).to include(
      "[`tom_select_migration_visual_reference.html`](tom_select_migration_visual_reference.html)",
      "collection_select",
      "rfk_select",
      "`allow_clear: true`",
      "`default_allow_clear`"
    )
    expect(visual_reference_index).to include(
      "tom_select_migration_visual_reference.html",
      "tom_select_lookup_metadata_visual_reference.html",
      "Setup Doctor diagnostic output",
      "visual_references.md#recording-browser-evidence"
    )
    expect(migration_reference).to include(
      "collection_select",
      "rfk_select",
      "include_blank",
      "allow_clear: true",
      "default_allow_clear",
      "same collection-backed field meaning",
      "Remote combobox",
      "selected preload",
      "authorization",
      "query execution",
      "production CSS"
    )
  end

  it "keeps configuration wrapper class visual reference packaged and scoped as class pass-through evidence" do
    expect(specification.files).to include("doc/configuration_wrapper_class_visual_reference.html")
    expect(styling_boundary).to include(
      "[`configuration_wrapper_class_visual_reference.html`](configuration_wrapper_class_visual_reference.html)",
      "rendered class pass-through lane"
    )
    expect(configuration_doc).to include(
      "## Wrapper and affix classes",
      "wrapper_html:",
      "tom_select_class_names:"
    )
    expect(configuration_wrapper_class_visual_reference).to include(
      "Configuration Wrapper Class Visual Reference",
      "host-app class pass-through only",
      "Rails Fields Kit does not own framework styles or production CSS",
      "Initializer class defaults only",
      "Static artifact only"
    )
  end

  it "keeps map-only native character counter boundary evidence packaged and scoped" do
    expect(specification.files).to include("doc/native_character_counter_boundary_sample_evidence.html")
    expect(visual_references).to include(
      "[`native_character_counter_boundary_sample_evidence.html`](native_character_counter_boundary_sample_evidence.html)",
      "native `maxlength` pass-through",
      "host-owned counter copy",
      "without presenting `character_counter:` or any helper option as current API"
    )
    expect(native_character_counter_boundary).to include(
      "Character counter sample evidence",
      "This static review artifact compares native wrapper wiring with host-app-owned character counter enhancements",
      "Ordinary native attribute pass-through such as <code>maxlength</code>",
      "Counter text and update timing",
      "No <code>character_counter:</code> helper option",
      "No runtime JavaScript or production CSS"
    )
    expect(public_api).not_to include("character_counter:")
  end

  it "keeps map-only native select boundary evidence packaged and scoped" do
    expect(specification.files).to include("doc/native_select_boundary_sample_evidence.html")
    expect(visual_references).to include(
      "[`native_select_boundary_sample_evidence.html`](native_select_boundary_sample_evidence.html)",
      "Map-only companion lane for plain native select, grouped optgroup select, and Tom Select-backed collection boundary comparison"
    )
    expect(native_select_boundary).to include(
      "Plain select stays browser-native",
      "Grouped select preserves optgroup meaning",
      "Searchable choices use Tom Select lanes",
      "Native browser selection semantics, Tom Select rendering, search execution, authorization, persistence, endpoint payloads, and production CSS remain outside this artifact.",
      "remote grouped options, authorization, and query execution are not Rails Fields Kit-owned"
    )
    expect(public_api).not_to include("rfk_native_select")
  end

  it "keeps proposal-only collection group boundary evidence packaged and unpromoted" do
    expect(specification.files).to include("doc/collection_group_boundary_sample_evidence.html")
    expect(collection_group_helpers).to include(
      "collection checkbox and radio groups outside the current FormBuilder helper API",
      "collection_group_boundary_sample_evidence.html",
      "proposal-only sample evidence",
      "not a current visual reference family member, release evidence lane, README entry, or public API inventory item"
    )
    expect(collection_group_boundary_sample_evidence).to include(
      "Collection Group Boundary Sample Evidence",
      "Proposal-only evidence",
      "does not introduce a Rails Fields Kit collection helper, public API, production CSS, runtime JavaScript, or release visual reference lane",
      "host-app-owned collection group markup",
      "Host apps own collection fieldset, legend, group hint, group error, option labels, checked-state semantics, and option policy.",
      "No public API, README, or visual index entry",
      "No collection checkbox or radio helper implementation"
    )
    expect(readme).not_to include("collection_group_boundary_sample_evidence.html")
    expect(public_api).not_to include("collection_group_boundary_sample_evidence.html")
    expect(visual_references).not_to include("collection_group_boundary_sample_evidence.html")
  end

  it "keeps grouped select focused docs packaged and routed from public API" do
    form_builder_helpers = markdown_section(public_api, "## FormBuilder helpers")

    expect(specification.files).to include("doc/grouped_select.md")
    expect(form_builder_helpers).to include(
      "`rfk_grouped_select`",
      "[`grouped_select.md`](grouped_select.md)",
      "collection-backed `<optgroup>` boundary",
      "separation from remote workflows or future optgroup metadata work"
    )
    expect(grouped_select).to include(
      "`rfk_grouped_select`",
      "rendered field kind is `grouped_select`",
      "ordinary select submission, selected values, disabled values, and `<optgroup>` rendering stay in the same collection-backed select lane",
      "Per-option `option_html:` attributes and group-level optgroup metadata are intentionally outside this helper's public boundary"
    )
  end

  it "keeps range field release evidence routed through native wrapper lanes" do
    expect(specification.files).to include("doc/range_field.md", "doc/sample_app_results.md")
    expect(public_api).to include("`rfk_range_field`", "[`range_field.md`](range_field.md)")
    expect(range_field).to include(
      "## Release Evidence Lane",
      "feature-specific native wrapper evidence",
      "native helper representative wrapper and accessibility lane",
      "native constraint attribute lane",
      "ordinary range options such as `min:`, `max:`, and `step:`",
      "live value previews",
      "custom slider styling",
      "multi-thumb range controls",
      "production CSS"
    )
    expect(sample_app_results).to include(
      "Native wrapper and accessibility",
      "Native constraint attribute checks",
      "range field table metadata evidence stayed separate from native `rfk_range_field` wrapper evidence"
    )
  end

  it "keeps native date, time, datetime-local, and color docs packaged and scoped" do
    expect(specification.files).to include("doc/native_date_time_color_fields.md")
    expect(public_api).to include(
      "[`native_date_time_color_fields.md`](native_date_time_color_fields.md)",
      "`rfk_date_field`",
      "`rfk_time_field`",
      "`rfk_datetime_local_field`",
      "`rfk_color_field`"
    )
    expect(native_date_time_color_fields).to include(
      "browser-native date, time, datetime-local, and color inputs",
      "reuse Rails Fields Kit's wrapper, label, hint, error, affix, and accessibility wiring",
      "browser-native picker behavior and browser support differences",
      "custom date picker, time picker, or color picker integrations",
      "masking, polyfills, and production CSS for picker controls",
      "timezone conversion and storage semantics"
    )
  end

  it "keeps file field focused docs packaged and scoped to native option pass-through" do
    expect(specification.files).to include("doc/file_field.md")
    expect(readme).to include("[`doc/file_field.md`](doc/file_field.md)")
    expect(public_api).to include(
      "`rfk_file_field`",
      "[`file_field.md`](file_field.md)",
      "file fields pass Rails file-input options such as `accept:`, `multiple:`, and `direct_upload:` through to Rails' native `file_field` helper",
      "multipart form setup, Active Storage direct upload JavaScript, preview UI, upload progress UI, file size and MIME validation policy, storage configuration, virus scanning, production CSS"
    )
    expect(file_field).to include(
      "Ordinary Rails `file_field` options such as `accept:`, `multiple:`, `direct_upload:`",
      "Rails Fields Kit does not change the submitted file parameter shape",
      "The host app remains responsible for multipart form setup, Active Storage direct upload behavior, file preview UI, upload progress UI, accepted file policy, file size and MIME validation, storage configuration, virus scanning, and production CSS",
      "Rails Fields Kit does not add upload JavaScript or replace Rails' file upload workflow"
    )
  end

  it "keeps token and table sample app evidence packaged and scoped" do
    expect(specification.files).to include("doc/token_table_sample_app_evidence.md", "doc/sample_app_results.md")
    expect(token_table_sample_app_evidence).to include(
      "after the older combined sample-app issue was split",
      "`rfk_token_search` helper or token-search setup",
      "`rfk_token_suggestions_with` or `RailsFieldsKit::TokenSuggestions.build`",
      "`RailsFieldsKit::RansackSuggestions.build`",
      "`rfk_table_filters` / `rfk_table_cell_editors`",
      "query execution, preference persistence, authorization, pagination",
      "submitted token text is parsed and executed by the host app"
    )
    expect(sample_app_results).to include(
      "Token and table metadata",
      "`rfk_token_search` representative token-entry lane checks",
      "## Token suggestion and Ransack suggestion metadata checks",
      "## Table metadata checks"
    )
  end

  it "keeps sample app results route guide packaged as a recording-lane selector" do
    expect(specification.files).to include("doc/sample_app_results_route_guide.md")
    expect(release_doc).to include(
      "[`sample_app_results_route_guide.md`](sample_app_results_route_guide.md)",
      "recording-lane selector",
      "does not add a release gate or turn CI success into browser visual approval"
    )
    expect(product_profile).to include(
      "`doc/sample_app_results_route_guide.md`: recording-lane selector for release-wide sample-app evidence, narrow PR comments, source-only visual reviews, and deferred browser-capable evidence"
    )
    expect(sample_app_results_route_guide).to include(
      "it does not add a release gate, change runtime behavior, or replace the full checklist",
      "CI success as visual approval",
      "`SOURCE REVIEW ONLY`",
      "`DEFERRED`",
      "Do not use `PASS` for GitHub Actions success, source review, static diff review, or a successful package build"
    )
  end

  it "keeps request failure duplicate field id evidence packaged and scoped" do
    expect(specification.files).to include("doc/tom_select_request_failure_visual_reference.html")
    expect(visual_references).to include(
      "[`tom_select_request_failure_visual_reference.html`](tom_select_request_failure_visual_reference.html)",
      "For duplicate object/method `error_surface: true` review",
      "duplicate field id boundary lane",
      "repeated-field id ownership",
      "`aria-describedby`",
      "request-failure event targeting"
    )
    expect(tom_select_request_failure_visual_reference).to include(
      "Duplicate field id boundary",
      "same object and method appear more than once on a page",
      "same object/method needs explicit ids",
      "error_surface: true",
      "aria-describedby",
      "detail.surface",
      "message, reveal timing, retry action"
    )
  end

  it "keeps Tom Select no-event boundary evidence packaged and scoped" do
    expect(specification.files).to include("doc/tom_select_no_event_boundary_review.html")
    expect(visual_references).to include(
      "[`tom_select_no_event_boundary_review.html`](tom_select_no_event_boundary_review.html)",
      "Map-only companion lane for stale / aborted request no-event states beside current request failure"
    )
    expect(tom_select_no_event_boundary).to include(
      "Stale or aborted request is ignored",
      "Suppressed, not failed",
      "No success or failure event is dispatched",
      "No request-start or request-finish event proposal",
      "No built-in retry, cancellation banner, toast, or fallback UI"
    )
  end

  it "keeps dropdown parent release evidence packaged and scoped" do
    expect(specification.files).to include("doc/dropdown_parent_release_evidence.md")
    expect(dropdown_parent_release_evidence).to include(
      "Selector pass-through",
      "No-config boundary",
      "dropdown_parent: \"body\"",
      "data-rails-fields-kit--tom-select-dropdown-parent-value",
      "dropdownParent: \"body\"",
      "Do not use this lane as proof of browser positioning, modal layout, portal implementation, z-index policy, or production CSS"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
