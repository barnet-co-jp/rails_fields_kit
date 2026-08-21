# frozen_string_literal: true

RSpec.describe "rfk_enum_select rendered kind" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  EnumKindModel = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "EnumKindModel")
    end

    def self.statuses
      { "draft" => 0, "published" => 1 }
    end

    def self.human_attribute_name(attribute, options = {})
      translations = {
        "status.draft" => "Draft label",
        "status.published" => "Published label"
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

  def protect_against_forgery?
    false
  end

  def form_builder(model = EnumKindModel.new("draft"), object_name = :enum_kind_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders enum_select as the helper-lane kind without changing submitted enum keys" do
    html = form_builder.rfk_enum_select(:status)

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"enum_select\"")
    expect(html).to include("value=\"draft\"")
    expect(html).to include(">Draft label</option>")
    expect(html).to include("value=\"published\"")
    expect(html).to include(">Published label</option>")
  end
end
