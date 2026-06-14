# frozen_string_literal: true

require "date"

RSpec.describe "native date/time/color FormBuilder helpers" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  NativeFieldModel = Struct.new(:starts_on, :starts_at, :accent_color) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "NativeFieldModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  ErrorNativeFieldModel = Struct.new(:starts_on) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "ErrorNativeFieldModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end

    def errors
      { starts_on: ["is required"] }
    end
  end

  def protect_against_forgery?
    false
  end

  def native_form_builder(model = NativeFieldModel.new(Date.new(2026, 6, 15), Time.new(2026, 6, 15, 9, 30, 0), "#336699"), object_name = :native_field_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders date, time, datetime-local, and color inputs through the native wrapper lane" do
    builder = native_form_builder

    date_html = builder.rfk_date_field(:starts_on, min: Date.new(2026, 1, 1), max: Date.new(2026, 12, 31))
    time_html = builder.rfk_time_field(:starts_at, step: 900)
    datetime_html = builder.rfk_datetime_local_field(:starts_at, min: Time.new(2026, 6, 1, 0, 0, 0))
    color_html = builder.rfk_color_field(:accent_color)

    expect(date_html).to include("type=\"date\"")
    expect(date_html).to include("value=\"2026-06-15\"")
    expect(date_html).to include("min=\"2026-01-01\"")
    expect(date_html).to include("max=\"2026-12-31\"")
    expect(time_html).to include("type=\"time\"")
    expect(time_html).to include("step=\"900\"")
    expect(datetime_html).to include("type=\"datetime-local\"")
    expect(datetime_html).to include("min=\"2026-06-01T00:00:00\"")
    expect(color_html).to include("type=\"color\"")
    expect(color_html).to include("value=\"#336699\"")
  end

  it "shares wrapper, hint, error, and accessibility wiring with other native helpers" do
    html = native_form_builder(ErrorNativeFieldModel.new(nil), :error_native_field_model).rfk_date_field(
      :starts_on,
      wrapper: true,
      label: "Start date",
      hint: "Use the browser-native date picker",
      required: true
    )

    expect(html).to include("class=\"rfk-field rfk-field--error\"")
    expect(html).to include("Start date</label>")
    expect(html).to include("Use the browser-native date picker")
    expect(html).to include("type=\"date\"")
    expect(html).to include("aria-describedby=\"error_native_field_model_starts_on_hint error_native_field_model_starts_on_error\"")
    expect(html).to include("aria-invalid=\"true\"")
    expect(html).to include("aria-required=\"true\"")
    expect(html).to include("is required")
  end
end
