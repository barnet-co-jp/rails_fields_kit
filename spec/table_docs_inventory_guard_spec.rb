# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "table docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:table_adapters) { read_doc("doc/table_adapters.md") }
  let(:table_group_html) { read_doc("doc/table_group_html.md") }
  let(:table_direct_helper_boundary) { read_doc("doc/table_direct_helper_boundary.md") }
  let(:table_range_field_metadata) { read_doc("doc/table_range_field_metadata.md") }
  let(:table_file_field_metadata) { read_doc("doc/table_file_field_metadata.md") }

  it "keeps the table group_html focused doc packaged and routed without promoting semantic group ownership" do
    expect(specification.files).to include("doc/table_group_html.md")

    expect(public_api).to include(
      "[`table_group_html.md`](table_group_html.md)",
      "`group_html:` is separate from field-level `wrapper_html:`",
      "semantic `fieldset` / `legend` generation"
    )
    expect(readme).to include(
      "[`doc/table_group_html.md`](doc/table_group_html.md)",
      "optional single outer `group_html:` wrapper"
    )
    expect(table_group_html).to include(
      "`group_html:`",
      "single wrapper around the joined table helper output",
      "The outer element stays a Rails Fields Kit-owned `<div>` attribute pass-through",
      "Semantic wrappers such as `fieldset` and `legend` belong to the host app",
      "group-level `aria-describedby` wiring"
    )
  end

  it "keeps the direct table helper boundary doc packaged and routed without promoting batch layout options" do
    expect(specification.files).to include("doc/table_direct_helper_boundary.md")

    expect(table_adapters).to include(
      "[`table_direct_helper_boundary.md`](table_direct_helper_boundary.md)",
      "direct FormBuilder helpers",
      "lower-level render/call-spec lanes"
    )
    expect(readme).to include(
      "[`doc/table_direct_helper_boundary.md`](doc/table_direct_helper_boundary.md)",
      "direct FormBuilder safe-join boundary"
    )
    expect(table_direct_helper_boundary).to include(
      "`rfk_table_filters(columns, group_html: nil)`",
      "safe_join` the rendered pieces into normal view output",
      "lower-level array-returning lane",
      "`wrapper_html:`, `item_html:`, or `empty:`",
      "introduced as separate public API decisions",
      "query execution, table preference persistence, authorization, and user-visible success or error copy"
    )
  end

  it "keeps range field table metadata docs packaged and routed without promoting range query behavior" do
    expect(specification.files).to include("doc/table_range_field_metadata.md")

    expect(public_api).to include(
      "[`table_range_field_metadata.md`](table_range_field_metadata.md)",
      "range metadata"
    )
    expect(table_adapters).to include(
      "[`table_range_field_metadata.md`](table_range_field_metadata.md)",
      "`TableFilterInput.range_field`",
      "`TableCellInput.range_field`",
      "range-pair query semantics",
      "custom sliders",
      "table persistence"
    )
    expect(table_range_field_metadata).to include(
      "RailsFieldsKit::TableFilterInput.range_field",
      "RailsFieldsKit::TableCellInput.range_field",
      "min: 1",
      "max: 10",
      "step: 1",
      "`TableRenderer` maps `range_field` to `rfk_range_field`",
      "range-pair query semantics",
      "multi-thumb sliders",
      "custom slider UI",
      "table preference persistence"
    )
  end

  it "keeps file field table metadata docs packaged and routed as cell-editor-only" do
    expect(specification.files).to include("doc/table_file_field_metadata.md")

    expect(public_api).to include(
      "[`table_file_field_metadata.md`](table_file_field_metadata.md)",
      "file cell-editor metadata"
    )
    expect(table_adapters).to include(
      "[`table_file_field_metadata.md`](table_file_field_metadata.md)",
      "`TableCellInput.file_field` cell-editor-only",
      "upload execution",
      "query semantics",
      "table persistence"
    )
    expect(table_file_field_metadata).to include(
      "RailsFieldsKit::TableCellInput.file_field",
      "TableFilterInput.file_field` is not a built-in factory",
      "`TableRenderer` maps `file_field` metadata to `rfk_file_field`",
      "upload execution and persistence in the host application",
      "multipart form setup",
      "Active Storage direct upload JavaScript",
      "preview UI",
      "table persistence",
      "query execution",
      "authorization"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
