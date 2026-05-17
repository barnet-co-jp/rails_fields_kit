# frozen_string_literal: true

RSpec.describe "Rails Fields Kit selected preload" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  SelectedPreloadModel = Struct.new(:customer_id, :tag_ids) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "SelectedPreloadModel")
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

  def form_builder(model = SelectedPreloadModel.new(1, [1, 2]), object_name = :selected_preload_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders selected preload data attributes for comboboxes" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected_url: "/customers/selected.json",
      selected_param: "customer_id",
      value_field: "id",
      label_field: "name"
    )

    expect(html).to include("data-rails-fields-kit--tom-select-selected-url-value=\"/customers/selected.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-selected-param-value=\"customer_id\"")
    expect(html).to include("data-rails-fields-kit--tom-select-selected-multiple-param-value=\"ids\"")
  end

  it "renders selected preload data attributes for multiple fields" do
    html = form_builder.rfk_tags(
      :tag_ids,
      url: "/tags.json",
      selected_url: "/tags/selected.json",
      selected_multiple_param: "tag_ids"
    )

    expect(html).to include("data-rails-fields-kit--tom-select-selected-url-value=\"/tags/selected.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-selected-param-value=\"id\"")
    expect(html).to include("data-rails-fields-kit--tom-select-selected-multiple-param-value=\"tag_ids\"")
  end

  it "uses configured selected preload parameter defaults" do
    RailsFieldsKit.configure do |config|
      config.default_selected_param = "record_id"
      config.default_selected_multiple_param = "record_ids"
    end

    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected_url: "/customers/selected.json"
    )

    expect(html).to include("data-rails-fields-kit--tom-select-selected-param-value=\"record_id\"")
    expect(html).to include("data-rails-fields-kit--tom-select-selected-multiple-param-value=\"record_ids\"")
  end
end
