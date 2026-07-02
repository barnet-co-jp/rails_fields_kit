# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table radio button metadata" do
  class FakeRadioTableFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_radio_button(method, tag_value, **options)
      calls << [:rfk_radio_button, method, tag_value, options]
      "radio_button"
    end
  end

  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "keeps radio button cell editor metadata cell-editor-only" do
    editor = RailsFieldsKit::TableCellInput.radio_button(
      :status,
      tag_value: "published",
      label: "Published",
      checked: true
    )

    expect(editor.to_table_cell_editor).to eq(
      type: "rails_fields_kit",
      field_type: "radio_button",
      method: "status",
      options: {
        tag_value: "published",
        label: "Published",
        checked: true
      }
    )
    expect(RailsFieldsKit::TableCellInput.known_type?(:radio_button)).to be(true)
    expect(RailsFieldsKit::TableFilterInput.known_type?(:radio_button)).to be(false)
  end

  it "maps radio button cell editors to the FormBuilder helper" do
    editor = RailsFieldsKit::TableCellInput.radio_button(
      :status,
      tag_value: "archived",
      label: "Archived"
    )

    expect(RailsFieldsKit::TableRenderer.helper_for(:radio_button)).to eq(:rfk_radio_button)
    expect(RailsFieldsKit::TableRenderer.cell_editor_call(editor)).to eq(
      helper: :rfk_radio_button,
      method: :status,
      options: {
        tag_value: "archived",
        label: "Archived"
      }
    )
  end

  it "renders tag_value as the radio helper positional value" do
    form_builder = FakeRadioTableFormBuilder.new
    editor = RailsFieldsKit::TableCellInput.radio_button(
      :status,
      tag_value: "draft",
      label: "Draft",
      checked: false
    )

    expect(RailsFieldsKit::TableRenderer.render_cell_editor(form_builder, editor)).to eq("radio_button")
    expect(form_builder.calls).to eq([
      [:rfk_radio_button, :status, "draft", { label: "Draft", checked: false }]
    ])
  end

  it "accepts string tag_value metadata when rendering" do
    form_builder = FakeRadioTableFormBuilder.new
    metadata = {
      field_type: "radio_button",
      method: "status",
      options: {
        "tag_value" => "scheduled",
        "label" => "Scheduled"
      }
    }

    expect(RailsFieldsKit::TableRenderer.render_cell_editor(form_builder, metadata)).to eq("radio_button")
    expect(form_builder.calls).to eq([
      [:rfk_radio_button, :status, "scheduled", { "label" => "Scheduled" }]
    ])
  end

  it "keeps missing tag_value failures explicit" do
    form_builder = FakeRadioTableFormBuilder.new
    metadata = {
      field_type: "radio_button",
      method: "status",
      options: { label: "Published" }
    }

    expect { RailsFieldsKit::TableRenderer.render_cell_editor(form_builder, metadata) }
      .to raise_error(ArgumentError, "table radio button metadata tag_value is required")
  end
end
