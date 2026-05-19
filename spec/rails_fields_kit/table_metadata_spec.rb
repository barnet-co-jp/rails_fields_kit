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

    it "exposes known filter field types" do
      expect(described_class.known_types).to include(:combobox, :token_search)
      expect(described_class.known_type?(:combobox)).to be(true)
      expect(described_class.known_type?(" token_search ")).to be(true)
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
      expect(described_class.known_types).to include(:combobox, :token_search)
      expect(described_class.known_type?(:combobox)).to be(true)
      expect(described_class.known_type?(" token_search ")).to be(true)
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
end