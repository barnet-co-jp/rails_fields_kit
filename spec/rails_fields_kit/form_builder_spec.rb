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

  SelectedCustomer = Struct.new(:id, :name)

  def protect_against_forgery?
    false
  end

  def form_builder
    model = DummyModel.new("draft", nil, [], nil)
    ActionView::Helpers::FormBuilder.new(:dummy_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders a Tom Select backed select field" do
    html = form_builder.rfk_select(:status, collection: { "Draft" => "draft" })

    expect(html).to include("select")
    expect(html).to include("rails-fields-kit--tom-select")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"select\"")
    expect(html).to include("data-rails-fields-kit--tom-select-value-field-value=\"value\"")
    expect(html).to include("data-rails-fields-kit--tom-select-label-field-value=\"text\"")
    expect(html).to include("<option value=\"draft\" selected=\"selected\">Draft</option>")
  end

  it "renders a remote editable combobox" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      create_url: "/customers",
      placeholder: "Search or create a customer",
      query_param: "keyword",
      create_param: "name",
      value_field: "id",
      label_field: "name",
      search_field: "name,email",
      min_length: 2
    )

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"combobox\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/customers.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-url-value=\"/customers\"")
    expect(html).to include("data-rails-fields-kit--tom-select-query-param-value=\"keyword\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-param-value=\"name\"")
    expect(html).to include("data-rails-fields-kit--tom-select-value-field-value=\"id\"")
    expect(html).to include("data-rails-fields-kit--tom-select-label-field-value=\"name\"")
    expect(html).to include("data-rails-fields-kit--tom-select-search-field-value=\"name,email\"")
    expect(html).to include("data-rails-fields-kit--tom-select-min-length-value=\"2\"")
    expect(html).to include("placeholder=\"Search or create a customer\"")
  end

  it "preloads a selected option from a hash" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected: { value: 10, text: "Acme Corp" }
    )

    expect(html).to include("<option selected=\"selected\" value=\"10\">Acme Corp</option>")
  end

  it "preloads a selected option from an object" do
    customer = SelectedCustomer.new(20, "Beta LLC")

    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected: customer,
      value_method: :id,
      label_method: :name
    )

    expect(html).to include("<option selected=\"selected\" value=\"20\">Beta LLC</option>")
  end

  it "preloads multiple selected options without duplicating collection entries" do
    html = form_builder.rfk_tags(
      :tag_ids,
      collection: [["Urgent", 1]],
      selected: [
        { value: 1, text: "Urgent" },
        { value: 2, text: "Backlog" }
      ]
    )

    expect(html).to include("<option selected=\"selected\" value=\"2\">Backlog</option>")
    expect(html.scan("value=\"1\"").size).to eq(1)
  end

  it "renders tags as a multiple select with remove buttons" do
    html = form_builder.rfk_tags(:tag_ids, collection: [["Urgent", 1]])

    expect(html).to include("multiple=\"multiple\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"tags\"")
    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;remove_button&quot;]\"")
  end

  it "renders autocomplete as a free text field" do
    html = form_builder.rfk_autocomplete(:keyword, url: "/suggestions.json")

    expect(html).to include("type=\"text\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"autocomplete\"")
    expect(html).to include("data-rails-fields-kit--tom-select-free-text-value=\"true\"")
  end

  it "uses configured defaults" do
    RailsFieldsKit.configure do |config|
      config.default_query_param = "term"
      config.default_min_length = 3
    end

    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json")

    expect(html).to include("data-rails-fields-kit--tom-select-query-param-value=\"term\"")
    expect(html).to include("data-rails-fields-kit--tom-select-min-length-value=\"3\"")
  end
end
