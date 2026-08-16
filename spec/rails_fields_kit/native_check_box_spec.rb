# frozen_string_literal: true

RSpec.describe "native checkbox wrapper helper" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  CheckboxModel = Struct.new(:active) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "CheckboxModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  CheckboxErrorModel = Struct.new(:active) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "CheckboxErrorModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end

    def errors
      { active: ["must be accepted"] }
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder(model = CheckboxModel.new(false), object_name = :checkbox_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps the Rails check_box hidden field and default values" do
    html = form_builder.rfk_check_box(:active)

    expect(html).to include("type=\"hidden\"")
    expect(html).to include("name=\"checkbox_model[active]\"")
    expect(html).to include("value=\"0\"")
    expect(html).to include("type=\"checkbox\"")
    expect(html).to include("value=\"1\"")
  end

  it "passes custom checked and unchecked values to the Rails helper" do
    html = form_builder(CheckboxModel.new("yes")).rfk_check_box(
      :active,
      checked_value: "yes",
      unchecked_value: "no"
    )

    expect(html).to include("type=\"hidden\"")
    expect(html).to include("value=\"no\"")
    expect(html).to include("type=\"checkbox\"")
    expect(html).to include("value=\"yes\"")
    expect(html).to include("checked=\"checked\"")
  end

  it "uses the native wrapper label, hint, error, and accessibility wiring" do
    html = form_builder(CheckboxErrorModel.new(false), :checkbox_error_model).rfk_check_box(
      :active,
      wrapper: true,
      label: "Active?",
      hint: "Enable this only when ready",
      required: true,
      html: { aria: { describedby: "host_hint" } }
    )

    expect(html).to include("class=\"rfk-field rfk-field--error\"")
    expect(html).to include("Active?</label>")
    expect(html).to include("id=\"checkbox_error_model_active_hint\"")
    expect(html).to include("Enable this only when ready")
    expect(html).to include("id=\"checkbox_error_model_active_error\"")
    expect(html).to include("must be accepted")
    expect(html).to include("aria-describedby=\"host_hint checkbox_error_model_active_hint checkbox_error_model_active_error\"")
    expect(html).to include("aria-invalid=\"true\"")
    expect(html).to include("aria-required=\"true\"")
  end
end
