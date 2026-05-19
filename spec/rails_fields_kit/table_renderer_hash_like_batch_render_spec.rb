# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  class HashLikeBatchRenderFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_combobox(method, **options)
      calls << [:rfk_combobox, method, options]
      "combobox"
    end

    def rfk_enum_select(method, **options)
      calls << [:rfk_enum_select, method, options]
      "enum_select"
    end
  end

  class HashLikeBatchRenderMetadata
    def initialize(metadata)
      @metadata = metadata
    end

    def to_hash
      @metadata
    end

    def to_a
      [[:unexpected, true]]
    end
  end

  it "renders a single hash-like filter metadata object as one batch entry" do
    form_builder = HashLikeBatchRenderFormBuilder.new
    metadata = HashLikeBatchRenderMetadata.new(
      field_type: "combobox",
      method: "customer_id",
      options: { url: "/customers.json" }
    )

    expect(metadata.to_a).to eq([[:unexpected, true]])
    expect(described_class.render_filters(form_builder, metadata)).to eq(["combobox"])
    expect(form_builder.calls).to eq([
      [:rfk_combobox, :customer_id, { url: "/customers.json" }]
    ])
  end

  it "renders a single hash-like cell editor metadata object as one batch entry" do
    form_builder = HashLikeBatchRenderFormBuilder.new
    metadata = HashLikeBatchRenderMetadata.new(
      field_type: "enum_select",
      method: "status",
      options: {}
    )

    expect(metadata.to_a).to eq([[:unexpected, true]])
    expect(described_class.render_cell_editors(form_builder, metadata)).to eq(["enum_select"])
    expect(form_builder.calls).to eq([
      [:rfk_enum_select, :status, {}]
    ])
  end
end
