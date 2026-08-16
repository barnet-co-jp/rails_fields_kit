# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  it "treats whitespace-only field types as missing" do
    expect do
      described_class.filter_call(
        field_type: "   ",
        method: :query
      )
    end.to raise_error(
      ArgumentError,
      "table metadata field_type is required"
    )
  end

  it "treats whitespace-only methods as missing" do
    expect do
      described_class.filter_call(
        field_type: :token_search,
        method: "   "
      )
    end.to raise_error(
      ArgumentError,
      "table metadata method is required"
    )
  end

  it "treats whitespace-only helper registrations as blank" do
    expect do
      described_class.register_field_helper(
        "   ",
        :custom_helper
      )
    end.to raise_error(
      ArgumentError,
      "field type is required"
    )

    expect do
      described_class.register_field_helper(
        :custom_field,
        "   "
      )
    end.to raise_error(
      ArgumentError,
      "helper name is required"
    )
  end
end
