# frozen_string_literal: true

RSpec.describe "table metadata field type drift" do
  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "keeps TableFilterInput known types aligned with default renderer helpers" do
    known_types = RailsFieldsKit::TableFilterInput.known_types.map(&:to_s).sort
    helper_types = RailsFieldsKit::TableRenderer.field_helpers.keys.sort

    expect(known_types - helper_types).to eq([]),
      "expected every TableFilterInput known type to have a default TableRenderer helper mapping"
    expect(helper_types - known_types).to eq([]),
      "expected every default TableRenderer helper mapping to be exposed as a TableFilterInput known type"
  end

  it "keeps every known table filter type renderable through its default helper" do
    RailsFieldsKit::TableFilterInput.known_types.each do |field_type|
      field_type = field_type.to_s
      call = RailsFieldsKit::TableRenderer.filter_call(
        field_type: field_type,
        method: :query,
        options: {}
      )

      expect(call).to eq(
        helper: RailsFieldsKit::TableRenderer.field_helpers.fetch(field_type),
        method: :query,
        options: {}
      )
    end
  end
end
