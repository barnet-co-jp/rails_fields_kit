# frozen_string_literal: true

RSpec.describe RailsFieldsKit::FormBuilder do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  DummyModel = Struct.new(:status, :customer_id, :tag_ids, :keyword) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "DummyModel")
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
    model = DummyModel.new("draft", nil, [], nil)
    ActionView::Helpers::FormBuilder.new(:dummy_model, model, self, {})
  end

  it "renders a Tom Select backed select field" do
    html = form_builder.rfk_select(:status, collection: { "Draft" => "draft" })

    expect(html).to include("select")
    expect(html).to include("rails-fields-kit--tom-select")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"select\"")
    expect(html).to include("<option value=\"draft\" selected=\"selected\">Draft</option>")
  end

  it "renders a remote editable combobox" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      create_url: "/customers",
      placeholder: "Search or create a customer"
    )

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"combobox\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/customers.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-url-value=\"/customers\"")
    expect(html).to include("placeholder=\"Search or create a customer\"")
  end

  it "renders tags as a multiple select" do
    html = form_builder.rfk_tags(:tag_ids, collection: [["Urgent", 1]])

    expect(html).to include("multiple=\"multiple\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"tags\"")
  end

  it "renders autocomplete as a free text field" do
    html = form_builder.rfk_autocomplete(:keyword, url: "/suggestions.json")

    expect(html).to include("type=\"text\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"autocomplete\"")
    expect(html).to include("data-rails-fields-kit--tom-select-free-text-value=\"true\"")
  end
end
