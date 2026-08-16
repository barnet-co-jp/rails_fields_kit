# frozen_string_literal: true

RSpec.describe "Native helper wrapper and accessibility contract" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  NativeHelperContractModel = Struct.new(:customer_code) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "NativeHelperContractModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  NativeHelperContractErrorModel = Struct.new(:customer_code) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "NativeHelperContractErrorModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end

    def errors
      { customer_code: ["is invalid"] }
    end
  end

  def protect_against_forgery?
    false
  end

  def build_form_builder(model, object_name = :native_helper_contract)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps the representative wrapper lane aligned with current docs" do
    html = build_form_builder(NativeHelperContractModel.new("C-001")).rfk_text_field(
      :customer_code,
      wrapper: true,
      label: "Customer code",
      hint: "Shown in the admin sidebar",
      prefix: "#",
      suffix: "required",
      required: true,
      html: { autocomplete: "off" }
    )

    expect(html).to include('class="rfk-field"')
    expect(html).to include('class="rfk-label"')
    expect(html).to include(">Customer code</label>")
    expect(html).to include('class="rfk-control"')
    expect(html).to include('class="rfk-prefix"')
    expect(html).to include(">#</span>")
    expect(html).to include('class="rfk-suffix"')
    expect(html).to include(">required</span>")
    expect(html).to include('class="rfk-hint"')
    expect(html).to include("Shown in the admin sidebar")
    expect(html).to include('autocomplete="off"')
    expect(html).to include('required="required"')
    expect(html).to include('aria-describedby="native_helper_contract_customer_code_hint"')
    expect(html).to include('aria-required="true"')
  end

  it "associates validation errors with the same wrapped native lane" do
    html = build_form_builder(NativeHelperContractErrorModel.new("bad")).rfk_text_field(
      :customer_code,
      wrapper: true,
      hint: "Shown in the admin sidebar",
      required: true
    )

    expect(html).to include('class="rfk-field rfk-field--error"').or include('class="rfk-field--error rfk-field"')
    expect(html).to include('id="native_helper_contract_customer_code_hint"')
    expect(html).to include('id="native_helper_contract_customer_code_error"')
    expect(html).to include('class="rfk-error"')
    expect(html).to include("is invalid")
    expect(html).to include('aria-describedby="native_helper_contract_customer_code_hint native_helper_contract_customer_code_error"')
    expect(html).to include('aria-invalid="true"')
    expect(html).to include('aria-required="true"')
  end

  it "keeps wrapper rendering but drops shared aria auto-wiring when accessibility is false" do
    html = build_form_builder(NativeHelperContractErrorModel.new("bad")).rfk_text_field(
      :customer_code,
      wrapper: true,
      label: "Customer code",
      hint: "Host app manages accessibility wiring",
      prefix: "#",
      accessibility: false,
      required: true
    )

    expect(html).to include('class="rfk-field rfk-field--error"').or include('class="rfk-field--error rfk-field"')
    expect(html).to include(">Customer code</label>")
    expect(html).to include("Host app manages accessibility wiring")
    expect(html).to include(">#</span>")
    expect(html).to include("is invalid")
    expect(html).not_to include('aria-describedby=')
    expect(html).not_to include('aria-invalid=')
    expect(html).not_to include('aria-required=')
  end
end
