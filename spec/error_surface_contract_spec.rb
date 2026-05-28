# frozen_string_literal: true

require "spec_helper"

RSpec.describe "error surface contract" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  DummyModel = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "DummyModel")
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

  def form_builder(model = DummyModel.new(nil), object_name = :dummy_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  it "renders the shared error surface id for opt-in tom select fields" do
    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json", error_surface: true)

    expect(html).to include("data-rails-fields-kit--tom-select-error-surface-id-value=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("aria-describedby=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("id=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("class=\"rfk-tom-select-error-surface\"")
  end

  it "keeps the same error surface id when custom error_surface_html is used" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      error_surface: true,
      error_surface_html: {
        class: "field-error",
        data: { lane: "custom" },
        role: "alert"
      }
    )

    expect(html).to include("data-rails-fields-kit--tom-select-error-surface-id-value=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("id=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("class=\"field-error rfk-tom-select-error-surface\"")
    expect(html).to include("data-lane=\"custom\"")
    expect(html).to include("role=\"alert\"")
  end

  it "does not render or reference an error surface for non-opt-in fields" do
    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json")

    expect(html).not_to include("data-rails-fields-kit--tom-select-error-surface-id-value")
    expect(html).not_to include("dummy_model_customer_id_error_surface")
  end
end
