# frozen_string_literal: true

RSpec.describe "option_html Proc context" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  OptionContextModel = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "OptionContextModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  OptionContextCustomer = Struct.new(:uuid, :display_name, :segment)

  def protect_against_forgery?
    false
  end

  def option_context_form_builder(model = OptionContextModel.new(nil))
    ActionView::Helpers::FormBuilder.new(:option_context_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps one-argument option_html procs value-only" do
    seen_values = []

    html = option_context_form_builder.rfk_select(
      :customer_id,
      collection: [OptionContextCustomer.new("c-1", "Acme Corp", "enterprise")],
      collection_value_method: :uuid,
      collection_label_method: :display_name,
      option_html: ->(value) {
        seen_values << value
        { data: { value_only: value } }
      }
    )

    expect(seen_values).to eq(["c-1"])
    expect(html).to include("data-value-only=\"c-1\"")
    expect(html).to include(">Acme Corp</option>")
  end

  it "passes value, label, and source item to record-backed collection procs" do
    customer = OptionContextCustomer.new("c-1", "Acme Corp", "enterprise")
    seen_context = []

    html = option_context_form_builder.rfk_select(
      :customer_id,
      collection: [customer],
      collection_value_method: :uuid,
      collection_label_method: :display_name,
      option_html: ->(value, label, item) {
        seen_context << [value, label, item]
        { data: { segment: item.segment, label: label } }
      }
    )

    expect(seen_context).to eq([["c-1", "Acme Corp", customer]])
    expect(html).to include("data-segment=\"enterprise\"")
    expect(html).to include("data-label=\"Acme Corp\"")
  end

  it "passes value and label with nil item for hash and pair collections" do
    seen_context = []
    option_html = ->(value, label, item) {
      seen_context << [value, label, item]
      { data: { label: label, item: item.nil? ? "none" : "present" } }
    }

    hash_html = option_context_form_builder.rfk_select(
      :customer_id,
      collection: { "Hash label" => "hash-value" },
      option_html: option_html
    )
    pair_html = option_context_form_builder.rfk_select(
      :customer_id,
      collection: [["Pair label", "pair-value"]],
      option_html: option_html
    )

    expect(seen_context).to eq([
      ["hash-value", "Hash label", nil],
      ["pair-value", "Pair label", nil]
    ])
    expect(hash_html).to include("data-label=\"Hash label\"")
    expect(hash_html).to include("data-item=\"none\"")
    expect(pair_html).to include("data-label=\"Pair label\"")
    expect(pair_html).to include("data-item=\"none\"")
  end

  it "keeps hash option_html and disabled option behavior" do
    html = option_context_form_builder.rfk_select(
      :customer_id,
      collection: { "Draft" => "draft", "Published" => "published" },
      disabled: ["published"],
      option_html: {
        "draft" => { data: { color: "gray" } }
      }
    )

    expect(html).to include("data-color=\"gray\"")
    expect(html).to include("value=\"published\" disabled=\"disabled\"").or include("disabled=\"disabled\" value=\"published\"")
  end
end
