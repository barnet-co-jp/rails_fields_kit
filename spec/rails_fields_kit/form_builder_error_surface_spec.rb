# frozen_string_literal: true

RSpec.describe "RailsFieldsKit error surface ids" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  ErrorSurfaceModel = Struct.new(:customer_id) do
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

  def form_builder
    ActionView::Helpers::FormBuilder.new(:dummy_model, ErrorSurfaceModel.new(nil), self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps the generated error surface id as the default contract" do
    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json", error_surface: true)

    expect(html).to include("data-rails-fields-kit--tom-select-error-surface-id-value=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("aria-describedby=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("id=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("role=\"status\"")
    expect(html).to include("aria-live=\"polite\"")
  end

  it "uses an explicit error_surface_html id across data, accessibility, and the surface element" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      html: { aria: { describedby: "existing_hint" } },
      error_surface: true,
      error_surface_html: { id: "customer_lookup_error_surface", class: "field-error" }
    )

    expect(html).to include("data-rails-fields-kit--tom-select-error-surface-id-value=\"customer_lookup_error_surface\"")
    expect(html).to include("aria-describedby=\"existing_hint customer_lookup_error_surface\"")
    expect(html).to include("id=\"customer_lookup_error_surface\"")
    expect(html).to include("class=\"field-error rfk-tom-select-error-surface\"").or include("class=\"rfk-tom-select-error-surface field-error\"")
    expect(html).not_to include("dummy_model_customer_id_error_surface")
  end

  it "does not duplicate an existing describedby reference to the error surface" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      html: { aria: { describedby: "customer_lookup_error_surface" } },
      error_surface: true,
      error_surface_html: { id: "customer_lookup_error_surface" }
    )

    expect(html).to include("aria-describedby=\"customer_lookup_error_surface\"")
    expect(html).not_to include("aria-describedby=\"customer_lookup_error_surface customer_lookup_error_surface\"")
  end

  it "does not emit error surface wiring when error_surface is not enabled" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      error_surface: false,
      error_surface_html: { id: "customer_lookup_error_surface" }
    )

    expect(html).not_to include("customer_lookup_error_surface")
    expect(html).not_to include("data-rails-fields-kit--tom-select-error-surface-id-value")
  end
end
