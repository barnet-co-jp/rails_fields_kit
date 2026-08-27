# frozen_string_literal: true

require "nokogiri"
require "spec_helper"

RSpec.describe "Tom Select initial state rendering" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  SelectedRecord = Struct.new(:id, :name)

  def protect_against_forgery?
    false
  end

  def scoped_form_builder(object_name = :filters)
    ActionView::Helpers::FormBuilder.new(object_name, nil, self, {})
  end

  def parsed_hidden_field(html, name)
    Nokogiri::HTML.fragment(html).at_xpath(%(.//input[@type="hidden" and @name="#{name}"]))
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "restores explicit lookup text and id without a model object" do
    html = scoped_form_builder.rfk_lookup(
      :keyword,
      id_field: :product_id,
      url: "/products.json",
      selected: { value: 42, text: "Widget 42" }
    )

    expect(html).to include('data-rails-fields-kit--tom-select-kind-value="lookup"')
    expect(html).to include('id="filters_keyword_lookup"')
    expect(parsed_hidden_field(html, "filters[keyword]")["value"]).to eq("Widget 42")
    expect(parsed_hidden_field(html, "filters[product_id]")["value"]).to eq("42")
  end

  it "keeps id-only lookup state available for selected preload" do
    html = scoped_form_builder.rfk_lookup(
      :keyword,
      id_field: :product_id,
      selected: 42,
      selected_url: "/products/selected.json"
    )

    expect(html).to include('data-rails-fields-kit--tom-select-selected-url-value="/products/selected.json"')
    expect(parsed_hidden_field(html, "filters[product_id]")["value"]).to eq("42")
    expect(parsed_hidden_field(html, "filters[keyword]")["value"].to_s).to eq("")
  end

  it "ignores an invalid scalar selected value for a static collection" do
    html = scoped_form_builder.rfk_select(
      :status,
      collection: [["Draft", "draft"]],
      selected: "missing"
    )

    expect(html).to include('<option value="draft">Draft</option>')
    expect(html).not_to include('value="missing"')
  end

  it "keeps an explicit value and label pair outside a static collection" do
    html = scoped_form_builder.rfk_select(
      :status,
      collection: [["Draft", "draft"]],
      selected: { value: "missing", text: "Known missing record" }
    )

    expect(html).to include('<option selected="selected" value="missing">Known missing record</option>')
  end

  it "marks an id-only selected option as pending when selected_url can hydrate it" do
    html = scoped_form_builder.rfk_combobox(
      :customer_id,
      collection: [["Known customer", "1"]],
      selected: "42",
      selected_url: "/customers/selected.json"
    )

    expect(html).to include('data-rfk-selected-label-pending="true"')
    expect(html).to include('<option data-rfk-selected-label-pending="true" selected="selected" value="42">42</option>')
  end

  it "preserves option_html value label and item context while marking pending selections" do
    record = SelectedRecord.new(1, "Known customer")
    observed = []

    html = scoped_form_builder.rfk_combobox(
      :customer_id,
      collection: [record],
      collection_value_method: :id,
      collection_label_method: :name,
      selected: 42,
      selected_url: "/customers/selected.json",
      option_html: lambda do |value, label, item|
        observed << [value, label, item]
        { data: { source: item&.name || "pending" } }
      end
    )

    expect(observed).to include([1, "Known customer", record])
    expect(html).to include('data-source="Known customer"')
    expect(html).to include('data-source="pending"')
    expect(html).to include('data-rfk-selected-label-pending="true"')
  end

  it "renders a native blank option for placeholder text before Tom Select connects" do
    html = scoped_form_builder.rfk_select(
      :status,
      collection: [["Draft", "draft"]],
      placeholder: "Choose status"
    )

    expect(html).to include('<option value="">Choose status</option>')
    expect(html).to include('data-rails-fields-kit--tom-select-placeholder-value="Choose status"')
    expect(html).to include('placeholder="Choose status"')
  end
end
