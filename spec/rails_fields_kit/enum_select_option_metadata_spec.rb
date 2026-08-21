# frozen_string_literal: true

require "spec_helper"

RSpec.describe "rfk_enum_select option metadata" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  EnumOptionMetadataModel = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "EnumOptionMetadataModel")
    end

    def self.statuses
      { "draft" => 0, "published" => 1, "archived" => 2 }
    end

    def self.human_attribute_name(attribute, options = {})
      translations = {
        "status.draft" => "Draft label",
        "status.published" => "Published label",
        "status.archived" => "Archived label"
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

  def form_builder(model = EnumOptionMetadataModel.new("draft"))
    ActionView::Helpers::FormBuilder.new(:enum_option_metadata_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "disables enum keys without changing submitted values" do
    html = form_builder.rfk_enum_select(:status, disabled: ["published"])

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"enum_select\"")
    expect(html).to include("value=\"draft\"")
    expect(html).to include(">Draft label</option>")
    expect(html).to include("value=\"published\" disabled=\"disabled\"").or include("disabled=\"disabled\" value=\"published\"")
    expect(html).to include(">Published label</option>")
  end

  it "passes option_html only to the matching enum key option" do
    html = form_builder.rfk_enum_select(
      :status,
      option_html: {
        "draft" => { class: "is-muted", data: { state: "initial" } }
      }
    )

    expect(html).to include("value=\"draft\"")
    expect(html).to include("class=\"is-muted\"")
    expect(html).to include("data-state=\"initial\"")
    expect(html).to include("value=\"published\"")
    expect(html).not_to include("data-state=\"published\"")
  end

  it "keeps explicit enum hash keys as values when option metadata is present" do
    html = form_builder.rfk_enum_select(
      :status,
      enum: { "draft" => 0, "published" => 1 },
      disabled: ["draft"],
      option_html: {
        "published" => { data: { qa: "enum-published" } }
      }
    )

    expect(html).to include("<option disabled=\"disabled\" selected=\"selected\" value=\"draft\">Draft label</option>")
    expect(html).to include("value=\"published\"")
    expect(html).to include("data-qa=\"enum-published\"")
    expect(html).to include(">Published label</option>")
    expect(html).not_to include("<option value=\"0\"")
    expect(html).not_to include("<option value=\"1\"")
  end
end
