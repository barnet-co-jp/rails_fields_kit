# frozen_string_literal: true

RSpec.describe "RailsFieldsKit FormBuilder table helper reset integration" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  ResetHelperDummyModel = Struct.new(:custom_value) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "ResetHelperDummyModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder
    model = ResetHelperDummyModel.new(nil)
    ActionView::Helpers::FormBuilder.new(:reset_helper_dummy_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
  ensure
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "stops rendering custom helpers after reset through rfk_table_filters" do
    RailsFieldsKit::TableRenderer.register_field_helper(
      :custom_filter,
      :rfk_text_field
    )

    metadata = [
      {
        filter: {
          field_type: "custom_filter",
          method: "custom_value"
        }
      }
    ]

    expect(
      form_builder.rfk_table_filters(metadata)
    ).to include("reset_helper_dummy_model_custom_value")

    RailsFieldsKit::TableRenderer.reset_field_helpers!

    expect {
      form_builder.rfk_table_filters(metadata)
    }.to raise_error(
      ArgumentError,
      "unknown table field type: custom_filter"
    )
  end

  it "stops rendering custom helpers after reset through rfk_table_cell_editors" do
    RailsFieldsKit::TableRenderer.register_field_helper(
      :custom_editor,
      :rfk_text_field
    )

    metadata = [
      {
        editor: {
          field_type: "custom_editor",
          method: "custom_value"
        }
      }
    ]

    expect(
      form_builder.rfk_table_cell_editors(metadata)
    ).to include("reset_helper_dummy_model_custom_value")

    RailsFieldsKit::TableRenderer.reset_field_helpers!

    expect {
      form_builder.rfk_table_cell_editors(metadata)
    }.to raise_error(
      ArgumentError,
      "unknown table field type: custom_editor"
    )
  end
end
