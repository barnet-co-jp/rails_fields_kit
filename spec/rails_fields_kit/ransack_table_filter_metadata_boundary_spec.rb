# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Ransack table filter metadata boundary" do
  class RansackBoundaryFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_token_search(method, **options)
      calls << [:rfk_token_search, method, options]
      "token_search"
    end
  end

  it "keeps ransack_filter as token-search metadata with adapter options" do
    input = RailsFieldsKit::TableFilterInput.ransack_filter(
      :query,
      fields: {
        name: :name_cont,
        status: {label: "Status", predicate: :status_eq, values: %w[open closed]}
      },
      url: "/order_tokens.json",
      param_name: :q,
      placeholder: "status:open keyword"
    )

    expect(input.to_table_filter).to eq(
      type: "rails_fields_kit",
      field_type: "token_search",
      method: "query",
      options: {
        adapter: :ransack,
        param_name: :q,
        fields: {
          name: :name_cont,
          status: {label: "Status", predicate: :status_eq, values: %w[open closed]}
        },
        placeholder: "status:open keyword",
        url: "/order_tokens.json"
      }
    )
  end

  it "passes ransack metadata through the renderer without interpreting search semantics" do
    input = RailsFieldsKit::TableFilterInput.ransack_filter(
      :query,
      fields: {name: :name_cont, status: :status_eq},
      param_name: :q
    )

    expect(RailsFieldsKit::TableRenderer.filter_call(input)).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {
        adapter: :ransack,
        param_name: :q,
        fields: {name: :name_cont, status: :status_eq}
      }
    )
  end

  it "renders through the existing rfk_token_search helper rather than a direct adapter DSL" do
    form_builder = RansackBoundaryFormBuilder.new
    input = RailsFieldsKit::TableFilterInput.ransack_filter(
      :query,
      fields: {name: :name_cont},
      param_name: :q
    )

    expect(RailsFieldsKit::TableRenderer.render_filter(form_builder, input)).to eq("token_search")
    expect(form_builder.calls).to eq([
      [
        :rfk_token_search,
        :query,
        {
          adapter: :ransack,
          param_name: :q,
          fields: {name: :name_cont}
        }
      ]
    ])
  end
end
