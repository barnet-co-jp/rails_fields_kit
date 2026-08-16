# frozen_string_literal: true

RSpec.describe "RailsFieldsKit::TableRenderer.unregister_field_helper" do
  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "removes custom-only field helper mappings" do
    RailsFieldsKit::TableRenderer.register_field_helper(:custom_field, :custom_table_field)

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:custom_field)).to be(true)

    RailsFieldsKit::TableRenderer.unregister_field_helper(:custom_field)

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:custom_field)).to be(false)
    expect {
      RailsFieldsKit::TableRenderer.filter_call(field_type: "custom_field", method: :code)
    }.to raise_error(
      RailsFieldsKit::TableRenderer::UnknownFieldType,
      "unknown Rails Fields Kit table field type: custom_field"
    )
  end

  it "allows custom field helper mappings to be registered again after unregistering" do
    RailsFieldsKit::TableRenderer.register_field_helper(:custom_field, :custom_table_field)
    RailsFieldsKit::TableRenderer.unregister_field_helper(:custom_field)
    RailsFieldsKit::TableRenderer.register_field_helper(:custom_field, :custom_table_field)

    expect(RailsFieldsKit::TableRenderer.filter_call(field_type: "custom_field", method: :code)).to eq(
      helper: :custom_table_field,
      method: :code,
      options: {}
    )
  end

  it "restores built-in mappings instead of removing built-in field types" do
    RailsFieldsKit::TableRenderer.register_field_helper(:combobox, :custom_table_field)

    expect(RailsFieldsKit::TableRenderer.helper_for(:combobox)).to eq(:custom_table_field)

    RailsFieldsKit::TableRenderer.unregister_field_helper(" combobox ")

    expect(RailsFieldsKit::TableRenderer.helper_for(:combobox)).to eq(:rfk_combobox)
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:combobox)).to be(true)
    expect(RailsFieldsKit::TableRenderer.filter_call(field_type: "combobox", method: :customer_id)).to eq(
      helper: :rfk_combobox,
      method: :customer_id,
      options: {}
    )
  end

  it "does not let field_helpers snapshots mutate the registry after unregistering" do
    RailsFieldsKit::TableRenderer.register_field_helper(:custom_field, :custom_table_field)
    RailsFieldsKit::TableRenderer.unregister_field_helper(:custom_field)

    helpers = RailsFieldsKit::TableRenderer.field_helpers
    helpers["custom_field"] = :custom_table_field

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:custom_field)).to be(false)
  end

  it "rejects blank field types with the same messages as registration" do
    expect { RailsFieldsKit::TableRenderer.unregister_field_helper(nil) }.to raise_error(
      ArgumentError,
      "table field type is required"
    )

    expect { RailsFieldsKit::TableRenderer.unregister_field_helper(" ") }.to raise_error(
      ArgumentError,
      "field type is required"
    )
  end
end
