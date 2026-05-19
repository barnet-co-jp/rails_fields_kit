# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableMetadata do
  SingleObjectColumn = Struct.new(:filter, :editor, keyword_init: true)
  SingleObjectTable = Struct.new(:columns, keyword_init: true)

  class SingleObjectFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
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

  it "collects filter metadata from a table-like object with a single hash column" do
    table = SingleObjectTable.new(
      columns: {
        filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
      }
    )

    expect(described_class.filters(table)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "builds filter call specs from a table-like object with a single hash column" do
    table = SingleObjectTable.new(
      columns: {
        filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
      }
    )

    expect(described_class.filter_calls(table)).to eq([
      {
        helper: :rfk_token_search,
        method: :query,
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "renders filters from a table-like object with a single hash column" do
    form_builder = SingleObjectFormBuilder.new
    table = SingleObjectTable.new(
      columns: {
        filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
      }
    )

    expect(described_class.render_filters(form_builder, table)).to eq(["token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_token_search, :query, { url: "/tokens.json" }]
    ])
  end

  it "collects cell editor metadata from a table-like object with a single hash column" do
    table = SingleObjectTable.new(
      columns: {
        editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
      }
    )

    expect(described_class.cell_editors(table)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "enum_select",
        method: "status",
        options: {}
      }
    ])
  end

  it "builds cell editor call specs from a table-like object with a single hash column" do
    table = SingleObjectTable.new(
      columns: {
        editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
      }
    )

    expect(described_class.cell_editor_calls(table)).to eq([
      {
        helper: :rfk_enum_select,
        method: :status,
        options: {}
      }
    ])
  end

  it "renders cell editors from a table-like object with a single hash column" do
    form_builder = SingleObjectFormBuilder.new
    table = SingleObjectTable.new(
      columns: {
        editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
      }
    )

    expect(described_class.render_cell_editors(form_builder, table)).to eq(["enum_select"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}]
    ])
  end

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

  it "builds filter call specs from a table-like object with a single object column" do
    column = SingleObjectColumn.new(
      filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
    )
    table = SingleObjectTable.new(columns: column)

    expect(described_class.filter_calls(table)).to eq([
      {
        helper: :rfk_token_search,
        method: :query,
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "renders filters from a table-like object with a single object column" do
    form_builder = SingleObjectFormBuilder.new
    column = SingleObjectColumn.new(
      filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
    )
    table = SingleObjectTable.new(columns: column)

    expect(described_class.render_filters(form_builder, table)).to eq(["token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_token_search, :query, { url: "/tokens.json" }]
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

  it "builds cell editor call specs from a table-like object with a single object column" do
    column = SingleObjectColumn.new(
      editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
    )
    table = SingleObjectTable.new(columns: column)

    expect(described_class.cell_editor_calls(table)).to eq([
      {
        helper: :rfk_enum_select,
        method: :status,
        options: {}
      }
    ])
  end

  it "renders cell editors from a table-like object with a single object column" do
    form_builder = SingleObjectFormBuilder.new
    column = SingleObjectColumn.new(
      editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
    )
    table = SingleObjectTable.new(columns: column)

    expect(described_class.render_cell_editors(form_builder, table)).to eq(["enum_select"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}]
    ])
  end
end