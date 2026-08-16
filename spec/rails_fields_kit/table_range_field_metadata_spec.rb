# frozen_string_literal: true

require "spec_helper"

RSpec.describe "range field table metadata" do
  class RangeFieldTableFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_range_field(method, **options)
      calls << [:rfk_range_field, method, options]
      "range_field"
    end
  end

  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "exposes range_field as a built-in filter metadata factory" do
    input = RailsFieldsKit::TableFilterInput.range_field(
      :priority,
      min: 1,
      max: 10,
      step: 1
    )

    expect(RailsFieldsKit::TableFilterInput.known_types).to include(:range_field)
    expect(RailsFieldsKit::TableFilterInput.known_type?(" range_field ")).to be(true)
    expect(input.to_table_filter).to eq(
      type: "rails_fields_kit",
      field_type: "range_field",
      method: "priority",
      options: {
        min: 1,
        max: 10,
        step: 1
      }
    )
  end

  it "exposes range_field as a built-in cell editor metadata factory" do
    input = RailsFieldsKit::TableCellInput.range_field(
      :completion,
      min: 0,
      max: 100,
      step: 5
    )

    expect(RailsFieldsKit::TableCellInput.known_types).to include(:range_field)
    expect(RailsFieldsKit::TableCellInput.known_type?(:range_field)).to be(true)
    expect(input.to_table_cell_editor).to eq(
      type: "rails_fields_kit",
      field_type: "range_field",
      method: "completion",
      options: {
        min: 0,
        max: 100,
        step: 5
      }
    )
  end

  it "maps range_field table metadata to rfk_range_field without changing native options" do
    form_builder = RangeFieldTableFormBuilder.new
    filter = RailsFieldsKit::TableFilterInput.range_field(
      :priority,
      min: 1,
      max: 10,
      step: 1
    )
    editor = RailsFieldsKit::TableCellInput.range_field(
      :completion,
      min: 0,
      max: 100,
      step: 5
    )

    expect(RailsFieldsKit::TableRenderer.helper_for(:range_field)).to eq(:rfk_range_field)
    expect(RailsFieldsKit::TableRenderer.filter_call(filter)).to eq(
      helper: :rfk_range_field,
      method: :priority,
      options: {
        min: 1,
        max: 10,
        step: 1
      }
    )
    expect(RailsFieldsKit::TableRenderer.cell_editor_call(editor)).to eq(
      helper: :rfk_range_field,
      method: :completion,
      options: {
        min: 0,
        max: 100,
        step: 5
      }
    )

    expect(RailsFieldsKit::TableRenderer.render_filter(form_builder, filter)).to eq("range_field")
    expect(RailsFieldsKit::TableRenderer.render_cell_editor(form_builder, editor)).to eq("range_field")
    expect(form_builder.calls).to eq([
      [:rfk_range_field, :priority, { min: 1, max: 10, step: 1 }],
      [:rfk_range_field, :completion, { min: 0, max: 100, step: 5 }]
    ])
  end
end
