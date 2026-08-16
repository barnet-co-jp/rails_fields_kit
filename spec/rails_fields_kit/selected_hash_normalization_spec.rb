# frozen_string_literal: true

RSpec.describe "RailsFieldsKit selected hash normalization" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  SelectedHashModel = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "SelectedHashModel")
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

  def form_builder(model = SelectedHashModel.new(nil))
    ActionView::Helpers::FormBuilder.new(:selected_hash_model, model, self, {})
  end

  it "preloads zero values from explicit value and id hash keys" do
    value_html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected: { value: 0, text: "Zero value" }
    )
    id_html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected: { id: 0, name: "Zero id" }
    )

    expect(value_html).to include("<option selected=\"selected\" value=\"0\">Zero value</option>")
    expect(id_html).to include("<option selected=\"selected\" value=\"0\">Zero id</option>")
  end

  it "keeps explicit false as a selected value and label" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected: { value: false, text: false }
    )

    expect(html).to include("<option selected=\"selected\" value=\"false\">false</option>")
  end

  it "continues to fall back past nil selected hash keys" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected: { value: nil, id: "fallback", text: nil, name: "Fallback label" }
    )

    expect(html).to include("<option selected=\"selected\" value=\"fallback\">Fallback label</option>")
  end
end
