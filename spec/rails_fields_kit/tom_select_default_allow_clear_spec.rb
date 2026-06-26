# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select default allow clear" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  AllowClearModel = Struct.new(:status, :tag_ids) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "AllowClearModel")
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

  def form_builder(model = AllowClearModel.new("draft", []))
    ActionView::Helpers::FormBuilder.new(:allow_clear_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps clear_button absent by default" do
    html = form_builder.rfk_select(:status, collection: { "Draft" => "draft" })

    expect(html).not_to include("data-rails-fields-kit--tom-select-plugins-value")
    expect(RailsFieldsKit.configuration.default_allow_clear).to eq(false)
  end

  it "adds clear_button when the app-wide default is enabled" do
    RailsFieldsKit.configure do |config|
      config.default_allow_clear = true
    end

    html = form_builder.rfk_select(:status, collection: { "Draft" => "draft" })

    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;clear_button&quot;]\"")
  end

  it "lets field-level allow_clear true add clear_button without the app-wide default" do
    html = form_builder.rfk_select(:status, collection: { "Draft" => "draft" }, allow_clear: true)

    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;clear_button&quot;]\"")
  end

  it "lets field-level allow_clear false suppress only semantic auto-add" do
    RailsFieldsKit.configure do |config|
      config.default_allow_clear = true
    end

    html = form_builder.rfk_select(:status, collection: { "Draft" => "draft" }, allow_clear: false)

    expect(html).not_to include("data-rails-fields-kit--tom-select-plugins-value")
  end

  it "does not remove an explicitly supplied clear_button plugin" do
    RailsFieldsKit.configure do |config|
      config.default_allow_clear = true
    end

    html = form_builder.rfk_select(
      :status,
      collection: { "Draft" => "draft" },
      plugins: ["clear_button"],
      allow_clear: false
    )

    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;clear_button&quot;]\"")
  end

  it "keeps explicit plugins as a replacement for default_plugins before clear_button is added" do
    RailsFieldsKit.configure do |config|
      config.default_plugins = ["dropdown_input"]
      config.default_allow_clear = true
    end

    html = form_builder.rfk_select(
      :status,
      collection: { "Draft" => "draft" },
      plugins: ["restore_on_backspace"]
    )

    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;restore_on_backspace&quot;,&quot;clear_button&quot;]\"")
    expect(html).not_to include("dropdown_input")
  end

  it "keeps tags remove_button distinct from app-wide clear_button" do
    RailsFieldsKit.configure do |config|
      config.default_allow_clear = true
    end

    html = form_builder.rfk_tags(:tag_ids, collection: { "Important" => "important" })

    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;remove_button&quot;,&quot;clear_button&quot;]\"")
  end
end
