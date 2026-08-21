# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableMetadata do
  class DuplicationHashLikeMetadata
    def initialize(metadata)
      @metadata = metadata
    end

    def to_hash
      @metadata
    end
  end

  class DuplicationHashLikeColumn
    def initialize(column)
      @column = column
    end

    def to_hash
      @column
    end
  end

  it "duplicates collected filter metadata hashes" do
    column = {
      filter: {
        field_type: "token_search",
        method: :query,
        options: {
          url: "/tokens.json"
        }
      }
    }

    filters = described_class.filters([column])

    filters.first[:field_type] = "mutated"
    filters.first[:options][:url] = "/mutated.json"

    expect(column).to eq(
      filter: {
        field_type: "token_search",
        method: :query,
        options: {
          url: "/tokens.json"
        }
      }
    )
  end

  it "duplicates collected cell editor metadata hashes" do
    column = {
      editor: {
        field_type: "enum_select",
        method: :status,
        options: {
          include_blank: true
        }
      }
    }

    editors = described_class.cell_editors([column])

    editors.first[:field_type] = "mutated"
    editors.first[:options][:include_blank] = false

    expect(column).to eq(
      editor: {
        field_type: "enum_select",
        method: :status,
        options: {
          include_blank: true
        }
      }
    )
  end

  it "duplicates string-keyed options hashes" do
    column = {
      filter: {
        "field_type" => "token_search",
        "method" => "query",
        "options" => {
          "url" => "/tokens.json"
        }
      }
    }

    filters = described_class.filters([column])

    filters.first["options"]["url"] = "/mutated.json"

    expect(column).to eq(
      filter: {
        "field_type" => "token_search",
        "method" => "query",
        "options" => {
          "url" => "/tokens.json"
        }
      }
    )
  end

  it "duplicates hash-like metadata objects" do
    metadata = DuplicationHashLikeMetadata.new(
      field_type: "token_search",
      method: :query,
      options: {
        url: "/tokens.json"
      }
    )

    column = {
      filter: metadata
    }

    filters = described_class.filters([column])

    filters.first[:field_type] = "mutated"
    filters.first[:options][:url] = "/mutated.json"

    expect(metadata.to_hash).to eq(
      field_type: "token_search",
      method: :query,
      options: {
        url: "/tokens.json"
      }
    )
  end

  it "duplicates metadata collected from hash-like columns" do
    column = DuplicationHashLikeColumn.new(
      filter: {
        field_type: "token_search",
        method: :query,
        options: {
          url: "/tokens.json"
        }
      }
    )

    filters = described_class.filters([column])

    filters.first[:field_type] = "mutated"
    filters.first[:options][:url] = "/mutated.json"

    expect(column.to_hash).to eq(
      filter: {
        field_type: "token_search",
        method: :query,
        options: {
          url: "/tokens.json"
        }
      }
    )
  end
end
