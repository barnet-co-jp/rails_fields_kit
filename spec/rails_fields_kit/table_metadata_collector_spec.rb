# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableMetadata do
  ColumnDefinition = Struct.new(:filter, :editor, keyword_init: true)
  AliasColumnDefinition = Struct.new(:filter_input, :cell_editor, keyword_init: true)
  TableDefinition = Struct.new(:columns, keyword_init: true)

  class MetadataCollectorFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_combobox(method, **options)
      calls << [:rfk_combobox, method, options]
      "combobox"
    end

    def rfk_token_search(method, **options)
      calls << [:rfk_token_search, method, options]
      "token_search"
    end

    def rfk_enum_select(method, **options)
      calls << [:rfk_enum_select, method, options]
      "enum_select"
    end
  end

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

  it "treats nil columns as empty metadata" do
    expect(described_class.filters(nil)).to eq([])
    expect(described_class.cell_editors(nil)).to eq([])
  end

  it "treats table-like objects with nil columns as empty metadata" do
    table = TableDefinition.new(columns: nil)

    expect(described_class.filters(table)).to eq([])
    expect(described_class.cell_editors(table)).to eq([])
  end

  it "collects filter metadata from table-like objects" do
    table = TableDefinition.new(
      columns: [
        {
          key: :customer_id,
          filter: RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json")
        },
        {
          key: :query,
          search_filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
        }
      ]
    )

    expect(described_class.filters(table)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "combobox",
        method: "customer_id",
        options: { url: "/customers.json" }
      },
      {
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "collects filter metadata from hash alias keys" do
    columns = [
      {
        key: :customer_id,
        filter_input: RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json")
      },
      {
        key: :query,
        "search_filter" => RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
      }
    ]

    expect(described_class.filters(columns)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "combobox",
        method: "customer_id",
        options: { url: "/customers.json" }
      },
      {
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: { url: "/tokens.json" }
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

  it "collects filter metadata from object alias methods" do
    columns = [
      AliasColumnDefinition.new(filter_input: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json"))
    ]

    expect(columns.first.members).to include(:filter_input)
    expect(columns.first.members).not_to include(:filter)
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

  it "collects cell editor metadata from table-like objects" do
    table = TableDefinition.new(
      columns: [
        {
          key: :status,
          editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
        },
        {
          key: :customer_id,
          cell_editor: RailsFieldsKit::TableCellInput.new(:combobox, :customer_id, url: "/customers.json")
        }
      ]
    )

    expect(described_class.cell_editors(table)).to eq([
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

  it "collects cell editor metadata from alias keys and methods" do
    columns = [
      {
        key: :status,
        cell_input: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
      },
      AliasColumnDefinition.new(cell_editor: RailsFieldsKit::TableCellInput.new(:combobox, :customer_id, url: "/customers.json"))
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

  it "renders collected filters" do
    form_builder = MetadataCollectorFormBuilder.new
    columns = [
      { filter: RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json") },
      { filter: nil },
      { search_filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json") }
    ]

    expect(described_class.render_filters(form_builder, columns)).to eq(["combobox", "token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, { url: "/customers.json" }],
      [:rfk_token_search, :query, { url: "/tokens.json" }]
    ])
  end

  it "renders collected cell editors" do
    form_builder = MetadataCollectorFormBuilder.new
    columns = [
      { editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status) },
      { editor: nil },
      { cell_editor: RailsFieldsKit::TableCellInput.new(:combobox, :customer_id, url: "/customers.json") }
    ]

    expect(described_class.render_cell_editors(form_builder, columns)).to eq(["enum_select", "combobox"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}],
      [:rfk_combobox, :customer_id, { url: "/customers.json" }]
    ])
  end
end