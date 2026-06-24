# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  class FakeHashLikeMetadata
    def initialize(hash)
      @hash = hash
    end

    def to_hash
      @hash
    end
  end

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

    def rfk_file_field(method, **options)
      calls << [:rfk_file_field, method, options]
      "file_field"
    end

    def rfk_date_field(method, **options)
      calls << [:rfk_date_field, method, options]
      "date_field"
    end

    def rfk_time_field(method, **options)
      calls << [:rfk_time_field, method, options]
      "time_field"
    end

    def rfk_datetime_local_field(method, **options)
      calls << [:rfk_datetime_local_field, method, options]
      "datetime_local_field"
    end

    def rfk_color_field(method, **options)
      calls << [:rfk_color_field, method, options]
      "color_field"
    end

    def custom_table_field(method, **options)
      calls << [:custom_table_field, method, options]
      "custom"
    end
  end

  around do |example|
    described_class.reset_field_helpers!
    example.run
    described_class.reset_field_helpers!
  end

  it "normalizes string field types and methods for filter calls" do
    metadata = {"field_type" => " token_search ", "method" => " query ", "options" => {"url" => "/tokens.json"}}

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {"url" => "/tokens.json"}
    )
  end

  it "normalizes string field types and methods for cell editor calls" do
    metadata = {"field_type" => " enum_select ", "method" => " status ", "options" => {}}

    expect(described_class.cell_editor_call(metadata)).to eq(
      helper: :rfk_enum_select,
      method: :status,
      options: {}
    )
  end

  it "normalizes registered helper lookups" do
    expect(described_class.helper_for(" token_search ")).to eq(:rfk_token_search)
  end

  it "duplicates filter call options hashes" do
    metadata = {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}

    call = described_class.filter_call(metadata)
    call[:options][:url] = "/mutated.json"

    expect(metadata).to eq(field_type: "token_search", method: "query", options: {url: "/tokens.json"})
  end

  it "duplicates cell editor call options hashes" do
    metadata = {field_type: "enum_select", method: "status", options: {include_blank: true}}

    call = described_class.cell_editor_call(metadata)
    call[:options][:include_blank] = false

    expect(metadata).to eq(field_type: "enum_select", method: "status", options: {include_blank: true})
  end

  it "returns rendered filter results in metadata order" do
    form_builder = FakeTableFormBuilder.new
    filters = [
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}},
      {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}
    ]

    expect(described_class.render_filters(form_builder, filters)).to eq(["combobox", "token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, {url: "/customers.json"}],
      [:rfk_token_search, :query, {url: "/tokens.json"}]
    ])
  end

  it "returns rendered cell editor results in metadata order" do
    form_builder = FakeTableFormBuilder.new
    editors = [
      {field_type: "enum_select", method: "status", options: {}},
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}}
    ]

    expect(described_class.render_cell_editors(form_builder, editors)).to eq(["enum_select", "combobox"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}],
      [:rfk_combobox, :customer_id, {url: "/customers.json"}]
    ])
  end

  it "builds a filter call spec from filter metadata objects" do
    metadata = RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {url: "/tokens.json"}
    )
  end

  it "builds a filter call spec from hash-like metadata" do
    metadata = FakeHashLikeMetadata.new(
      field_type: "token_search",
      method: :query,
      options: {url: "/tokens.json"}
    )

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {url: "/tokens.json"}
    )
  end

  it "rejects invalid hash-like filter metadata" do
    metadata = FakeHashLikeMetadata.new([[:field_type, "token_search"]])

    expect { described_class.filter_call(metadata) }.to raise_error(
      ArgumentError,
      "table metadata to_hash must return a hash"
    )
  end

  it "rejects non-hash filter metadata" do
    expect { described_class.filter_call(:token_search) }.to raise_error(
      ArgumentError,
      "table metadata must be a hash"
    )
  end

  it "builds filter call specs in batches" do
    filters = [
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}},
      {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}
    ]

    expect(described_class.filter_calls(filters)).to eq([
      {helper: :rfk_combobox, method: :customer_id, options: {url: "/customers.json"}},
      {helper: :rfk_token_search, method: :query, options: {url: "/tokens.json"}}
    ])
  end

  it "treats nil filter batches as empty" do
    expect(described_class.filter_calls(nil)).to eq([])
  end

  it "builds a single filter call spec from one hash in batch APIs" do
    metadata = {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}

    expect(described_class.filter_calls(metadata)).to eq([
      {helper: :rfk_token_search, method: :query, options: {url: "/tokens.json"}}
    ])
  end

  it "treats a single hash-like metadata object as one batch entry" do
    metadata = FakeHashLikeMetadata.new(
      field_type: "token_search",
      method: :query,
      options: {url: "/tokens.json"}
    )

    expect(described_class.filter_calls(metadata)).to eq([
      {helper: :rfk_token_search, method: :query, options: {url: "/tokens.json"}}
    ])
  end

  it "builds filter call specs from enumerable batch inputs" do
    filters = [
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}},
      {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}
    ].each

    expect(described_class.filter_calls(filters)).to eq([
      {helper: :rfk_combobox, method: :customer_id, options: {url: "/customers.json"}},
      {helper: :rfk_token_search, method: :query, options: {url: "/tokens.json"}}
    ])
  end

  it "normalizes metadata method names" do
    metadata = {field_type: "token_search", method: " query ", options: {url: "/tokens.json"}}

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {url: "/tokens.json"}
    )
  end

  it "normalizes metadata options" do
    metadata = {field_type: "token_search", method: "query", options: {"url" => "/tokens.json"}}

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {"url" => "/tokens.json"}
    )
  end

  it "defaults missing metadata options to an empty hash" do
    metadata = {field_type: "token_search", method: "query"}

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {}
    )
  end

  it "duplicates metadata options" do
    metadata = {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}

    call = described_class.filter_call(metadata)
    call[:options][:url] = "/mutated.json"

    expect(metadata).to eq(field_type: "token_search", method: "query", options: {url: "/tokens.json"})
  end

  it "rejects non-hash metadata options" do
    metadata = {field_type: "token_search", method: "query", options: "not a hash"}

    expect { described_class.filter_call(metadata) }.to raise_error(
      ArgumentError,
      "table metadata options must be a hash"
    )
  end

  it "builds a token search filter call spec" do
    metadata = {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}

    expect(described_class.filter_call(metadata)).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {url: "/tokens.json"}
    )
  end

  it "maps native date/time/color metadata to FormBuilder helpers" do
    form_builder = FakeTableFormBuilder.new
    filters = [
      {field_type: "date_field", method: "starts_on", options: {min: "2026-01-01"}},
      {field_type: "time_field", method: "starts_at", options: {step: 900}}
    ]
    editors = [
      {field_type: "datetime_local_field", method: "published_at", options: {step: 60}},
      {field_type: "color_field", method: "accent_color", options: {required: true}}
    ]

    expect(described_class.render_filters(form_builder, filters)).to eq(["date_field", "time_field"])
    expect(described_class.render_cell_editors(form_builder, editors)).to eq(["datetime_local_field", "color_field"])
    expect(form_builder.calls).to eq([
      [:rfk_date_field, :starts_on, {min: "2026-01-01"}],
      [:rfk_time_field, :starts_at, {step: 900}],
      [:rfk_datetime_local_field, :published_at, {step: 60}],
      [:rfk_color_field, :accent_color, {required: true}]
    ])
  end

  it "builds a cell editor call spec" do
    metadata = {field_type: "enum_select", method: "status", options: {}}

    expect(described_class.cell_editor_call(metadata)).to eq(
      helper: :rfk_enum_select,
      method: :status,
      options: {}
    )
  end

  it "builds a file field cell editor call spec" do
    metadata = {
      field_type: "file_field",
      method: "attachment",
      options: {accept: "image/png", multiple: true, direct_upload: true}
    }

    expect(described_class.cell_editor_call(metadata)).to eq(
      helper: :rfk_file_field,
      method: :attachment,
      options: {accept: "image/png", multiple: true, direct_upload: true}
    )
  end

  it "builds a cell editor call spec from hash-like metadata" do
    metadata = FakeHashLikeMetadata.new(
      field_type: "enum_select",
      method: :status,
      options: {}
    )

    expect(described_class.cell_editor_call(metadata)).to eq(
      helper: :rfk_enum_select,
      method: :status,
      options: {}
    )
  end

  it "rejects invalid hash-like cell editor metadata" do
    metadata = FakeHashLikeMetadata.new([[:field_type, "enum_select"]])

    expect { described_class.cell_editor_call(metadata) }.to raise_error(
      ArgumentError,
      "table metadata to_hash must return a hash"
    )
  end

  it "rejects non-hash cell editor metadata" do
    expect { described_class.cell_editor_call(:enum_select) }.to raise_error(
      ArgumentError,
      "table metadata must be a hash"
    )
  end

  it "builds cell editor call specs in batches" do
    editors = [
      {field_type: "enum_select", method: "status", options: {}},
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}}
    ]

    expect(described_class.cell_editor_calls(editors)).to eq([
      {helper: :rfk_enum_select, method: :status, options: {}},
      {helper: :rfk_combobox, method: :customer_id, options: {url: "/customers.json"}}
    ])
  end

  it "treats nil cell editor batches as empty" do
    expect(described_class.cell_editor_calls(nil)).to eq([])
  end

  it "builds a single cell editor call spec from one hash in batch APIs" do
    metadata = {field_type: "enum_select", method: "status", options: {}}

    expect(described_class.cell_editor_calls(metadata)).to eq([
      {helper: :rfk_enum_select, method: :status, options: {}}
    ])
  end

  it "treats a single hash-like cell editor metadata object as one batch entry" do
    metadata = FakeHashLikeMetadata.new(
      field_type: "enum_select",
      method: :status,
      options: {}
    )

    expect(described_class.cell_editor_calls(metadata)).to eq([
      {helper: :rfk_enum_select, method: :status, options: {}}
    ])
  end

  it "builds cell editor call specs from enumerable batch inputs" do
    editors = [
      {field_type: "enum_select", method: "status", options: {}},
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}}
    ].each

    expect(described_class.cell_editor_calls(editors)).to eq([
      {helper: :rfk_enum_select, method: :status, options: {}},
      {helper: :rfk_combobox, method: :customer_id, options: {url: "/customers.json"}}
    ])
  end

  it "renders filters through a form builder" do
    form_builder = FakeTableFormBuilder.new
    metadata = {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}

    expect(described_class.render_filter(form_builder, metadata)).to eq("token_search")
    expect(form_builder.calls).to eq([
      [:rfk_token_search, :query, {url: "/tokens.json"}]
    ])
  end

  it "renders filters in batches" do
    form_builder = FakeTableFormBuilder.new
    filters = [
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}},
      {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}
    ]

    expect(described_class.render_filters(form_builder, filters)).to eq(["combobox", "token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, {url: "/customers.json"}],
      [:rfk_token_search, :query, {url: "/tokens.json"}]
    ])
  end

  it "renders one filter from one hash in batch APIs" do
    form_builder = FakeTableFormBuilder.new
    metadata = {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}

    expect(described_class.render_filters(form_builder, metadata)).to eq(["token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_token_search, :query, {url: "/tokens.json"}]
    ])
  end

  it "renders filters from enumerable batch inputs" do
    form_builder = FakeTableFormBuilder.new
    filters = [
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}},
      {field_type: "token_search", method: "query", options: {url: "/tokens.json"}}
    ].each

    expect(described_class.render_filters(form_builder, filters)).to eq(["combobox", "token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, {url: "/customers.json"}],
      [:rfk_token_search, :query, {url: "/tokens.json"}]
    ])
  end

  it "renders cell editors through a form builder" do
    form_builder = FakeTableFormBuilder.new
    metadata = {field_type: "enum_select", method: "status", options: {}}

    expect(described_class.render_cell_editor(form_builder, metadata)).to eq("enum_select")
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}]
    ])
  end

  it "renders file field cell editors through a form builder" do
    form_builder = FakeTableFormBuilder.new
    metadata = {
      field_type: "file_field",
      method: "attachment",
      options: {accept: "image/png", multiple: true, direct_upload: true}
    }

    expect(described_class.render_cell_editor(form_builder, metadata)).to eq("file_field")
    expect(form_builder.calls).to eq([
      [:rfk_file_field, :attachment, {accept: "image/png", multiple: true, direct_upload: true}]
    ])
  end

  it "renders cell editors in batches" do
    form_builder = FakeTableFormBuilder.new
    editors = [
      {field_type: "enum_select", method: "status", options: {}},
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}}
    ]

    expect(described_class.render_cell_editors(form_builder, editors)).to eq(["enum_select", "combobox"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}],
      [:rfk_combobox, :customer_id, {url: "/customers.json"}]
    ])
  end

  it "renders one cell editor from one hash in batch APIs" do
    form_builder = FakeTableFormBuilder.new
    metadata = {field_type: "enum_select", method: "status", options: {}}

    expect(described_class.render_cell_editors(form_builder, metadata)).to eq(["enum_select"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}]
    ])
  end

  it "renders cell editors from enumerable batch inputs" do
    form_builder = FakeTableFormBuilder.new
    editors = [
      {field_type: "enum_select", method: "status", options: {}},
      {field_type: "combobox", method: "customer_id", options: {url: "/customers.json"}}
    ].each

    expect(described_class.render_cell_editors(form_builder, editors)).to eq(["enum_select", "combobox"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}],
      [:rfk_combobox, :customer_id, {url: "/customers.json"}]
    ])
  end

  it "exposes registered helper mappings" do
    expect(described_class.field_helpers).to include(
      "combobox" => :rfk_combobox,
      "token_search" => :rfk_token_search,
      "enum_select" => :rfk_enum_select,
      "date_field" => :rfk_date_field,
      "time_field" => :rfk_time_field,
      "datetime_local_field" => :rfk_datetime_local_field,
      "color_field" => :rfk_color_field,
      "file_field" => :rfk_file_field
    )
  end

  it "returns duplicated registered helper mappings" do
    helpers = described_class.field_helpers
    helpers["custom"] = :custom_helper

    expect(described_class.field_helpers).not_to have_key("custom")
  end

  it "exposes registered field types without helper names" do
    expect(described_class.registered_field_types).to include(
      "combobox",
      "token_search",
      "enum_select",
      "date_field",
      "time_field",
      "datetime_local_field",
      "color_field",
      "file_field"
    )
    expect(described_class.registered_field_types).not_to include(:rfk_combobox)
  end

  it "returns duplicated registered field types" do
    field_types = described_class.registered_field_types
    field_types << "custom"

    expect(described_class.registered_field_types).not_to include("custom")
  end

  it "exposes custom registered field types" do
    described_class.register_field_helper(:custom_field, :custom_table_field)

    expect(described_class.registered_field_types).to include("custom_field")
  end

  it "resets registered field types to the default registry" do
    described_class.register_field_helper(:custom_field, :custom_table_field)
    described_class.reset_field_helpers!

    expect(described_class.registered_field_types).to include("combobox", "token_search")
    expect(described_class.registered_field_types).not_to include("custom_field")
  end

  it "exposes custom registered helper mappings" do
    described_class.register_field_helper(:custom_field, :custom_table_field)

    expect(described_class.field_helpers).to include(
      "custom_field" => :custom_table_field
    )
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
    expect { described_class.register_field_helper(:custom_field, nil) }.to raise_error(
      ArgumentError,
      "table helper name is required"
    )
  end

  it "allows custom field helper registration" do
    described_class.register_field_helper(:custom_field, :custom_table_field)
    metadata = {field_type: "custom_field", method: "code", options: {prefix: "#"}}

    expect(described_class.filter_call(metadata)).to eq(
      helper: :custom_table_field,
      method: :code,
      options: {prefix: "#"}
    )
  end

  it "renders custom registered field helpers" do
    described_class.register_field_helper(:custom_field, :custom_table_field)
    form_builder = FakeTableFormBuilder.new
    metadata = {field_type: "custom_field", method: "code", options: {prefix: "#"}}

    expect(described_class.render_filter(form_builder, metadata)).to eq("custom")
    expect(form_builder.calls).to eq([
      [:custom_table_field, :code, {prefix: "#"}]
    ])
  end

  it "resets custom field helper registration" do
    described_class.register_field_helper(:custom_field, :custom_table_field)
    described_class.reset_field_helpers!

    metadata = {field_type: "custom_field", method: "code", options: {}}
    expect { described_class.filter_call(metadata) }.to raise_error(RailsFieldsKit::TableRenderer::UnknownFieldType)
  end

  it "raises for missing field types" do
    [
      {method: "query", options: {}},
      {field_type: nil, method: "query", options: {}}
    ].each do |metadata|
      expect { described_class.filter_call(metadata) }.to raise_error(
        RailsFieldsKit::TableRenderer::UnknownFieldType,
        "table metadata field_type is required"
      )
    end
  end

  it "raises for unknown field types" do
    metadata = {field_type: "unknown", method: "query", options: {}}

    expect { described_class.filter_call(metadata) }.to raise_error(
      RailsFieldsKit::TableRenderer::UnknownFieldType,
      "unknown Rails Fields Kit table field type: unknown"
    )
  end

  it "raises when rendering metadata without a method" do
    form_builder = FakeTableFormBuilder.new
    metadata = {field_type: "token_search", method: nil, options: {url: "/tokens.json"}}

    expect { described_class.render_filter(form_builder, metadata) }.to raise_error(
      ArgumentError,
      "table metadata method is required"
    )
  end
end
