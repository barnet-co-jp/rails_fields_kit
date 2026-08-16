# frozen_string_literal: true

RSpec.describe "Tom Select error surface accessibility contract" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def protect_against_forgery?
    false
  end

  def error_surface_contract_model_class
    @error_surface_contract_model_class ||= Class.new(Struct.new(:customer_id)) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "ErrorSurfaceContractModel")
      end

      def persisted?
        false
      end

      def to_key
        nil
      end
    end
  end

  def form_builder
    model = error_surface_contract_model_class.new(nil)
    ActionView::Helpers::FormBuilder.new(:error_surface_contract_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders the default hidden live region placeholder without visible feedback UI" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      error_surface: true
    )

    expect(html).to include("data-rails-fields-kit--tom-select-error-surface-id-value=\"error_surface_contract_model_customer_id_error_surface\"")
    expect(html).to include("aria-describedby=\"error_surface_contract_model_customer_id_error_surface\"")
    expect(html).to include("id=\"error_surface_contract_model_customer_id_error_surface\"")
    expect(html).to include("hidden=\"hidden\"")
    expect(html).to include("role=\"status\"")
    expect(html).to include("aria-live=\"polite\"")
    expect(html).to include("aria-atomic=\"true\"")
    expect(html).to include("class=\"rfk-tom-select-error-surface\"")
    expect(html).not_to include("retry")
    expect(html).not_to include("Unable to load")
  end

  it "uses explicit surface ids consistently and does not duplicate aria-describedby" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      error_surface: true,
      html: {
        aria: {
          describedby: "existing-help custom-error-surface"
        }
      },
      error_surface_html: {
        id: "custom-error-surface",
        class: "field-error",
        data: { lane: "selected-preload" }
      }
    )

    expect(html).to include("data-rails-fields-kit--tom-select-error-surface-id-value=\"custom-error-surface\"")
    expect(html).to include("aria-describedby=\"existing-help custom-error-surface\"")
    expect(html).not_to include("aria-describedby=\"existing-help custom-error-surface custom-error-surface\"")
    expect(html).to include("id=\"custom-error-surface\"")
    expect(html).to include("data-lane=\"selected-preload\"")
    expect(html).to include("class=\"field-error rfk-tom-select-error-surface\"").or include("class=\"rfk-tom-select-error-surface field-error\"")
  end

  it "keeps explicit role and aria overrides on the opt-in placeholder" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      error_surface: true,
      error_surface_html: {
        id: "assertive-error-surface",
        role: "alert",
        :"aria-live" => "assertive",
        :"aria-atomic" => false
      }
    )

    expect(html).to include("data-rails-fields-kit--tom-select-error-surface-id-value=\"assertive-error-surface\"")
    expect(html).to include("aria-describedby=\"assertive-error-surface\"")
    expect(html).to include("id=\"assertive-error-surface\"")
    expect(html).to include("role=\"alert\"")
    expect(html).to include("aria-live=\"assertive\"")
    expect(html).to include("aria-atomic=\"false\"")
    expect(html).to include("class=\"rfk-tom-select-error-surface\"")
  end
end
