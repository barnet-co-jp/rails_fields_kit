# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table known field types" do
  it "returns duplicated known filter field types" do
    known_types = RailsFieldsKit::TableFilterInput.known_types
    known_types.clear

    expect(RailsFieldsKit::TableFilterInput.known_types).to include(:combobox, :token_search)
    expect(RailsFieldsKit::TableFilterInput.known_type?(:combobox)).to be(true)
  end

  it "returns duplicated known cell editor field types" do
    known_types = RailsFieldsKit::TableCellInput.known_types
    known_types.clear

    expect(RailsFieldsKit::TableCellInput.known_types).to include(:combobox, :token_search)
    expect(RailsFieldsKit::TableCellInput.known_type?(:combobox)).to be(true)
  end
end