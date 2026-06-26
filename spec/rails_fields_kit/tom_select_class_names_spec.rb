# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select classNames field option" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  ClassNamesModel = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "ClassNamesModel")
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
    ActionView::Helpers::FormBuilder.new(:class_names_model, ClassNamesModel.new("draft"), self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders field-level Tom Select classNames as a JSON data value" do
    html = form_builder.rfk_select(
      :status,
      collection: { "Draft" => "draft" },
      tom_select_class_names: {
        control: "ts-control custom-control",
        dropdown: "ts-dropdown custom-dropdown"
      },
      wrapper: true,
      wrapper_html: { class: "host-field" }
    )

    expect(html).to include("data-rails-fields-kit--tom-select-class-names-value=\"{&quot;control&quot;:&quot;ts-control custom-control&quot;,&quot;dropdown&quot;:&quot;ts-dropdown custom-dropdown&quot;}\"")
    expect(html).to include("class=\"host-field rfk-field\"")
  end

  it "omits Tom Select classNames data when the field option is not provided" do
    html = form_builder.rfk_select(:status, collection: { "Draft" => "draft" })

    expect(html).not_to include("data-rails-fields-kit--tom-select-class-names-value")
  end
end
