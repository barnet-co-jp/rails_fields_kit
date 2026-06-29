# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "focused table metadata docs inventory" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:table_adapters) { read_doc("doc/table_adapters.md") }
  let(:table_check_box_metadata) { read_doc("doc/table_check_box_metadata.md") }
  let(:table_range_field_metadata) { read_doc("doc/table_range_field_metadata.md") }

  it "keeps check_box and range metadata docs packaged and reachable from table adapters" do
    expect(specification.files).to include(
      "doc/table_check_box_metadata.md",
      "doc/table_range_field_metadata.md"
    )

    expect(table_adapters).to include(
      "[`table_check_box_metadata.md`](table_check_box_metadata.md)",
      "without adding boolean query semantics, tri-state filtering, bulk edit, table persistence, or production styling",
      "[`table_range_field_metadata.md`](table_range_field_metadata.md)",
      "without adding range-pair query semantics, custom sliders, table persistence, or production styling"
    )
  end

  it "keeps check_box metadata scoped to renderer mapping and host-owned table behavior" do
    expect(table_check_box_metadata).to include(
      "`TableFilterInput.check_box` and `TableCellInput.check_box`",
      "rfk_check_box",
      "the metadata factory type, `check_box`",
      "pass-through of `checked_value:`, `unchecked_value:`, and ordinary wrapper options",
      "boolean query semantics or table persistence behavior",
      "tri-state filtering or indeterminate-state UI",
      "bulk edit behavior and persistence",
      "authorization and table execution policy"
    )
  end

  it "keeps range metadata scoped to native options and host-owned range behavior" do
    expect(table_range_field_metadata).to include(
      "`rfk_range_field` is part of the native wrapper helper family",
      "`RailsFieldsKit::TableFilterInput.range_field(...)`",
      "`RailsFieldsKit::TableCellInput.range_field(...)`",
      "min: 1",
      "max: 10",
      "step: 1",
      "`TableRenderer` maps `range_field` to `rfk_range_field`",
      "range-pair query semantics",
      "custom slider UI",
      "table preference persistence",
      "Ransack execution",
      "production styling"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
