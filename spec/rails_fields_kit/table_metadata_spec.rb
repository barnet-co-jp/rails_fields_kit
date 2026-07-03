# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table metadata objects" do
  describe RailsFieldsKit::TableFilterInput do
    it "exposes table filter metadata" do
      input = described_class.new(
        :combobox,
        :customer_id,
        url: "/customers.json",
        selected_url: "/customers/selected.json"
      )

      expect(input.to_table_filter).to eq(
        type: "rails_fields_kit",
        field_type: "combobox",
        method: "customer_id",
        options: {
          url: "/customers.json",
          selected_url: "/customers/selected.json"
        }
      )
    end

    it "exposes table filter metadata as a hash" do
      input = described_class.new(:combobox, :customer_id, url: "/customers.json")

      expect(input.to_h).to eq(input.to_table_filter)
      expect(input.to_hash).to eq(input.to_h)
      expect(input.to_h).to eq(
        type: "rails_fields_kit",
        field_type: "combobox",
        method: "customer_id",
        options: { url: "/customers.json" }
      )
    end

    it "returns duplicated filter field names" do
      input = described_class.new(:combobox, :customer_id)
      field_name = input.field_name
      field_name.replace("mutated")

      expect(input.field_name).to eq("customer_id")
      expect(input.to_table_filter).to include(method: "customer_id")
    end

    it "returns duplicated filter options" do
      input = described_class.new(:combobox, :customer_id, url: "/customers.json")
      input.options.clear

      expect(input.options).to eq(url: "/customers.json")
      expect(input.to_table_filter).to include(options: { url: "/customers.json" })
    end

    it "builds common table filter metadata from factories" do
      input = described_class.combobox(
        :customer_id,
        url: "/customers.json",
        selected_url: "/customers/selected.json"
      )

      expect(input.to_table_filter).to eq(
        type: "rails_fields_kit",
        field_type: "combobox",
        method: "customer_id",
        options: {
          url: "/customers.json",
          selected_url: "/customers/selected.json"
        }
      )
    end

    it "builds native date/time/color table filter metadata from factories" do
      date_input = described_class.date_field(
        :starts_on,
        min: "2026-01-01",
        max: "2026-12-31"
      )
      time_input = described_class.time_field(:starts_at, step: 900)
      datetime_input = described_class.datetime_local_field(:published_at, step: 60)
      color_input = described_class.color_field(:accent_color, required: true)

      expect(date_input.to_table_filter).to eq(
        type: "rails_fields_kit",
        field_type: "date_field",
        method: "starts_on",
        options: {
          min: "2026-01-01",
          max: "2026-12-31"
        }
      )
      expect(time_input.to_table_filter).to include(
        field_type: "time_field",
        method: "starts_at",
        options: { step: 900 }
      )
      expect(datetime_input.to_table_filter).to include(
        field_type: "datetime_local_field",
        method: "published_at",
        options: { step: 60 }
      )
      expect(color_input.to_table_filter).to include(
        field_type: "color_field",
        method: "accent_color",
        options: { required: true }
      )
    end

    it "builds table filter metadata from a dynamic type" do
      input = described_class.from_type(
        :combobox,
        :customer_id,
        url: "/customers.json"
      )

      expect(input.to_table_filter).to eq(
        type: "rails_fields_kit",
        field_type: "combobox",
        method: "customer_id",
        options: {
          url: "/customers.json"
        }
      )
    end

    it "exposes known filter field types without file upload factories" do
      expect(described_class.known_types).to include(
        :combobox,
        :token_search,
        :date_field,
        :time_field,
        :datetime_local_field,
        :color_field,
        :radio_button
      )
      expect(described_class.known_type?(:combobox)).to be(true)
      expect(described_class.known_type?(" token_search ")).to be(true)
      expect(described_class.known_type?(:radio_button)).to be(true)
      expect(described_class.known_type?(:file_field)).to be(false)
      expect(described_class.known_type?(:unknown_field)).to be(false)
      expect(described_class.known_type?(nil)).to be(false)
      expect(described_class.known_type?(" ")).to be(false)
    end

    it "builds token search filter metadata" do
      input = described_class.token_search(
        :query,
        url: "/search_tokens.json",
        placeholder: "status:open keyword"
      )

      expect(input.to_table_filter).to eq(
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: {
          url: "/search_tokens.json",
          placeholder: "status:open keyword"
        }
      )
    end

    it "builds ransack filter metadata" do
      input = described_class.ransack_filter(
        :query,
        fields: { name: :name_cont, status: :status_eq },
        url: "/search_tokens.json",
        param_name: :q
      )

      expect(input.to_table_filter).to eq(
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: {
          adapter: :ransack,
          param_name: :q,
          fields: { name: :name_cont, status: :status_eq },
          url: "/search_tokens.json"
        }
      )
    end

    it "keeps Object#method available for reflection" do
      input = described_class.new(:combobox, :customer_id)

      expect(input.method(:to_table_filter)).to be_a(Method)
    end

    it "accepts type as a keyword alias for field_type" do
      input = described_class.new(type: :tags)

      expect(input.to_table_filter).to include(field_type: "tags")
    end
  end

  describe RailsFieldsKit::TableCellInput do
    it "exposes table cell editor metadata" do
      input = described_class.new(:enum_select, :status)

      expect(input.to_table_cell_editor).to eq(
        type: "rails_fields_kit",
        field_type: "enum_select",
        method: "status",
        options: {}
      )
    end

    it "exposes table cell editor metadata as a hash" do
      input = described_class.new(:enum_select, :status)

      expect(input.to_h).to eq(input.to_table_cell_editor)
      expect(input.to_hash).to eq(input.to_h)
      expect(input.to_h).to eq(
        type: "rails_fields_kit",
        field_type: "enum_select",
        method: "status",
        options: {}
      )
    end

    it "returns duplicated cell editor field names" do
      input = described_class.new(:combobox, :customer_id)
      field_name = input.field_name
      field_name.replace("mutated")

      expect(input.field_name).to eq("customer_id")
      expect(input.to_table_cell_editor).to include(method: "customer_id")
    end

    it "returns duplicated cell editor options" do
      input = described_class.new(:combobox, :customer_id, url: "/customers.json")
      input.options.clear

      expect(input.options).to eq(url: "/customers.json")
      expect(input.to_table_cell_editor).to include(options: { url: "/customers.json" })
    end

    it "builds common table cell editor metadata from factories" do
      input = described_class.combobox(
        :customer_id,
        url: "/customers.json",
        selected_url: "/customers/selected.json"
      )

      expect(input.to_table_cell_editor).to eq(
        type: "rails_fields_kit",
        field_type: "combobox",
        method: "customer_id",
        options: {
          url: "/customers.json",
          selected_url: "/customers/selected.json"
        }
      )
    end

    it "builds native date/time/color table cell editor metadata from factories" do
      date_input = described_class.date_field(:starts_on, min: "2026-01-01")
      time_input = described_class.time_field(:starts_at, step: 900)
      datetime_input = described_class.datetime_local_field(:published_at, step: 60)
      color_input = described_class.color_field(:accent_color, required: true)

      expect(date_input.to_table_cell_editor).to include(
        field_type: "date_field",
        method: "starts_on",
        options: { min: "2026-01-01" }
      )
      expect(time_input.to_table_cell_editor).to include(
        field_type: "time_field",
        method: "starts_at",
        options: { step: 900 }
      )
      expect(datetime_input.to_table_cell_editor).to include(
        field_type: "datetime_local_field",
        method: "published_at",
        options: { step: 60 }
      )
      expect(color_input.to_table_cell_editor).to include(
        field_type: "color_field",
        method: "accent_color",
        options: { required: true }
      )
    end

    it "builds radio button table cell editor metadata from the built-in factory" do
      input = described_class.radio_button(
        :status,
        tag_value: "published",
        label: "Published",
        checked: true
      )

      expect(input.to_table_cell_editor).to eq(
        type: "rails_fields_kit",
        field_type: "radio_button",
        method: "status",
        options: {
          tag_value: "published",
          label: "Published",
          checked: true
        }
      )
    end

    it "requires a radio button tag value for the built-in factory" do
      expect { described_class.radio_button(:status) }.to raise_error(ArgumentError)
    end

    it "builds file field cell editor metadata from the built-in factory" do
      input = described_class.file_field(
        :attachment,
        accept: "image/png",
        multiple: true,
        direct_upload: true
      )

      expect(input.to_table_cell_editor).to eq(
        type: "rails_fields_kit",
        field_type: "file_field",
        method: "attachment",
        options: {
          accept: "image/png",
          multiple: true,
          direct_upload: true
        }
      )
    end

    it "builds table cell editor metadata from a dynamic type" do
      input = described_class.from_type(
        :enum_select,
        :status,
        label: "Workflow status"
      )

      expect(input.to_table_cell_editor).to eq(
        type: "rails_fields_kit",
        field_type: "enum_select",
        method: "status",
        options: {
          label: "Workflow status"
        }
      )
    end

    it "exposes known cell editor field types" do
      expect(described_class.known_types).to include(
        :combobox,
        :token_search,
        :date_field,
        :time_field,
        :datetime_local_field,
        :color_field,
        :radio_button,
        :file_field
      )
      expect(described_class.known_type?(:combobox)).to be(true)
      expect(described_class.known_type?(" token_search ")).to be(true)
      expect(described_class.known_type?(:radio_button)).to be(true)
      expect(described_class.known_type?(:file_field)).to be(true)
      expect(described_class.known_type?(:unknown_field)).to be(false)
      expect(described_class.known_type?(nil)).to be(false)
      expect(described_class.known_type?(" ")).to be(false)
    end

    it "keeps Object#method available for reflection" do
      input = described_class.new(:enum_select, :status)

      expect(input.method(:to_table_cell_editor)).to be_a(Method)
    end

    it "accepts type as a keyword alias for field_type" do
      input = described_class.new(type: :combobox)

      expect(input.to_table_cell_editor).to include(field_type: "combobox")
    end
  end

  describe RailsFieldsKit::TableMetadata do
    it "treats nil and empty column sources as empty metadata lists" do
      empty_table = Struct.new(:columns).new([])

      expect(described_class.filters(nil)).to eq([])
      expect(described_class.cell_editors([])).to eq([])
      expect(described_class.filter_calls(empty_table)).to eq([])
    end

    it "treats single hash and object columns as one metadata-bearing column" do
      object_column = Struct.new(:filter).new(
        {
          type: "rails_fields_kit",
          field_type: "token_search",
          method: "query",
          options: { url: "/tokens.json" }
        }
      )

      expect(described_class.filters(filter: { type: "text", method: "name" })).to eq([
        { type: "text", method: "name" }
      ])
      expect(described_class.filters(object_column)).to eq([
        {
          type: "rails_fields_kit",
          field_type: "token_search",
          method: "query",
          options: { url: "/tokens.json" }
        }
      ])
    end

    it "uses a table-like object's columns reader as the source of truth" do
      table = Struct.new(:columns, :filter).new(
        [{ "filter" => { type: "select", method: "status" } }],
        { type: "text", method: "ignored" }
      )

      expect(described_class.filters(table)).to eq([
        { type: "select", method: "status" }
      ])
    end

    it "keeps invalid hash-like column and metadata boundaries explicit" do
      invalid_hash_like = Class.new do
        def to_hash
          "not a hash"
        end
      end

      expect { described_class.filters([invalid_hash_like.new]) }
        .to raise_error(ArgumentError, "table column to_hash must return a hash")
      expect { described_class.filters([{ filter: invalid_hash_like.new }]) }
        .to raise_error(ArgumentError, "table metadata to_hash must return a hash")
    end

    it "duplicates metadata hashes and nested options before returning them" do
      source_options = { url: "/customers.json" }
      source_metadata = { type: "rails_fields_kit", method: "customer_id", options: source_options }
      filter_metadata = described_class.filters([{ filter: source_metadata }]).first

      filter_metadata[:options][:url] = "/mutated.json"
      filter_metadata[:method] = "mutated"

      expect(source_metadata).to eq(
        type: "rails_fields_kit",
        method: "customer_id",
        options: { url: "/customers.json" }
      )
      expect(source_options).to eq(url: "/customers.json")
    end
  end
end
