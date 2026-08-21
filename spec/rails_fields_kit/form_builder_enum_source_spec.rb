# frozen_string_literal: true

RSpec.describe "rfk_enum_select explicit enum source" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  ExplicitEnumModel = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "ExplicitEnumModel")
    end

    def self.human_attribute_name(attribute, options = {})
      translations = {
        "status.draft" => "下書き",
        "status.published" => "公開済み"
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

  def form_builder(model = ExplicitEnumModel.new("draft"))
    ActionView::Helpers::FormBuilder.new(:explicit_enum_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "uses explicit enum hash keys as submitted values while keeping model-backed labels" do
    html = form_builder.rfk_enum_select(:status, enum: { "draft" => 0, "published" => 1 })

    expect(html).to include("value=\"draft\"")
    expect(html).to include(">下書き</option>")
    expect(html).to include("value=\"published\"")
    expect(html).to include(">公開済み</option>")
    expect(html).to include("selected=\"selected\"")
  end

  it "keeps explicit enum labels on the human_attribute_name fallback path" do
    html = form_builder(ExplicitEnumModel.new("archived")).rfk_enum_select(:status, enum: { "archived" => 2 })

    expect(html).to include("value=\"archived\"")
    expect(html).to include(">Archived</option>")
  end
end
