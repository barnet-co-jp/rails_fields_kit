# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  class DuplicationHashLikeOptions
    def initialize(options)
      @options = options
    end

    def to_hash
      @options
    end
  end

  it "duplicates hash-like filter options objects" do
    options = DuplicationHashLikeOptions.new(
      url: "/tokens.json"
    )

    call = described_class.filter_call(
      field_type: "token_search",
      method: :query,
      options: options
    )

    call[:options][:url] = "/mutated.json"

    expect(options.to_hash).to eq(
      url: "/tokens.json"
    )
  end

  it "duplicates hash-like cell editor options objects" do
    options = DuplicationHashLikeOptions.new(
      include_blank: true
    )

    call = described_class.cell_editor_call(
      field_type: "enum_select",
      method: :status,
      options: options
    )

    call[:options][:include_blank] = false

    expect(options.to_hash).to eq(
      include_blank: true
    )
  end
end
