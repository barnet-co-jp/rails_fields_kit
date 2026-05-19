# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableMetadata do
  class HashLikeColumn
    attr_reader :to_hash_calls

    def initialize(column)
      @column = column
      @to_hash_calls = 0
    end

    def to_hash
      @to_hash_calls += 1
      @column
    end

    def to_a
      [[:unexpected, true]]
    end
  end

  class InvalidHashLikeColumn
    def to_hash
      [[:filter, :invalid]]
    end
  end

  class HashLikeColumnTable
    attr_reader :columns

    def initialize(columns)
      @columns = columns
    end
  end

  it "collects filter metadata from hash-like columns" do
    column = HashLikeColumn.new(
      filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
    )

    expect(described_class.filters([column])).to eq([
      {
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "collects cell editor metadata from hash-like columns" do
    column = HashLikeColumn.new(
      editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
    )

    expect(described_class.cell_editors([column])).to eq([
      {
        type: "rails_fields_kit",
        field_type: "enum_select",
        method: "status",
        options: {}
      }
    ])
  end

  it "normalizes a hash-like column once per collected column" do
    column = HashLikeColumn.new(
      filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
    )

    described_class.filters([column])

    expect(column.to_hash_calls).to eq(1)
  end

  it "preserves a single hash-like column instead of expanding to_a" do
    column = HashLikeColumn.new(
      filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
    )

    expect(column.to_a).to eq([[:unexpected, true]])

    expect(described_class.filters(column)).to eq([
      {
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "collects metadata from table-like objects with a single hash-like column" do
    column = HashLikeColumn.new(
      filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
    )

    table = HashLikeColumnTable.new(column)

    expect(described_class.filter_calls(table)).to eq([
      {
        helper: :rfk_token_search,
        method: :query,
        options: { url: "/tokens.json" }
      }
    ])
  end

  it "rejects invalid hash-like columns" do
    expect {
      described_class.filters([InvalidHashLikeColumn.new])
    }.to raise_error(
      ArgumentError,
      "table column to_hash must return a hash"
    )
  end
end
