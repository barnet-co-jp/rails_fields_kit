# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableMetadata do
  class HashLikeColumnRenderFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_token_search(method, **options)
      calls << [:rfk_token_search, method, options]
      "token_search"
    end

    def rfk_enum_select(method, **options)
      calls << [:rfk_enum_select, method, options]
      "enum_select"
    end
  end

  class HashLikeRenderColumn
    def initialize(column)
      @column = column
    end

    def to_hash
      @column
    end

    def to_a
      [[:unexpected, true]]
    end
  end

  class HashLikeRenderTable
    attr_reader :columns

    def initialize(columns)
      @columns = columns
    end
  end

  it "renders filters from a table-like object with a single hash-like column" do
    form_builder = HashLikeColumnRenderFormBuilder.new
    column = HashLikeRenderColumn.new(
      filter: RailsFieldsKit::TableFilterInput.token_search(:query, url: "/tokens.json")
    )
    table = HashLikeRenderTable.new(column)

    expect(column.to_a).to eq([[:unexpected, true]])
    expect(described_class.render_filters(form_builder, table)).to eq(["token_search"])
    expect(form_builder.calls).to eq([
      [:rfk_token_search, :query, { url: "/tokens.json" }]
    ])
  end

  it "renders cell editors from a table-like object with a single hash-like column" do
    form_builder = HashLikeColumnRenderFormBuilder.new
    column = HashLikeRenderColumn.new(
      editor: RailsFieldsKit::TableCellInput.enum_select(:status)
    )
    table = HashLikeRenderTable.new(column)

    expect(column.to_a).to eq([[:unexpected, true]])
    expect(described_class.render_cell_editors(form_builder, table)).to eq(["enum_select"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}]
    ])
  end
end
