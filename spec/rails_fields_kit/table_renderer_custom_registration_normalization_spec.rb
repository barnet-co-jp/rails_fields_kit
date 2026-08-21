# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  after do
    described_class.reset_field_helpers!
  end

  it "normalizes custom field helper registrations" do
    described_class.register_field_helper(
      " custom_token_search ",
      " custom_helper "
    )

    expect(
      described_class.helper_for(:custom_token_search)
    ).to eq(:custom_helper)

    expect(
      described_class.helper_for(" custom_token_search ")
    ).to eq(:custom_helper)
  end

  it "does not mutate normalized custom helper registrations through field_helpers" do
    described_class.register_field_helper(
      :custom_token_search,
      :custom_helper
    )

    helpers = described_class.field_helpers
    helpers[:custom_token_search] = :mutated

    expect(
      described_class.helper_for(:custom_token_search)
    ).to eq(:custom_helper)
  end
end
