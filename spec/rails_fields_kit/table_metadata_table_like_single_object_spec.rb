# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableMetadata do
  SingleObjectColumn = Struct.new(:filter, :editor, keyword_init: true)
  SingleObjectTable = Struct.new(:columns, keyword_init: true)

  it "collects filter metadata from a table-like object with a single object column" do
    column = SingleObjectColumn.new(
      filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
    )
    table = SingleObjectTable.new(columns: column)

    expect(column.to_a.length).to eq(2)
    expect(described_class.filters(table)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "collects cell editor metadata from a table-like object with a single object column" do
    column = SingleObjectColumn.new(
      editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
    )
    table = SingleObjectTable.new(columns: column)

    expect(column.to_a.length).to eq(2)
    expect(described_class.cell_editors(table)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "enum_select",
        method: "status",
        options: {}
      }
    ])
  end
end