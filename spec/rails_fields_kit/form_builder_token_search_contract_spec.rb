# frozen_string_literal: true

require "spec_helper"

RSpec.describe "rfk_token_search defaults" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  TokenSearchContractModel = Struct.new(:query) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "TokenSearchContractModel")
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

  def form_builder(model = TokenSearchContractModel.new(nil), object_name = :token_search_contract_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps the documented defaults for token search" do
    html = form_builder.rfk_token_search(
      :query,
      url: "/search_token_suggestions.json",
      placeholder: "status:open keyword"
    )

    expect(html).to include("type=\"text\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"token_search\"")
    expect(html).to include("data-rails-fields-kit--tom-select-free-text-value=\"true\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-value=\"true\"")
    expect(html).to include("data-rails-fields-kit--tom-select-persist-value=\"false\"")
    expect(html).to include("data-rails-fields-kit--tom-select-delimiter-value=\" \"")
    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;remove_button&quot;]\"")
  end

  it "lets callers override the documented defaults explicitly" do
    html = form_builder.rfk_token_search(
      :query,
      url: "/search_token_suggestions.json",
      free_text: false,
      create: false,
      persist: true,
      delimiter: ",",
      plugins: ["dropdown_input"]
    )

    expect(html).to include("data-rails-fields-kit--tom-select-free-text-value=\"false\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-value=\"false\"")
    expect(html).to include("data-rails-fields-kit--tom-select-persist-value=\"true\"")
    expect(html).to include("data-rails-fields-kit--tom-select-delimiter-value=\",\"")
    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;dropdown_input&quot;]\"")
  end
end
