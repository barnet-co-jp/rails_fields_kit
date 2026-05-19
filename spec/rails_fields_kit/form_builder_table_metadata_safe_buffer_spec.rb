# frozen_string_literal: true

RSpec.describe "RailsFieldsKit FormBuilder table metadata safe buffers" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  SafeBufferDummyModel = Struct.new(:query, :status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "SafeBufferDummyModel")
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
    model = SafeBufferDummyModel.new(nil, "draft")
    ActionView::Helpers::FormBuilder.new(:safe_buffer_dummy_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "returns an ActiveSupport::SafeBuffer from rfk_table_filters" do
    html = form_builder.rfk_table_filters([
      {
        filter: RailsFieldsKit::TableFilterInput.token_search(
          :query,
          url: "/tokens.json"
        )
      }
    ])

    expect(html).to be_a(ActiveSupport::SafeBuffer)
    expect(html.html_safe?).to eq(true)
  end

  it "returns an ActiveSupport::SafeBuffer from rfk_table_cell_editors" do
    html = form_builder.rfk_table_cell_editors([
      {
        editor: RailsFieldsKit::TableCellInput.enum_select(:status)
      }
    ])

    expect(html).to be_a(ActiveSupport::SafeBuffer)
    expect(html.html_safe?).to eq(true)
  end
end
