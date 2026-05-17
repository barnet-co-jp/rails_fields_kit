# frozen_string_literal: true

RSpec.describe "Rails Fields Kit accessibility" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  AccessibleModel = Struct.new(:status, :keyword) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "AccessibleModel")
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

  def form_builder(model = AccessibleModel.new("bad", nil), object_name = :accessible_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "connects wrapped hints and errors to the input" do
    html = form_builder.rfk_select(
      :status,
      collection: { "Bad" => "bad" },
      wrapper: true,
      hint: "Choose carefully"
    )

    expect(html).to include("id=\"accessible_model_status_hint\"")
    expect(html).to include("id=\"accessible_model_status_error\"")
    expect(html).to include("aria-describedby=\"accessible_model_status_hint accessible_model_status_error\"")
    expect(html).to include("aria-invalid=\"true\"")
  end

  it "connects wrapped hints to native inputs" do
    html = form_builder.rfk_text_field(:keyword, wrapper: true, hint: "Search text")

    expect(html).to include("id=\"accessible_model_keyword_hint\"")
    expect(html).to include("aria-describedby=\"accessible_model_keyword_hint\"")
  end

  it "allows accessibility automation to be disabled" do
    html = form_builder.rfk_text_field(:keyword, wrapper: true, hint: "Search text", accessibility: false)

    expect(html).to include("id=\"accessible_model_keyword_hint\"")
    expect(html).not_to include("aria-describedby=\"accessible_model_keyword_hint\"")
  end
end
