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