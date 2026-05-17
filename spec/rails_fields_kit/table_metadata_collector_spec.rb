# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableMetadata do
  ColumnDefinition = Struct.new(:filter, :editor, keyword_init: true)

  it "collects filter metadata from hash columns" do
    columns = [
      {
        key: :customer_id,
        filter: RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json")
      },
      { key: :status, filter: nil },
      { key: :name, filter: false }
    ]

    expect(described_class.filters(columns)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "combobox",
        method: "customer_id",
        options: { url: "/customers.json" }
      }
    ])
  end

  it "collects filter metadata from object columns" do
    columns = [
      ColumnDefinition.new(filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")),
      ColumnDefinition.new(filter: nil)
    ]

    expect(described_class.filters(columns)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "collects cell editor metadata" do
    columns = [
      {
        key: :status,
        editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
      },
      ColumnDefinition.new(editor: RailsFieldsKit::TableCellInput.new(:combobox, :customer_id, url: "/customers.json"))
    ]

    expect(described_class.cell_editors(columns)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "enum_select",
        method: "status",
        options: {}
      },
      {
        type: "rails_fields_kit",
        field_type: "combobox",
        method: "customer_id",
        options: { url: "/customers.json" }
      }
    ])
  end

  it "keeps raw metadata hashes" do
    metadata = {
      type: "rails_fields_kit",
      field_type: "search_field",
      method: "keyword",
      options: { placeholder: "Search" }
    }
    columns = [{ filter: metadata }]

    expect(described_class.filters(columns)).to eq([metadata])
  end

  it "builds filter call specs from collected metadata" do
    columns = [
      {
        filter: RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json")
      },
      { filter: nil },
      {
        filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
      }
    ]

    expect(described_class.filter_calls(columns)).to eq([
      {
        helper: :rfk_combobox,
        method: :customer_id,
        options: { url: "/customers.json" }
      },
      {
        helper: :rfk_token_search,
        method: :query,
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "builds cell editor call specs from collected metadata" do
    columns = [
      {
        editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
      },
      { editor: nil }
    ]

    expect(described_class.cell_editor_calls(columns)).to eq([
      {
        helper: :rfk_enum_select,
        method: :status,
        options: {}
      }
    ])
  end
end