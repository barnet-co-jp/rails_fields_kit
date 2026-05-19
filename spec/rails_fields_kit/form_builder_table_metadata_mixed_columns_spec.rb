# frozen_string_literal: true

RSpec.describe "RailsFieldsKit FormBuilder table metadata mixed columns" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  MixedColumnsDummyModel = Struct.new(:status, :customer_id, :query, :tag_ids) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "MixedColumnsDummyModel")
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

  MixedObjectColumn = Struct.new(:filter, :editor, keyword_init: true)

  class MixedHashLikeColumn
    def initialize(column)
      @column = column
    end

    def to_hash
      @column
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder
    model = MixedColumnsDummyModel.new("draft", nil, nil, [])
    ActionView::Helpers::FormBuilder.new(:mixed_columns_dummy_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders only enabled filters from mixed table column definitions" do
    columns = [
      {
        filter: RailsFieldsKit::TableFilterInput.combobox(:customer_id, url: "/customers.json"),
        editor: RailsFieldsKit::TableCellInput.enum_select(:status)
      },
      {
        filter: false,
        filter_input: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/should-not-render.json")
      },
      MixedObjectColumn.new(
        filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
      ),
      MixedHashLikeColumn.new(
        search_filter: RailsFieldsKit::TableFilterInput.tags(:tag_ids, url: "/tags.json")
      ),
      { filter: nil }
    ]

    html = form_builder.rfk_table_filters(columns)

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"combobox\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/customers.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"token_search\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/tokens.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"tags\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/tags.json\"")
    expect(html).not_to include("/should-not-render.json")
  end

  it "renders only enabled cell editors from mixed table column definitions" do
    columns = [
      {
        filter: RailsFieldsKit::TableFilterInput.combobox(:customer_id, url: "/customers.json"),
        editor: RailsFieldsKit::TableCellInput.enum_select(:status)
      },
      MixedObjectColumn.new(
        editor: RailsFieldsKit::TableCellInput.combobox(:customer_id, url: "/editor-customers.json")
      ),
      MixedHashLikeColumn.new(
        cell_editor: RailsFieldsKit::TableCellInput.tags(:tag_ids, url: "/editor-tags.json")
      ),
      {
        editor: false,
        cell_editor: RailsFieldsKit::TableCellInput.combobox(:customer_id, url: "/should-not-render.json")
      },
      { editor: nil }
    ]

    html = form_builder.rfk_table_cell_editors(columns)

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"select\"")
    expect(html).to include(">Draft</option>")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/editor-customers.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"tags\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/editor-tags.json\"")
    expect(html).not_to include("/should-not-render.json")
  end
end
