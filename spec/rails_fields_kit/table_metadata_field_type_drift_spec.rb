# frozen_string_literal: true

RSpec.describe "table metadata field type drift" do
  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "keeps TableFilterInput known types aligned with filter-capable default renderer helpers" do
    renderer_only_types = ["file_field"]
    known_types = RailsFieldsKit::TableFilterInput.known_types.map(&:to_s).sort
    helper_types = RailsFieldsKit::TableRenderer.field_helpers.keys.sort
    filter_helper_types = helper_types - renderer_only_types

    expect(known_types - filter_helper_types).to eq([]),
      "expected every TableFilterInput known type to have a default TableRenderer helper mapping"
    expect(filter_helper_types - known_types).to eq([]),
      "expected every filter-capable default TableRenderer helper mapping to be exposed as a TableFilterInput known type"
    expect(RailsFieldsKit::TableFilterInput.known_type?(:file_field)).to be(false),
      "expected file_field to stay cell-editor-only because table filters imply query semantics"
    expect(RailsFieldsKit::TableFilterInput.known_type?(:radio_button)).to be(true),
      "expected radio_button to be exposed as renderable filter control metadata"
  end

  it "keeps every known table filter type renderable through its default helper" do
    RailsFieldsKit::TableFilterInput.known_types.each do |field_type|
      field_type = field_type.to_s
      options = field_type == "radio_button" ? {tag_value: "published"} : {}
      call = RailsFieldsKit::TableRenderer.filter_call(
        field_type: field_type,
        method: :query,
        options: options
      )

      expect(call).to eq(
        helper: RailsFieldsKit::TableRenderer.field_helpers.fetch(field_type),
        method: :query,
        options: options
      )
    end
  end
end
