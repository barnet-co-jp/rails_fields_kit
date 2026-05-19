# frozen_string_literal: true

RSpec.describe "RailsFieldsKit FormBuilder table metadata helpers with hash-like columns" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  TableHelperDummyModel = Struct.new(:status, :customer_id, :keyword) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "TableHelperDummyModel")
    end

    def self.statuses
      { "draft" => 0, "published" => 1 }
    end

    def self.human_attribute_name(attribute, options = {})
      translations = {
        "status.draft" => "Draft label",
        "status.published" => "Published label"
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

  class TableHelperHashLikeColumn
    def initialize(column)
      @column = column
    end

    def to_hash
      @column
    end

    def to_a
      [[:unexpected, true]]
    end
  end

  class TableHelperTableLikeObject
    attr_reader :columns

    def initialize(columns)
      @columns = columns
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder
    model = TableHelperDummyModel.new("draft", nil, nil)
    ActionView::Helpers::FormBuilder.new(:table_helper_dummy_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders filters from a table-like object with a single hash-like column" do
    column = TableHelperHashLikeColumn.new(
      filter: RailsFieldsKit::TableFilterInput.token_search(:keyword, url: "/tokens.json")
    )
    table = TableHelperTableLikeObject.new(column)

    html = form_builder.rfk_table_filters(table)

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"token_search\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/tokens.json\"")
  end

  it "renders cell editors from a table-like object with a single hash-like column" do
    column = TableHelperHashLikeColumn.new(
      editor: RailsFieldsKit::TableCellInput.enum_select(:status)
    )
    table = TableHelperTableLikeObject.new(column)

    html = form_builder.rfk_table_cell_editors(table)

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"select\"")
    expect(html).to include(">Draft label</option>")
  end

  it "renders an empty safe string for nil table metadata" do
    expect(form_builder.rfk_table_filters(nil)).to eq("")
    expect(form_builder.rfk_table_cell_editors(nil)).to eq("")
  end
end
