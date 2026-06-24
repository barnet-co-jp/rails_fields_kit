# frozen_string_literal: true

require "spec_helper"

RSpec.describe "native radio button wrapper helper" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  RadioButtonModel = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "RadioButtonModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  RadioButtonErrorModel = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "RadioButtonErrorModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end

    def errors
      { status: ["must be selected"] }
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder(model = RadioButtonModel.new("published"), object_name = :radio_button_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps Rails radio_button value, checked state, and same-name group behavior" do
    builder = form_builder
    draft_html = builder.rfk_radio_button(:status, "draft")
    published_html = builder.rfk_radio_button(:status, "published")

    expect(draft_html).to include("type=\"radio\"")
    expect(draft_html).to include("name=\"radio_button_model[status]\"")
    expect(draft_html).to include("id=\"radio_button_model_status_draft\"")
    expect(draft_html).to include("value=\"draft\"")
    expect(draft_html).not_to include("checked=\"checked\"")

    expect(published_html).to include("type=\"radio\"")
    expect(published_html).to include("name=\"radio_button_model[status]\"")
    expect(published_html).to include("id=\"radio_button_model_status_published\"")
    expect(published_html).to include("value=\"published\"")
    expect(published_html).to include("checked=\"checked\"")
  end

  it "passes custom radio options through to the Rails helper" do
    html = form_builder.rfk_radio_button(
      :status,
      "archived",
      checked: true,
      disabled: true,
      html: { data: { role: "status-radio" } }
    )

    expect(html).to include("value=\"archived\"")
    expect(html).to include("checked=\"checked\"")
    expect(html).to include("disabled=\"disabled\"")
    expect(html).to include("data-role=\"status-radio\"")
  end

  it "uses wrapper label, hint, error, and accessibility wiring for a single radio control" do
    html = form_builder(RadioButtonErrorModel.new(nil), :radio_button_error_model).rfk_radio_button(
      :status,
      "published",
      wrapper: true,
      label: "Published",
      hint: "Choose one status option",
      required: true,
      html: { aria: { describedby: "host_hint" } }
    )

    expect(html).to include("class=\"rfk-field rfk-field--error\"")
    expect(html).to include("for=\"radio_button_error_model_status_published\"")
    expect(html).to include("Published</label>")
    expect(html).to include("id=\"radio_button_error_model_status_hint\"")
    expect(html).to include("Choose one status option")
    expect(html).to include("id=\"radio_button_error_model_status_error\"")
    expect(html).to include("must be selected")
    expect(html).to include("aria-describedby=\"host_hint radio_button_error_model_status_hint radio_button_error_model_status_error\"")
    expect(html).to include("aria-invalid=\"true\"")
    expect(html).to include("aria-required=\"true\"")
  end
end
