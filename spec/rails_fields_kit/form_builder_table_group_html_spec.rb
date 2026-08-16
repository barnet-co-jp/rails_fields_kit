# frozen_string_literal: true

RSpec.describe "RailsFieldsKit FormBuilder table group html option" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  TableGroupHtmlDummyModel = Struct.new(:status, :keyword) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "TableGroupHtmlDummyModel")
    end

    def self.statuses
      { "draft" => 0, "published" => 1 }
    end

    def self.human_attribute_name(attribute, options = {})
      translations = {
        "status.draft" => "Draft",
        "status.published" => "Published"
      }

      translations.fetch(attribute.to_s, options[:default] || attribute.to_s.humanize)
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder
    model = TableGroupHtmlDummyModel.new("draft", nil)
    ActionView::Helpers::FormBuilder.new(:table_group_html_dummy_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps existing safe-joined filter output when group_html is omitted" do
    columns = [
      {
        filter: RailsFieldsKit::TableFilterInput.search_field(:keyword)
      }
    ]

    expected_html = safe_join(RailsFieldsKit::TableMetadata.render_filters(form_builder, columns))

    expect(form_builder.rfk_table_filters(columns)).to eq(expected_html)
  end

  it "wraps table filters with group-level html attributes" do
    columns = [
      {
        filter: RailsFieldsKit::TableFilterInput.search_field(:keyword)
      }
    ]

    html = form_builder.rfk_table_filters(
      columns,
      group_html: {
        class: "rfk-table-filter-group",
        data: { controller: "table-filters" },
        aria: { label: "Order filters" }
      }
    )

    expect(html).to include("<div")
    expect(html).to include("class=\"rfk-table-filter-group\"")
    expect(html).to include("data-controller=\"table-filters\"")
    expect(html).to include("aria-label=\"Order filters\"")
    expect(html).to include("table_group_html_dummy_model_keyword")
  end

  it "wraps table cell editors with the same group-level boundary" do
    columns = [
      {
        editor: RailsFieldsKit::TableCellInput.enum_select(:status)
      }
    ]

    html = form_builder.rfk_table_cell_editors(
      columns,
      group_html: {
        class: "rfk-table-editor-group",
        data: { role: "cell-editors" },
        aria: { label: "Cell editors" }
      }
    )

    expect(html).to include("class=\"rfk-table-editor-group\"")
    expect(html).to include("data-role=\"cell-editors\"")
    expect(html).to include("aria-label=\"Cell editors\"")
    expect(html).to include(">Draft</option>")
  end

  it "leaves TableMetadata batch render contracts as ordered arrays" do
    columns = [
      {
        filter: RailsFieldsKit::TableFilterInput.search_field(:keyword),
        editor: RailsFieldsKit::TableCellInput.enum_select(:status)
      }
    ]

    expect(RailsFieldsKit::TableMetadata.render_filters(form_builder, columns)).to be_an(Array)
    expect(RailsFieldsKit::TableMetadata.render_cell_editors(form_builder, columns)).to be_an(Array)
  end
end
