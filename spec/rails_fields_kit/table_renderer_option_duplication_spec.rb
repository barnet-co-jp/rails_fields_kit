# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  it "duplicates filter call options hashes" do
    metadata = {
      field_type: "token_search",
      method: :query,
      options: {
        url: "/tokens.json"
      }
    }

    call = described_class.filter_call(metadata)

    call[:options][:url] = "/mutated.json"
    call[:options][:placeholder] = "Changed"

    expect(metadata).to eq(
      field_type: "token_search",
      method: :query,
      options: {
        url: "/tokens.json"
      }
    )
  end

  it "duplicates cell editor call options hashes" do
    metadata = {
      field_type: "enum_select",
      method: :status,
      options: {
        include_blank: true
      }
    }

    call = described_class.cell_editor_call(metadata)

    call[:options][:include_blank] = false
    call[:options][:prompt] = "Changed"

    expect(metadata).to eq(
      field_type: "enum_select",
      method: :status,
      options: {
        include_blank: true
      }
    )
  end
end
