# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  class FakeTableFormBuilder
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

  it "builds a filter call spec from filter metadata objects" do
    filter = RailsFieldsKit::TableFilterInput.new(
      :combobox,
      :customer_id,
      url: "/customers.json"
    )

    expect(described_class.filter_call(filter)).to eq(
      helper: :rfk_combobox,
      method: :customer_id,
      options: { url: "/customers.json" }
    )
  end

  it "builds a token search filter call spec" do
    filter = RailsFieldsKit::TableFilterInput.token_search(
      :query,
      url: "/search_tokens.json",
      placeholder: "status:open keyword"
    )

    expect(described_class.filter_call(filter)).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {
        url: "/search_tokens.json",
        placeholder: "status:open keyword"
      }
    )
  end

  it "builds a cell editor call spec" do
    editor = RailsFieldsKit::TableCellInput.new(:enum_select, :status)

    expect(described_class.cell_editor_call(editor)).to eq(
      helper: :rfk_enum_select,
      method: :status,
      options: {}
    )
  end

  it "renders filters through a form builder" do
    form_builder = FakeTableFormBuilder.new
    filter = RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json")

    expect(described_class.render_filter(form_builder, filter)).to eq("combobox")
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, { url: "/customers.json" }]
    ])
  end

  it "renders cell editors through a form builder" do
    form_builder = FakeTableFormBuilder.new
    editor = RailsFieldsKit::TableCellInput.new(:enum_select, :status)

    expect(described_class.render_cell_editor(form_builder, editor)).to eq("enum_select")
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}]
    ])
  end

  it "raises for unknown field types" do
    metadata = { field_type: "unknown", method: "query", options: {} }

    expect { described_class.filter_call(metadata) }.to raise_error(
      RailsFieldsKit::TableRenderer::UnknownFieldType,
      "unknown Rails Fields Kit table field type: unknown"
    )
  end

  it "raises when rendering metadata without a method" do
    form_builder = FakeTableFormBuilder.new
    metadata = { field_type: "combobox", options: {} }

    expect { described_class.render_filter(form_builder, metadata) }.to raise_error(
      ArgumentError,
      "table metadata method is required"
    )
  end
end