# frozen_string_literal: true

RSpec.describe "RailsFieldsKit FormBuilder table metadata enumerators" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  EnumeratorDummyModel = Struct.new(:status, :query) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "EnumeratorDummyModel")
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

  class EnumeratorTableObject
    attr_reader :columns

    def initialize(columns)
      @columns = columns
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder
    model = EnumeratorDummyModel.new("draft", nil)
    ActionView::Helpers::FormBuilder.new(:enumerator_dummy_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders filters from enumerator-backed table columns" do
    columns = Enumerator.new do |yielder|
      yielder << {
        filter: RailsFieldsKit::TableFilterInput.token_search(
          :query,
          url: "/tokens.json"
        )
      }
    end

    table = EnumeratorTableObject.new(columns)

    html = form_builder.rfk_table_filters(table)

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"token_search\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/tokens.json\"")
  end

  it "renders cell editors from enumerator-backed table columns" do
    columns = Enumerator.new do |yielder|
      yielder << {
        editor: RailsFieldsKit::TableCellInput.enum_select(:status)
      }
    end

    table = EnumeratorTableObject.new(columns)

    html = form_builder.rfk_table_cell_editors(table)

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"select\"")
    expect(html).to include(">Draft</option>")
  end
end
