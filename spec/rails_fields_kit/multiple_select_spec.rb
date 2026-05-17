# frozen_string_literal: true

RSpec.describe "Rails Fields Kit multiple selects" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  MultipleSelectModel = Struct.new(:tag_ids, :category_ids) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "MultipleSelectModel")
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

  def form_builder(model = MultipleSelectModel.new([], []), object_name = :multiple_select_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders tags as an array param with a hidden blank input" do
    html = form_builder.rfk_tags(:tag_ids, collection: [["Urgent", 1]])

    expect(html).to include("type=\"hidden\"")
    expect(html).to include("name=\"multiple_select_model[tag_ids][]\"")
    expect(html).to include("multiple=\"multiple\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"tags\"")
  end

  it "renders multi selects as array params" do
    html = form_builder.rfk_multi_select(:category_ids, collection: [["A", "a"], ["B", "b"]])

    expect(html).to include("type=\"hidden\"")
    expect(html).to include("name=\"multiple_select_model[category_ids][]\"")
    expect(html).to include("multiple=\"multiple\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"multi_select\"")
  end

  it "allows the hidden blank input to be disabled" do
    html = form_builder.rfk_multi_select(
      :category_ids,
      collection: [["A", "a"]],
      include_hidden: false
    )

    expect(html).not_to include("type=\"hidden\"")
    expect(html).to include("multiple=\"multiple\"")
  end
end
