# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableMetadata do
  class ObjectAndHashLikeColumn
    attr_reader :to_hash_calls

    def initialize(filter)
      @filter = filter
      @to_hash_calls = 0
    end

    def filter
      @filter
    end

    def to_hash
      @to_hash_calls += 1

      {
        filter: RailsFieldsKit::TableFilterInput.search_field(:unexpected)
      }
    end
  end

  class ObjectAndHashLikeEditorColumn
    attr_reader :to_hash_calls

    def initialize(editor)
      @editor = editor
      @to_hash_calls = 0
    end

    def editor
      @editor
    end

    def to_hash
      @to_hash_calls += 1

      {
        editor: RailsFieldsKit::TableCellInput.combobox(:unexpected)
      }
    end
  end

  it "prefers object metadata readers before hash-like normalization" do
    expected_filter = RailsFieldsKit::TableFilterInput.token_search(
      :query,
      url: "/tokens.json"
    )

    column = ObjectAndHashLikeColumn.new(expected_filter)

    expect(described_class.filters([column])).to eq([
      {
        type: "rails_fields_kit",
        field_type: "token_search",
        method: "query",
        options: { url: "/tokens.json" }
      }
    ])

    expect(column.to_hash_calls).to eq(0)
  end

  it "prefers object cell editor readers before hash-like normalization" do
    expected_editor = RailsFieldsKit::TableCellInput.enum_select(:status)

    column = ObjectAndHashLikeEditorColumn.new(expected_editor)

    expect(described_class.cell_editors([column])).to eq([
      {
        type: "rails_fields_kit",
        field_type: "enum_select",
        method: "status",
        options: {}
      }
    ])

    expect(column.to_hash_calls).to eq(0)
  end
end
