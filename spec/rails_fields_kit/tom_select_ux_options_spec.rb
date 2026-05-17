# frozen_string_literal: true

RSpec.describe "Tom Select UX options" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  UxOptionsModel = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "UxOptionsModel")
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

  def form_builder(model = UxOptionsModel.new(nil), object_name = :ux_options_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders explicit UX option data attributes" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      open_on_focus: false,
      close_after_select: true,
      hide_selected: true,
      persist: true
    )

    expect(html).to include("data-rails-fields-kit--tom-select-open-on-focus-value=\"false\"")
    expect(html).to include("data-rails-fields-kit--tom-select-close-after-select-value=\"true\"")
    expect(html).to include("data-rails-fields-kit--tom-select-hide-selected-value=\"true\"")
    expect(html).to include("data-rails-fields-kit--tom-select-persist-value=\"true\"")
  end

  it "renders configured UX option defaults" do
    RailsFieldsKit.configure do |config|
      config.default_open_on_focus = true
      config.default_close_after_select = false
      config.default_hide_selected = false
      config.default_persist = false
    end

    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json")

    expect(html).to include("data-rails-fields-kit--tom-select-open-on-focus-value=\"true\"")
    expect(html).to include("data-rails-fields-kit--tom-select-close-after-select-value=\"false\"")
    expect(html).to include("data-rails-fields-kit--tom-select-hide-selected-value=\"false\"")
    expect(html).to include("data-rails-fields-kit--tom-select-persist-value=\"false\"")
  end
end
