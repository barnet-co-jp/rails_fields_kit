# frozen_string_literal: true

RSpec.describe "Tom Select dropdown parent option" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  DummyDropdownParentModel = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "DummyDropdownParentModel")
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
    model = DummyDropdownParentModel.new(nil)
    ActionView::Helpers::FormBuilder.new(:dummy_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders dropdown_parent as a Tom Select data value" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      dropdown_parent: "body"
    )

    expect(html).to include("data-rails-fields-kit--tom-select-dropdown-parent-value=\"body\"")
  end

  it "does not render dropdown parent data when omitted" do
    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json")

    expect(html).not_to include("data-rails-fields-kit--tom-select-dropdown-parent-value")
  end
end
