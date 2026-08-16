# frozen_string_literal: true

RSpec.describe "password field table metadata" do
  class FakePasswordFieldFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_password_field(method, **options)
      calls << [:rfk_password_field, method, options]
      "password_field"
    end
  end

  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "exposes password_field as built-in filter metadata" do
    filter = RailsFieldsKit::TableFilterInput.password_field(:admin_password, autocomplete: "current-password")

    expect(RailsFieldsKit::TableFilterInput.known_type?(:password_field)).to be(true)
    expect(RailsFieldsKit::TableFilterInput.known_types).to include(:password_field)
    expect(filter.to_table_filter).to eq(
      type: "rails_fields_kit",
      field_type: "password_field",
      method: "admin_password",
      options: {autocomplete: "current-password"}
    )
  end

  it "exposes password_field as built-in cell editor metadata" do
    editor = RailsFieldsKit::TableCellInput.password_field(:api_secret, autocomplete: "new-password")

    expect(RailsFieldsKit::TableCellInput.known_type?(" password_field ")).to be(true)
    expect(RailsFieldsKit::TableCellInput.known_types).to include(:password_field)
    expect(editor.to_table_cell_editor).to eq(
      type: "rails_fields_kit",
      field_type: "password_field",
      method: "api_secret",
      options: {autocomplete: "new-password"}
    )
  end

  it "maps password_field table metadata to the native password helper" do
    expect(RailsFieldsKit::TableRenderer.helper_for(:password_field)).to eq(:rfk_password_field)
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:password_field)).to be(true)

    expect(
      RailsFieldsKit::TableRenderer.filter_call(
        RailsFieldsKit::TableFilterInput.password_field(:admin_password, autocomplete: "current-password")
      )
    ).to eq(
      helper: :rfk_password_field,
      method: :admin_password,
      options: {autocomplete: "current-password"}
    )
  end

  it "renders password_field metadata through the registered helper" do
    form_builder = FakePasswordFieldFormBuilder.new
    editor = RailsFieldsKit::TableCellInput.password_field(:api_secret, autocomplete: "new-password")

    expect(RailsFieldsKit::TableRenderer.render_cell_editor(form_builder, editor)).to eq("password_field")
    expect(form_builder.calls).to eq([
      [:rfk_password_field, :api_secret, {autocomplete: "new-password"}]
    ])
  end
end
