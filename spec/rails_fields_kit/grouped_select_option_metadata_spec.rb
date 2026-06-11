# frozen_string_literal: true

require "spec_helper"

RSpec.describe "rfk_grouped_select option metadata" do
  let(:template) { ActionView::Base.empty }
  let(:record) { Customer.new("2") }
  let(:builder) { RailsFieldsKit::FormBuilder.new(:customer, record, template, {}) }

  class Customer
    attr_accessor :customer_id

    def initialize(customer_id)
      @customer_id = customer_id
    end
  end

  it "passes disabled values through grouped choices while preserving selection" do
    html = builder.rfk_grouped_select(
      :customer_id,
      grouped_collection: [
        ["North", [["Alpha LLC", "1"], ["Beta LLC", "2"]]],
        ["South", [["Gamma LLC", "3"]]]
      ],
      disabled: ["3"]
    )

    expect(html).to include('<option selected="selected" value="2">Beta LLC</option>')
    expect(html).to include('<option disabled="disabled" value="3">Gamma LLC</option>')
    expect(html).not_to include('[&quot;Beta LLC&quot;')
  end
end
