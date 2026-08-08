# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "table metadata focused docs inventory" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:table_adapters) { read_doc("doc/table_adapters.md") }
  let(:direct_helper_boundary) { read_doc("doc/table_direct_helper_boundary.md") }
  let(:range_metadata) { read_doc("doc/table_range_field_metadata.md") }
  let(:checkbox_metadata) { read_doc("doc/table_check_box_metadata.md") }
  let(:radio_metadata) { read_doc("doc/table_radio_button_metadata.md") }
  let(:file_metadata) { read_doc("doc/table_file_field_metadata.md") }

  it "keeps the direct helper boundary doc packaged and routed from table metadata docs" do
    expect(specification.files).to include("doc/table_direct_helper_boundary.md")
    expect(table_adapters).to include(
      "[`table_direct_helper_boundary.md`](table_direct_helper_boundary.md)",
      "direct FormBuilder helpers and lower-level render/call-spec lanes"
    )
    expect(public_api).to include(
      "`rfk_table_filters` and `rfk_table_cell_editors` are the direct FormBuilder rendering path",
      "`TableMetadata.filter_calls` / `cell_editor_calls` and `TableRenderer.filter_call` / `cell_editor_call` are the call-spec path"
    )
    expect(direct_helper_boundary).to include(
      "safe_join",
      "single Rails Fields Kit-owned outer `<div>`",
      "does not make Rails Fields Kit own semantic `fieldset` / `legend` generation",
      "host application or table integration owns page layout, empty states, semantic grouping, query execution, table preference persistence, authorization, and user-visible success or error copy"
    )
  end

  it "keeps native table metadata focused docs packaged and routed from table metadata docs" do
    expect(specification.files).to include(
      "doc/table_range_field_metadata.md",
      "doc/table_check_box_metadata.md",
      "doc/table_radio_button_metadata.md",
      "doc/table_file_field_metadata.md"
    )
    expect(table_adapters).to include(
      "[`table_range_field_metadata.md`](table_range_field_metadata.md)",
      "[`table_check_box_metadata.md`](table_check_box_metadata.md)",
      "[`table_radio_button_metadata.md`](table_radio_button_metadata.md)",
      "[`table_file_field_metadata.md`](table_file_field_metadata.md)",
      "`TableFilterInput.radio_button`",
      "`TableCellInput.radio_button`",
      "required `tag_value:`",
      "same-name grouping",
      "range-pair query semantics",
      "tri-state filtering",
      "upload execution",
      "table persistence",
      "production styling"
    )
    expect(public_api).to include(
      "use [`table_range_field_metadata.md`](table_range_field_metadata.md) for range metadata",
      "[`table_check_box_metadata.md`](table_check_box_metadata.md) for checkbox metadata",
      "[`table_radio_button_metadata.md`](table_radio_button_metadata.md) for radio button filter and cell-editor metadata",
      "[`table_file_field_metadata.md`](table_file_field_metadata.md) for file cell-editor metadata",
      "These guides do not add range-pair query semantics, boolean query policy, radio group generation, file upload execution, table persistence, or production styling"
    )
  end

  it "keeps focused native table metadata boundaries representative instead of owning host behavior" do
    expect(range_metadata).to include(
      "RailsFieldsKit::TableFilterInput.range_field",
      "RailsFieldsKit::TableCellInput.range_field",
      "TableRenderer` maps `range_field` to `rfk_range_field`",
      "does not add range-pair query semantics, multi-thumb sliders, custom slider UI, table preference persistence, Ransack execution, or production styling"
    )
    expect(checkbox_metadata).to include(
      "TableFilterInput.check_box",
      "TableCellInput.check_box",
      "dispatches this field type to `rfk_check_box`",
      "tri-state filtering or indeterminate-state UI",
      "bulk edit behavior and persistence",
      "authorization and table execution policy"
    )
    expect(radio_metadata).to include(
      "TableFilterInput.radio_button",
      "TableCellInput.radio_button",
      "maps `radio_button` metadata to `rfk_radio_button`",
      "`tag_value:` is required",
      "filter factory is renderable control metadata only",
      "collection radio group helpers",
      "table query execution or persistence"
    )
    expect(file_metadata).to include(
      "RailsFieldsKit::TableCellInput.file_field",
      "cell-editor-only",
      "TableFilterInput.file_field` is not a built-in factory",
      "multipart form setup, Active Storage direct upload JavaScript, preview UI, upload progress UI, file validation policy, storage configuration, virus scanning, table persistence, query execution, authorization, and production CSS"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
