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

    def custom_table_field(method, **options)
      calls << [:custom_table_field, method, options]
      "custom"
    end
  end

  class HashLikeOptions
    def to_hash
      { url: "/customers.json" }
    end
  end

  class HashLikeRendererMetadata
    def initialize(metadata)
      @metadata = metadata
    end

    def to_hash
      @metadata
    end
  end

  around do |example|
    described_class.reset_field_helpers!
    example.run
    described_class.reset_field_helpers!
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

  it "builds a filter call spec from hash-like metadata" do
    metadata = HashLikeRendererMetadata.new(
      field_type: "combobox",
      method: "customer_id",
      options: { url: "/customers.json" }
    )

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_combobox,
      method: :customer_id,
      options: { url: "/customers.json" }
    )
  end

  it "rejects invalid hash-like filter metadata" do
    metadata = HashLikeRendererMetadata.new([[:field_type, "combobox"]])

    expect { described_class.filter_call(metadata) }.to raise_error(
      ArgumentError,
      "table metadata to_hash must return a hash"
    )
  end

  it "rejects non-hash filter metadata" do
    expect { described_class.filter_call(Object.new) }.to raise_error(
      ArgumentError,
      "table metadata must be a hash"
    )
  end

  it "builds filter call specs in batches" do
    filters = [
      RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json"),
      nil,
      RailsFieldsKit::TableFilterInput.token_search(:query, url: "/search_tokens.json")
    ]

    expect(described_class.filter_calls(filters)).to eq([
      {
        helper: :rfk_combobox,
        method: :customer_id,
        options: { url: "/customers.json" }
      },
      {
        helper: :rfk_token_search,
        method: :query,
        options: { url: "/search_tokens.json" }
      }
    ])
  end

  it "builds a single filter call spec from one hash in batch APIs" do
    metadata = { field_type: "combobox", method: "customer_id", options: { url: "/customers.json" } }

    expect(described_class.filter_calls(metadata)).to eq([
      {
        helper: :rfk_combobox,
        method: :customer_id,
        options: { url: "/customers.json" }
      }
    ])
  end

  it "builds filter call specs from enumerable batch inputs" do
    filters = [
      { field_type: "combobox", method: "customer_id", options: { url: "/customers.json" } },
      nil,
      RailsFieldsKit::TableFilterInput.token_search(:query, url: "/search_tokens.json")
    ].each

    expect(described_class.filter_calls(filters)).to eq([
      {
        helper: :rfk_combobox,
        method: :customer_id,
        options: { url: "/customers.json" }
      },
      {
        helper: :rfk_token_search,
        method: :query,
        options: { url: "/search_tokens.json" }
      }
    ])
  end

  it "normalizes metadata method names" do
    metadata = { field_type: "combobox", method: " customer_id ", options: { url: "/customers.json" } }

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_combobox,
      method: :customer_id,
      options: { url: "/customers.json" }
    )
  end

  it "normalizes metadata options" do
    metadata = { field_type: "combobox", method: :customer_id, options: HashLikeOptions.new }

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_combobox,
      method: :customer_id,
      options: { url: "/customers.json" }
    )
  end

  it "defaults missing metadata options to an empty hash" do
    metadata = { field_type: "combobox", method: :customer_id }

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_combobox,
      method: :customer_id,
      options: {}
    )
  end

  it "duplicates metadata options" do
    options = { url: "/customers.json" }
    call = described_class.filter_call(field_type: "combobox", method: :customer_id, options: options)
    call.fetch(:options).clear

    expect(options).to eq(url: "/customers.json")
  end

  it "rejects non-hash metadata options" do
    metadata = { field_type: "combobox", method: :customer_id, options: [[:url, "/customers.json"]] }

    expect { described_class.filter_call(metadata) }.to raise_error(
      ArgumentError,
      "table metadata options must be a hash"
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

  it "builds a cell editor call spec from hash-like metadata" do
    metadata = HashLikeRendererMetadata.new(
      field_type: "enum_select",
      method: "status",
      options: {}
    )

    expect(described_class.cell_editor_call(metadata)).to eq(
      helper: :rfk_enum_select,
      method: :status,
      options: {}
    )
  end

  it "rejects invalid hash-like cell editor metadata" do
    metadata = HashLikeRendererMetadata.new([[:field_type, "enum_select"]])

    expect { described_class.cell_editor_call(metadata) }.to raise_error(
      ArgumentError,
      "table metadata to_hash must return a hash"
    )
  end

  it "rejects non-hash cell editor metadata" do
    expect { described_class.cell_editor_call(Object.new) }.to raise_error(
      ArgumentError,
      "table metadata must be a hash"
    )
  end

  it "builds cell editor call specs in batches" do
    editors = [
      RailsFieldsKit::TableCellInput.new(:enum_select, :status),
      nil,
      RailsFieldsKit::TableCellInput.new(:combobox, :customer_id, url: "/customers.json")
    ]

    expect(described_class.cell_editor_calls(editors)).to eq([
      {
        helper: :rfk_enum_select,
        method: :status,
        options: {}
      },
      {
        helper: :rfk_combobox,
        method: :customer_id,
        options: { url: "/customers.json" }
      }
    ])
  end

  it "builds a single cell editor call spec from one hash in batch APIs" do
    metadata = { field_type: "enum_select", method: "status", options: {} }

    expect(described_class.cell_editor_calls(metadata)).to eq([
      {
        helper: :rfk_enum_select,
        method: :status,
        options: {}
      }
    ])
  end

  it "builds cell editor call specs from enumerable batch inputs" do
    editors = [
      { field_type: "enum_select", method: "status", options: {} },
      nil,
      RailsFieldsKit::TableCellInput.new(:combobox, :customer_id, url: "/customers.json")
    ].each

    expect(described_class.cell_editor_calls(editors)).to eq([
      {
        helper: :rfk_enum_select,
        method: :status,
        options: {}
      },
      {
        helper: :rfk_combobox,
        method: :customer_id,
        options: { url: "/customers.json" }
      }
    ])
  end

  it "renders filters through a form builder" do
    form_builder = FakeTableFormBuilder.new
    filter = RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json")

    expect(described_class.render_filter(form_builder, filter)).to eq("combobox")
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, { url: "/customers.json" }]
    ])
  end

  it "renders filters in batches" do
    form_builder = FakeTableFormBuilder.new
    filters = [
      RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json"),
      nil,
      RailsFieldsKit::TableFilterInput.token_search(:query, url: "/search_tokens.json")
    ]

    expect(described_class.render_filters(form_builder, filters)).to eq(["combobox", "token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, { url: "/customers.json" }],
      [:rfk_token_search, :query, { url: "/search_tokens.json" }]
    ])
  end

  it "renders one filter from one hash in batch APIs" do
    form_builder = FakeTableFormBuilder.new
    metadata = { field_type: "combobox", method: "customer_id", options: { url: "/customers.json" } }

    expect(described_class.render_filters(form_builder, metadata)).to eq(["combobox"])
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, { url: "/customers.json" }]
    ])
  end

  it "renders filters from enumerable batch inputs" do
    form_builder = FakeTableFormBuilder.new
    filters = [
      { field_type: "combobox", method: "customer_id", options: { url: "/customers.json" } },
      nil,
      RailsFieldsKit::TableFilterInput.token_search(:query, url: "/search_tokens.json")
    ].each

    expect(described_class.render_filters(form_builder, filters)).to eq(["combobox", "token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, { url: "/customers.json" }],
      [:rfk_token_search, :query, { url: "/search_tokens.json" }]
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

  it "renders cell editors in batches" do
    form_builder = FakeTableFormBuilder.new
    editors = [
      RailsFieldsKit::TableCellInput.new(:enum_select, :status),
      nil,
      RailsFieldsKit::TableCellInput.new(:combobox, :customer_id, url: "/customers.json")
    ]

    expect(described_class.render_cell_editors(form_builder, editors)).to eq(["enum_select", "combobox"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}],
      [:rfk_combobox, :customer_id, { url: "/customers.json" }]
    ])
  end

  it "renders one cell editor from one hash in batch APIs" do
    form_builder = FakeTableFormBuilder.new
    metadata = { field_type: "enum_select", method: "status", options: {} }

    expect(described_class.render_cell_editors(form_builder, metadata)).to eq(["enum_select"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}]
    ])
  end

  it "renders cell editors from enumerable batch inputs" do
    form_builder = FakeTableFormBuilder.new
    editors = [
      { field_type: "enum_select", method: "status", options: {} },
      nil,
      RailsFieldsKit::TableCellInput.new(:combobox, :customer_id, url: "/customers.json")
    ].each

    expect(described_class.render_cell_editors(form_builder, editors)).to eq(["enum_select", "combobox"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}],
      [:rfk_combobox, :customer_id, { url: "/customers.json" }]
    ])
  end

  it "exposes registered helper mappings" do
    expect(described_class.helper_for(:combobox)).to eq(:rfk_combobox)
    expect(described_class.helper_for(:grouped_select)).to eq(:rfk_grouped_select)
    expect(described_class.helper_for(" token_search ")).to eq(:rfk_token_search)
    expect(described_class.registered_field_type?(:combobox)).to be(true)
    expect(described_class.registered_field_type?(:unknown_field)).to be(false)
    expect(described_class.registered_field_type?(nil)).to be(false)
  end

  it "returns duplicated registered helper mappings" do
    helpers = described_class.field_helpers
    helpers.clear

    expect(described_class.helper_for(:combobox)).to eq(:rfk_combobox)
    expect(described_class.registered_field_type?(:combobox)).to be(true)
  end

  it "exposes custom registered helper mappings" do
    described_class.register_field_helper(:custom_field, :custom_table_field)

    expect(described_class.helper_for(:custom_field)).to eq(:custom_table_field)
    expect(described_class.registered_field_type?(:custom_field)).to be(true)
  end

  it "normalizes custom field helper registration" do
    described_class.register_field_helper(" custom_field ", " custom_table_field ")

    expect(described_class.helper_for(:custom_field)).to eq(:custom_table_field)
  end

  it "rejects blank custom field helper registrations" do
    expect { described_class.register_field_helper(nil, :custom_table_field) }.to raise_error(
      ArgumentError,
      "table field type is required"
    )
    expect { described_class.register_field_helper(:custom_field, " ") }.to raise_error(
      ArgumentError,
      "table helper name is required"
    )
  end

  it "allows custom field helper registration" do
    described_class.register_field_helper(:custom_field, :custom_table_field)
    metadata = { field_type: "custom_field", method: "code", options: { prefix: "#" } }

    expect(described_class.filter_call(metadata)).to eq(
      helper: :custom_table_field,
      method: :code,
      options: { prefix: "#" }
    )
  end

  it "renders custom registered field helpers" do
    described_class.register_field_helper(:custom_field, :custom_table_field)
    form_builder = FakeTableFormBuilder.new
    metadata = { field_type: "custom_field", method: "code", options: { prefix: "#" } }

    expect(described_class.render_filter(form_builder, metadata)).to eq("custom")
    expect(form_builder.calls).to eq([
      [:custom_table_field, :code, { prefix: "#" }]
    ])
  end

  it "resets custom field helper registration" do
    described_class.register_field_helper(:custom_field, :custom_table_field)
    described_class.reset_field_helpers!

    metadata = { field_type: "custom_field", method: "code", options: {} }
    expect { described_class.filter_call(metadata) }.to raise_error(RailsFieldsKit::TableRenderer::UnknownFieldType)
  end

  it "raises for missing field types" do
    [
      { method: "query", options: {} },
      { field_type: nil, method: "query", options: {} },
      { field_type: " ", method: "query", options: {} }
    ].each do |metadata|
      expect { described_class.filter_call(metadata) }.to raise_error(
        RailsFieldsKit::TableRenderer::UnknownFieldType,
        "table metadata field_type is required"
      )
    end
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
    [
      { field_type: "combobox", options: {} },
      { field_type: "combobox", method: nil, options: {} },
      { field_type: "combobox", method: " ", options: {} }
    ].each do |metadata|
      expect { described_class.render_filter(form_builder, metadata) }.to raise_error(
        ArgumentError,
        "table metadata method is required"
      )
    end
  end
end