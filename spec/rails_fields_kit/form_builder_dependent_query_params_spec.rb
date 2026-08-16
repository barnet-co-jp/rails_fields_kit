# frozen_string_literal: true

require "spec_helper"

RSpec.describe "FormBuilder dependent query params" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  DependentQueryModel = Struct.new(:product_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "DependentQueryModel")
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
    ActionView::Helpers::FormBuilder.new(:dependent_query_model, DependentQueryModel.new, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders dependent query params data values for remote combobox helpers" do
    html = form_builder.rfk_combobox(
      :product_id,
      url: "/products.json",
      query_params: { scope: "active" },
      depends_on: {
        category: "#detail-category",
        account_item_id: "#detail-account-item"
      },
      clear_on_dependency_change: true
    )

    expect(html).to include('data-rails-fields-kit--tom-select-query-params-value="{&quot;scope&quot;:&quot;active&quot;}"')
    expect(html).to include('data-rails-fields-kit--tom-select-depends-on-value="{&quot;category&quot;:&quot;#detail-category&quot;,&quot;account_item_id&quot;:&quot;#detail-account-item&quot;}"')
    expect(html).to include('data-rails-fields-kit--tom-select-clear-on-dependency-change-value="true"')
  end

  it "keeps the existing selection by default when dependency clearing is not requested" do
    html = form_builder.rfk_autocomplete(
      :product_id,
      url: "/products.json",
      depends_on: { category: "#detail-category" }
    )

    expect(html).to include('data-rails-fields-kit--tom-select-depends-on-value="{&quot;category&quot;:&quot;#detail-category&quot;}"')
    expect(html).not_to include("data-rails-fields-kit--tom-select-clear-on-dependency-change-value")
  end
end
