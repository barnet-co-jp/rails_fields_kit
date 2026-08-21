# frozen_string_literal: true

RSpec.describe "RailsFieldsKit::FormBuilder error surface accessibility" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  ErrorSurfaceDummyModel = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "ErrorSurfaceDummyModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  ErrorSurfaceErrorModel = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "ErrorSurfaceErrorModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end

    def errors
      { status: ["is invalid"] }
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder(model = ErrorSurfaceDummyModel.new(nil), object_name = :error_surface_dummy_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  def describedby_tokens(html)
    html.match(/aria-describedby="([^"]+)"/)[1].split
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "preserves symbol keyed aria-describedby values without duplicating the error surface id" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      error_surface: true,
      html: {
        aria: {
          describedby: " custom_help   error_surface_dummy_model_customer_id_error_surface  extra_help "
        }
      }
    )

    expect(describedby_tokens(html)).to eq([
      "custom_help",
      "error_surface_dummy_model_customer_id_error_surface",
      "extra_help"
    ])
    expect(describedby_tokens(html).count("error_surface_dummy_model_customer_id_error_surface")).to eq(1)
  end

  it "preserves string keyed aria-describedby values when appending the error surface id" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      error_surface: true,
      html: {
        aria: {
          "describedby" => "custom_help extra_help"
        }
      }
    )

    expect(describedby_tokens(html)).to eq([
      "custom_help",
      "extra_help",
      "error_surface_dummy_model_customer_id_error_surface"
    ])
  end

  it "keeps wrapper hint and validation error ids with custom describedby values" do
    html = form_builder(ErrorSurfaceErrorModel.new("bad"), :error_surface_error_model).rfk_select(
      :status,
      collection: { "Bad" => "bad" },
      wrapper: true,
      hint: "Choose a valid status",
      error_surface: true,
      html: {
        aria: {
          describedby: "custom_help"
        }
      }
    )

    expect(describedby_tokens(html)).to eq([
      "custom_help",
      "error_surface_error_model_status_hint",
      "error_surface_error_model_status_error",
      "error_surface_error_model_status_error_surface"
    ])
  end

  it "keeps accessibility false scoped to wrapper-generated ids" do
    html = form_builder(ErrorSurfaceErrorModel.new("bad"), :error_surface_error_model).rfk_select(
      :status,
      collection: { "Bad" => "bad" },
      wrapper: true,
      hint: "Choose a valid status",
      accessibility: false,
      error_surface: true,
      html: {
        aria: {
          describedby: "custom_help"
        }
      }
    )

    expect(describedby_tokens(html)).to eq([
      "custom_help",
      "error_surface_error_model_status_error_surface"
    ])
    expect(html).to include("id=\"error_surface_error_model_status_hint\"")
    expect(html).to include("id=\"error_surface_error_model_status_error\"")
  end
end
