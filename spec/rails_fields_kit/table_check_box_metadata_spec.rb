# frozen_string_literal: true

require "spec_helper"

RSpec.describe "checkbox table metadata" do
  class FakeCheckBoxTableFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_check_box(method, **options)
      calls << [:rfk_check_box, method, options]
      "check_box"
    end
  end

  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "builds check_box filter metadata without adding boolean query semantics" do
    input = RailsFieldsKit::TableFilterInput.check_box(
      :active,
      checked_value: "1",
      unchecked_value: "0",
      label: "Active only"
    )

    expect(input.to_table_filter).to eq(
      type: "rails_fields_kit",
      field_type: "check_box",
      method: "active",
      options: {
        checked_value: "1",
        unchecked_value: "0",
        label: "Active only"
      }
    )
    expect(RailsFieldsKit::TableFilterInput.known_type?(:check_box)).to be(true)
  end

  it "builds check_box cell editor metadata" do
    input = RailsFieldsKit::TableCellInput.check_box(
      :active,
      checked_value: "yes",
      unchecked_value: "no"
    )

    expect(input.to_table_cell_editor).to eq(
      type: "rails_fields_kit",
      field_type: "check_box",
      method: "active",
      options: {
        checked_value: "yes",
        unchecked_value: "no"
      }
    )
    expect(RailsFieldsKit::TableCellInput.known_type?(" check_box ")).to be(true)
  end

  it "maps check_box metadata to the final rfk_check_box helper surface" do
    form_builder = FakeCheckBoxTableFormBuilder.new
    metadata = {
      field_type: "check_box",
      method: "active",
      options: {
        checked_value: "yes",
        unchecked_value: "no",
        wrapper: true
      }
    }

    expect(RailsFieldsKit::TableRenderer.filter_call(metadata)).to eq(
      helper: :rfk_check_box,
      method: :active,
      options: {
        checked_value: "yes",
        unchecked_value: "no",
        wrapper: true
      }
    )
    expect(RailsFieldsKit::TableRenderer.render_filter(form_builder, metadata)).to eq("check_box")
    expect(form_builder.calls).to eq([
      [
        :rfk_check_box,
        :active,
        {
          checked_value: "yes",
          unchecked_value: "no",
          wrapper: true
        }
      ]
    ])
  end
end
