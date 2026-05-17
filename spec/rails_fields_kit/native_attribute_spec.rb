# frozen_string_literal: true

RSpec.describe "Rails Fields Kit native attributes" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  NativeAttributeModel = Struct.new(:status, :customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "NativeAttributeModel")
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

  def form_builder(model = NativeAttributeModel.new(nil, nil), object_name = :native_attribute_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "promotes native attributes to Tom Select backed selects" do
    html = form_builder.rfk_select(
      :status,
      collection: { "Draft" => "draft" },
      required: true,
      disabled: true,
      autocomplete: "off"
    )

    expect(html).to include("required=\"required\"")
    expect(html).to include("disabled=\"disabled\"")
    expect(html).to include("autocomplete=\"off\"")
  end

  it "adds aria-required when a wrapped required field is accessible" do
    html = form_builder.rfk_select(
      :customer_id,
      collection: { "Acme" => 1 },
      wrapper: true,
      hint: "Required customer",
      required: true
    )

    expect(html).to include("required=\"required\"")
    expect(html).to include("aria-required=\"true\"")
    expect(html).to include("aria-describedby=\"native_attribute_model_customer_id_hint\"")
  end

  it "promotes readonly to autocomplete text inputs" do
    html = form_builder.rfk_autocomplete(:status, url: "/statuses.json", readonly: true)

    expect(html).to include("readonly=\"readonly\"")
  end
end
