# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer, ".registered_field_types" do
  around do |example|
    described_class.reset_field_helpers!
    example.run
    described_class.reset_field_helpers!
  end

  it "lists built-in renderable field types without exposing helper names" do
    expect(described_class.registered_field_types).to include(
      "select",
      "combobox",
      "token_search",
      "text_field",
      "search_field"
    )
    expect(described_class.registered_field_types).not_to include(:rfk_select)
  end

  it "includes custom registered field types and returns a mutation-safe list" do
    described_class.register_field_helper(" custom_field ", :custom_table_field)

    field_types = described_class.registered_field_types
    field_types << "mutated_field"

    expect(field_types).to include("custom_field")
    expect(described_class.registered_field_types).to include("custom_field")
    expect(described_class.registered_field_types).not_to include("mutated_field")
  end

  it "returns to the built-in type list after registry reset" do
    described_class.register_field_helper(:custom_field, :custom_table_field)
    described_class.reset_field_helpers!

    expect(described_class.registered_field_types).not_to include("custom_field")
    expect(described_class.registered_field_types).to include("select")
  end
end
