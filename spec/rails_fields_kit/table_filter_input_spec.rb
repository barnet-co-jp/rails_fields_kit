# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableFilterInput do
  it "builds radio button filter metadata" do
    metadata = described_class.radio_button(:status, tag_value: "published", label: "Published")

    expect(metadata.to_table_filter).to eq(
      type: "rails_fields_kit",
      field_type: "radio_button",
      method: "status",
      options: {
        tag_value: "published",
        label: "Published"
      }
    )
  end

  it "includes radio button in known filter types" do
    expect(described_class.known_type?(:radio_button)).to be(true)
    expect(described_class.known_type?(" radio_button ")).to be(true)
    expect(described_class.known_types).to include(:radio_button)
  end
end
