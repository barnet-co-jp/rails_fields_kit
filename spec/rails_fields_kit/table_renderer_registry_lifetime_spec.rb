# frozen_string_literal: true

RSpec.describe "RailsFieldsKit::TableRenderer registry lifetime" do
  class RegistryLifetimeFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def custom_table_field(method, **options)
      calls << [:custom_table_field, method, options]
      "custom"
    end
  end

  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "keeps custom mappings global until reset_field_helpers restores the defaults" do
    RailsFieldsKit::TableRenderer.register_field_helper(:temporary_field, :custom_table_field)

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(true)
    expect(RailsFieldsKit::TableRenderer.filter_call(field_type: :temporary_field, method: :code)).to include(
      helper: :custom_table_field,
      method: :code
    )

    RailsFieldsKit::TableRenderer.reset_field_helpers!

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(false)
    expect {
      RailsFieldsKit::TableRenderer.filter_call(field_type: :temporary_field, method: :code)
    }.to raise_error(RailsFieldsKit::TableRenderer::UnknownFieldType)
  end

  it "lets a one-off registration render inside a scoped cleanup block" do
    form_builder = RegistryLifetimeFormBuilder.new

    begin
      RailsFieldsKit::TableRenderer.register_field_helper(:temporary_field, :custom_table_field)

      result = RailsFieldsKit::TableRenderer.render_filter(
        form_builder,
        field_type: :temporary_field,
        method: :code,
        options: {prefix: "#"}
      )
    ensure
      RailsFieldsKit::TableRenderer.reset_field_helpers!
    end

    expect(result).to eq("custom")
    expect(form_builder.calls).to eq([
      [:custom_table_field, :code, {prefix: "#"}]
    ])
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(false)
  end

  it "returns duplicated helper maps so callers cannot mutate the registry directly" do
    helpers = RailsFieldsKit::TableRenderer.field_helpers
    helpers["temporary_field"] = :custom_table_field

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(false)
    expect(RailsFieldsKit::TableRenderer.helper_for(:temporary_field)).to be_nil
  end
end
