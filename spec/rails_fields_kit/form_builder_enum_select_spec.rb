# frozen_string_literal: true

RSpec.describe "RailsFieldsKit::FormBuilder rfk_enum_select explicit enum boundary" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  ModelBackedEnum = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "ModelBackedEnum")
    end

    def self.statuses
      { "draft" => 0, "published" => 1 }
    end

    def self.human_attribute_name(attribute, options = {})
      translations = {
        "status.draft" => "Draft label",
        "status.published" => "Published label",
        "status/draft" => "Draft slash label",
        "status/published" => "Published slash label"
      }
      translations.fetch(attribute.to_s, options[:default] || attribute.to_s.humanize)
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  PlainSearchForm = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "PlainSearchForm")
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

  def form_builder(model, object_name)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps the model-backed enum fallback and model label path" do
    html = form_builder(ModelBackedEnum.new("draft"), :model_backed_enum).rfk_enum_select(:status)

    expect(html).to include("value=\"draft\"")
    expect(html).to include(">Draft label</option>")
    expect(html).to include("value=\"published\"")
    expect(html).to include(">Published label</option>")
  end

  it "allows the enum i18n key path to be configured without overriding FormBuilder internals" do
    RailsFieldsKit.configure do |config|
      config.enum_i18n_key = ->(method, value) { "#{method}/#{value}" }
    end

    html = form_builder(ModelBackedEnum.new("draft"), :model_backed_enum).rfk_enum_select(:status)

    expect(html).to include(">Draft slash label</option>")
    expect(html).to include(">Published slash label</option>")
  end

  it "rejects a non-callable enum i18n key configuration" do
    expect do
      RailsFieldsKit.configure { |config| config.enum_i18n_key = "status/value" }
    end.to raise_error(ArgumentError, "enum_i18n_key must respond to #call")
  end

  it "uses explicit enum values without requiring a pluralized enum method" do
    html = form_builder(PlainSearchForm.new("archived"), :search).rfk_enum_select(
      :status,
      enum: { "draft" => 0, "archived" => 1 }
    )

    expect(html).to include("name=\"search[status]\"")
    expect(html).to include("value=\"draft\"")
    expect(html).to include(">Draft</option>")
    expect(html).to include("value=\"archived\"")
    expect(html).to include(">Archived</option>")
  end

  it "allows explicit enum values when the form has no object" do
    html = form_builder(nil, :search).rfk_enum_select(
      :status,
      enum: { "needs_review" => "needs_review", "approved" => "approved" }
    )

    expect(html).to include("name=\"search[status]\"")
    expect(html).to include("value=\"needs_review\"")
    expect(html).to include(">Needs review</option>")
    expect(html).to include("value=\"approved\"")
    expect(html).to include(">Approved</option>")
  end
end
