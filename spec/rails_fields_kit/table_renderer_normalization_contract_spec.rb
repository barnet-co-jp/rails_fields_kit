# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  it "normalizes string field types and methods for filter calls" do
    call = described_class.filter_call(
      field_type: " token_search ",
      method: " query ",
      options: {
        url: "/tokens.json"
      }
    )

    expect(call).to eq(
      helper: :rfk_token_search,
      method: :query,
      options: {
        url: "/tokens.json"
      }
    )
  end

  it "normalizes string field types and methods for cell editor calls" do
    call = described_class.cell_editor_call(
      field_type: " enum_select ",
      method: " status ",
      options: {
        include_blank: true
      }
    )

    expect(call).to eq(
      helper: :rfk_enum_select,
      method: :status,
      options: {
        include_blank: true
      }
    )
  end

  it "normalizes registered helper lookups" do
    expect(
      described_class.helper_for(" token_search ")
    ).to eq(:rfk_token_search)

    expect(
      described_class.registered_field_type?(" enum_select ")
    ).to eq(true)
  end
end
