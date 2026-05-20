# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  it "duplicates field helper mappings" do
    helpers = described_class.field_helpers

    helpers[:token_search] = :mutated_helper
    helpers[:enum_select] = :another_helper

    expect(
      described_class.helper_for(:token_search)
    ).to eq(:rfk_token_search)

    expect(
      described_class.helper_for(:enum_select)
    ).to eq(:rfk_enum_select)
  end

  it "isolates helper lookup normalization from returned mappings" do
    helpers = described_class.field_helpers

    helpers[" token_search "] = :mutated_helper

    expect(
      described_class.helper_for(" token_search ")
    ).to eq(:rfk_token_search)
  end
end
