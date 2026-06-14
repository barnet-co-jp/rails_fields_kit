# frozen_string_literal: true

require "spec_helper"

RSpec.describe "rfk_grouped_select option metadata" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  Customer = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "Customer")
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

  let(:record) { Customer.new("2") }
  let(:builder) { ActionView::Helpers::FormBuilder.new(:customer, record, self, {}) }

  it "passes disabled values through grouped choices with explicit selection" do
    html = builder.rfk_grouped_select(
      :customer_id,
      grouped_collection: [
        ["North", [["Alpha LLC", "1"], ["Beta LLC", "2"]]],
        ["South", [["Gamma LLC", "3"]]]
      ],
      selected: "2",
      disabled: ["3"]
    )

    expect(html).to include('<option selected="selected" value="2">Beta LLC</option>')
    expect(html).to include('<option disabled="disabled" value="3">Gamma LLC</option>')
    expect(html).not_to include('[&quot;Beta LLC&quot;')
  end
end
