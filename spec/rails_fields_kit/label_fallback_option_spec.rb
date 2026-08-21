# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select label fallback option" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  LabelFallbackDummyModel = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "LabelFallbackDummyModel")
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

  def form_builder(model = LabelFallbackDummyModel.new(nil), object_name = :label_fallback_dummy_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "omits the label fallback data value by default" do
    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json")

    expect(html).not_to include("data-rails-fields-kit--tom-select-label-fallback-value")
  end

  it "renders an opt-out data value for fields that need strict endpoint labels" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      label_fallback: false
    )

    expect(html).to include("data-rails-fields-kit--tom-select-label-fallback-value=\"false\"")
    expect(html).to include("data-rails-fields-kit--tom-select-value-field-value=\"value\"")
    expect(html).to include("data-rails-fields-kit--tom-select-label-field-value=\"text\"")
  end
end
