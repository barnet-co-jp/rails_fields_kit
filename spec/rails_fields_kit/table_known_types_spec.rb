# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table known field types" do
  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "returns duplicated known filter field types" do
    known_types = RailsFieldsKit::TableFilterInput.known_types
    known_types.clear

    expect(RailsFieldsKit::TableFilterInput.known_types).to include(:combobox, :token_search)
    expect(RailsFieldsKit::TableFilterInput.known_type?(:combobox)).to be(true)
  end

  it "returns duplicated known cell editor field types" do
    known_types = RailsFieldsKit::TableCellInput.known_types
    known_types.clear

    expect(RailsFieldsKit::TableCellInput.known_types).to include(:combobox, :token_search)
    expect(RailsFieldsKit::TableCellInput.known_type?(:combobox)).to be(true)
  end

  it "keeps custom registered field types out of filter known types" do
    RailsFieldsKit::TableRenderer.register_field_helper(:custom_field, :custom_table_field)

    expect(RailsFieldsKit::TableFilterInput.known_type?(:custom_field)).to be(false)
    expect(RailsFieldsKit::TableFilterInput.known_types).not_to include(:custom_field)
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:custom_field)).to be(true)
  end

  it "keeps custom registered field types out of cell editor known types" do
    RailsFieldsKit::TableRenderer.register_field_helper(:custom_field, :custom_table_field)

    expect(RailsFieldsKit::TableCellInput.known_type?(:custom_field)).to be(false)
    expect(RailsFieldsKit::TableCellInput.known_types).not_to include(:custom_field)
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:custom_field)).to be(true)
  end

  it "allows metadata objects to carry custom field types before renderer validation" do
    filter = RailsFieldsKit::TableFilterInput.from_type(:custom_field, :code, prefix: "#")
    editor = RailsFieldsKit::TableCellInput.from_type(:custom_field, :code, prefix: "#")

    expect(filter.to_table_filter).to include(field_type: "custom_field", method: "code")
    expect(editor.to_table_cell_editor).to include(field_type: "custom_field", method: "code")
  end

  it "uses the renderer registry to validate custom metadata renderability" do
    RailsFieldsKit::TableRenderer.register_field_helper(:custom_field, :custom_table_field)

    filter = RailsFieldsKit::TableFilterInput.from_type(:custom_field, :code, prefix: "#")
    editor = RailsFieldsKit::TableCellInput.from_type(:custom_field, :code, prefix: "#")

    expect(RailsFieldsKit::TableRenderer.filter_call(filter)).to eq(
      helper: :custom_table_field,
      method: :code,
      options: {prefix: "#"}
    )
    expect(RailsFieldsKit::TableRenderer.cell_editor_call(editor)).to eq(
      helper: :custom_table_field,
      method: :code,
      options: {prefix: "#"}
    )
  end
end
