# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  class RenderResultFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_token_search(method_name, **options)
      @calls << [:rfk_token_search, method_name, options]
      "token-search-#{method_name}"
    end

    def rfk_enum_select(method_name, **options)
      @calls << [:rfk_enum_select, method_name, options]
      "enum-select-#{method_name}"
    end
  end

  it "returns rendered filter results in metadata order" do
    form_builder = RenderResultFormBuilder.new

    rendered = described_class.render_filters(
      form_builder,
      [
        {
          field_type: "token_search",
          method: :query,
          options: { url: "/tokens.json" }
        },
        {
          field_type: "token_search",
          method: :secondary_query,
          options: { url: "/secondary-tokens.json" }
        }
      ]
    )

    expect(rendered).to eq([
      "token-search-query",
      "token-search-secondary_query"
    ])

    expect(form_builder.calls).to eq([
      [:rfk_token_search, :query, { url: "/tokens.json" }],
      [:rfk_token_search, :secondary_query, { url: "/secondary-tokens.json" }]
    ])
  end

  it "returns rendered cell editor results in metadata order" do
    form_builder = RenderResultFormBuilder.new

    rendered = described_class.render_cell_editors(
      form_builder,
      [
        {
          field_type: "enum_select",
          method: :status,
          options: {}
        },
        {
          field_type: "enum_select",
          method: :secondary_status,
          options: { include_blank: true }
        }
      ]
    )

    expect(rendered).to eq([
      "enum-select-status",
      "enum-select-secondary_status"
    ])

    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}],
      [:rfk_enum_select, :secondary_status, { include_blank: true }]
    ])
  end
end
