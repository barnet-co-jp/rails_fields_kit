# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "focused docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:roadmap) { read_doc("ROADMAP.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:field_helpers) { read_doc("doc/field_helpers.md") }
  let(:table_adapters) { read_doc("doc/table_adapters.md") }
  let(:table_file_field_metadata) { read_doc("doc/table_file_field_metadata.md") }
  let(:table_range_field_metadata) { read_doc("doc/table_range_field_metadata.md") }
  let(:table_check_box_metadata) { read_doc("doc/table_check_box_metadata.md") }
  let(:datalist_boundary) { read_doc("doc/datalist_boundary.md") }
  let(:native_numeric_fields) { read_doc("doc/native_numeric_fields.md") }
  let(:native_contact_fields) { read_doc("doc/native_contact_fields.md") }
  let(:visual_reference_browser_evidence) { read_doc("doc/visual_reference_browser_evidence.md") }
  let(:sample_app_results_route_guide) { read_doc("doc/sample_app_results_route_guide.md") }
  let(:dropdown_parent_release_evidence) { read_doc("doc/dropdown_parent_release_evidence.md") }
  let(:token_table_sample_app_evidence) { read_doc("doc/token_table_sample_app_evidence.md") }
  let(:search_controller_release_evidence) { read_doc("doc/search_controller_release_evidence.md") }
  let(:radio_button_release_evidence) { read_doc("doc/radio_button_release_evidence.md") }

  it "keeps table file field metadata packaged and routed without promoting upload ownership" do
    expect(specification.files).to include("doc/table_file_field_metadata.md")
    expect(public_api).to include(
      "[`table_file_field_metadata.md`](table_file_field_metadata.md)",
      "file cell-editor metadata",
      "file upload execution"
    )
    expect(table_file_field_metadata).to include(
      "RailsFieldsKit::TableCellInput.file_field",
      "TableRenderer` maps `file_field` metadata to `rfk_file_field`",
      "cell-editor-only",
      "`TableFilterInput.file_field` is not a built-in factory",
      "The host application owns multipart form setup, Active Storage direct upload JavaScript, preview UI, upload progress UI, file validation policy, storage configuration, virus scanning, table persistence, query execution, authorization, and production CSS"
    )
  end

  it "keeps focused range and checkbox table metadata docs packaged without promoting table semantics" do
    expect(specification.files).to include(
      "doc/table_range_field_metadata.md",
      "doc/table_check_box_metadata.md"
    )

    expect(public_api).to include(
      "[`table_range_field_metadata.md`](table_range_field_metadata.md)",
      "[`table_check_box_metadata.md`](table_check_box_metadata.md)",
      "range-pair query semantics",
      "boolean query policy",
      "table persistence",
      "production styling"
    )

    expect(table_adapters).to include(
      "[`table_range_field_metadata.md`](table_range_field_metadata.md)",
      "TableFilterInput.range_field",
      "TableCellInput.range_field",
      "min`, `max`, and `step",
      "without adding range-pair query semantics, custom sliders, table persistence, or production styling",
      "[`table_check_box_metadata.md`](table_check_box_metadata.md)",
      "TableFilterInput.check_box",
      "TableCellInput.check_box",
      "without adding boolean query semantics, tri-state filtering, bulk edit, table persistence, or production styling"
    )

    expect(table_range_field_metadata).to include(
      "RailsFieldsKit::TableFilterInput.range_field",
      "RailsFieldsKit::TableCellInput.range_field",
      "TableRenderer` maps `range_field` to `rfk_range_field`",
      "Treat `min`, `max`, and `step` as ordinary native input options",
      "Rails Fields Kit does not add range-pair query semantics, multi-thumb sliders, custom slider UI, table preference persistence, Ransack execution, or production styling"
    )

    expect(table_check_box_metadata).to include(
      "TableFilterInput.check_box",
      "TableCellInput.check_box",
      "TableRenderer` dispatches this field type to `rfk_check_box`",
      "pass-through of `checked_value:`, `unchecked_value:`, and ordinary wrapper options",
      "interpreting submitted checked and unchecked values",
      "query construction, including Ransack predicates",
      "tri-state filtering or indeterminate-state UI",
      "bulk edit behavior and persistence",
      "authorization and table execution policy"
    )
  end

  it "keeps datalist proposal boundary docs packaged without promoting a current helper" do
    form_builder_helpers = markdown_section(public_api, "## FormBuilder helpers")

    expect(specification.files).to include("doc/datalist_boundary.md")
    expect(readme).to include(
      "[`doc/datalist_boundary.md`](doc/datalist_boundary.md)",
      "Rails Fields Kit does not currently provide `rfk_masked_field`, `rfk_slug_field`, or `rfk_datalist_field`"
    )
    expect(roadmap).to include(
      "[`doc/datalist_boundary.md`](doc/datalist_boundary.md)",
      "current proposal boundary for HTML datalist support",
      "keeps `rfk_datalist_field` out of the current public API"
    )
    expect(field_helpers).to include(
      "[`datalist_boundary.md`](datalist_boundary.md)",
      "`rfk_text_field list:` plus host-owned `<datalist>` markup",
      "separate from Tom Select-backed autocomplete or combobox workflows",
      "Keep `rfk_datalist_field`, `rfk_slug_field`, and `rfk_masked_field`"
    )
    expect(datalist_boundary).to include(
      "This document records the proposal boundary for HTML `datalist` support",
      "It does not add `rfk_datalist_field` to the current public API",
      "`rfk_text_field list:` plus host-owned `<datalist>` markup",
      "Do not add `rfk_datalist_field` to `doc/public_api.md`"
    )
    expect(form_builder_helpers).not_to include("rfk_datalist_field")
  end

  it "keeps native numeric and contact focused docs packaged without promoting host-app-owned behavior" do
    form_builder_helpers = markdown_section(public_api, "## FormBuilder helpers")

    expect(specification.files).to include("doc/native_numeric_fields.md", "doc/native_contact_fields.md")
    expect(readme).to include(
      "[`doc/native_numeric_fields.md`](doc/native_numeric_fields.md)",
      "[`doc/native_contact_fields.md`](doc/native_contact_fields.md)"
    )
    expect(public_api).to include(
      "[`native_numeric_fields.md`](native_numeric_fields.md)",
      "[`native_contact_fields.md`](native_contact_fields.md)"
    )
    expect(field_helpers).to include(
      "[`native_numeric_fields.md`](native_numeric_fields.md)",
      "[`native_contact_fields.md`](native_contact_fields.md)",
      "formatting, rounding, normalization, validation wording, and phone policy with the host app"
    )
    expect(form_builder_helpers).to include(
      "`rfk_number_field`",
      "`rfk_money_field`",
      "`rfk_percent_field`",
      "`rfk_email_field`",
      "`rfk_url_field`",
      "`rfk_phone_field`",
      "`rfk_search_field`"
    )
    expect(native_numeric_fields).to include(
      "`rfk_number_field`, `rfk_money_field`, and `rfk_percent_field`",
      "delegates to Rails' native `number_field` helper",
      "delegates to Rails' native `text_field` helper, defaults `inputmode` to `decimal`, and uses `currency:` as the prefix when provided",
      "generated label, hint, validation error, prefix, and suffix output",
      "aria-describedby`, `aria-invalid`, and `aria-required` wiring",
      "The host app remains responsible for number formatting, locale-specific separators, rounding, currency conversion, currency display policy, decimal precision, browser validation-message wording, server-side validation, and persistence"
    )
    expect(native_contact_fields).to include(
      "`rfk_email_field`, `rfk_url_field`, `rfk_phone_field`, and `rfk_search_field`",
      "delegates to Rails' native `email_field` helper",
      "delegates to Rails' native `url_field` helper",
      "delegates to Rails' native `telephone_field` helper and defaults `autocomplete` to `tel`",
      "delegates to Rails' native `search_field` helper",
      "generated label, hint, validation error, prefix, and suffix output",
      "The host app remains responsible for browser-native validation-message wording, email deliverability checks, URL normalization, phone-number formatting, country-specific phone policy, search execution, autocomplete policy, server-side validation, and persistence"
    )
  end

  it "keeps browser evidence runbook packaged without turning source review or CI into visual approval" do
    expect(specification.files).to include("doc/visual_reference_browser_evidence.md")
    expect(readme).to include(
      "[`doc/visual_reference_browser_evidence.md`](doc/visual_reference_browser_evidence.md)",
      "manual desktop/narrow browser-capable evidence beyond CI or source review"
    )
    expect(sample_app_results_route_guide).to include(
      "Source-only or connector-only visual review",
      "source review / browser pass / CI / docs link review",
      "Do not use `PASS` for GitHub Actions success, source review, static diff review, or a successful package build"
    )
    expect(visual_reference_browser_evidence).to include(
      "manual reviewer aid, not CI automation, screenshot approval, or a merge bot",
      "Desktop: about `1280x900`",
      "Narrow: about `390x844`",
      "CI success and source review are useful context, but they are not browser visual approval",
      "Do not mark a visual reference as browser-approved unless the desktop and narrow browser review actually ran"
    )
  end

  it "keeps release evidence guides packaged without expanding sample app ownership" do
    expect(specification.files).to include(
      "doc/dropdown_parent_release_evidence.md",
      "doc/token_table_sample_app_evidence.md",
      "doc/search_controller_release_evidence.md",
      "doc/radio_button_release_evidence.md"
    )

    expect(dropdown_parent_release_evidence).to include(
      "selector pass-through and no-config behavior",
      "Render a Tom Select-backed helper with `dropdown_parent: \"body\"`",
      "confirm `dropdownParent` is absent from Tom Select options",
      "Do not use this lane as proof of browser positioning, modal layout, portal implementation, z-index policy, or production CSS"
    )

    expect(token_table_sample_app_evidence).to include(
      "Use this guide when a release or focused PR needs sample app evidence for token search, token suggestions, Ransack suggestion metadata, or table metadata rendering",
      "Use `doc/sample_app_checklist.md` to choose whether evidence belongs in a release result file or a narrow PR comment",
      "Use `doc/sample_app_results.md` only as the release evidence log, not as a source of new behavior",
      "submitted token text is parsed and executed by the host app",
      "query execution, preference persistence, authorization, pagination, visible save/error copy, and final table layout remain host-app or table integration responsibilities"
    )

    expect(search_controller_release_evidence).to include(
      "representative evidence for `rfk_search_with` endpoint-side policy, especially `minimum_query_length:` or `match:`",
      "FormBuilder `min_length:` remains a browser-side loading hint",
      "`match: :prefix` confirms prefix-only suggestions",
      "The evidence should not standardize adapter-specific SQL, case sensitivity, token parsing, search ranking, pagination, authorization, or query execution"
    )

    expect(radio_button_release_evidence).to include(
      "representative sample-app evidence for `rfk_radio_button`",
      "single-control native wrapper around Rails' standard `radio_button` helper",
      "the helper call, including the method and `tag_value`",
      "same-name grouping behavior remains Rails standard radio behavior",
      "collection iteration, fieldset / legend markup, group-level validation UI, and layout policy stay in the host app",
      "production CSS, final spacing, and browser-specific visual approval stay outside this guide"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
