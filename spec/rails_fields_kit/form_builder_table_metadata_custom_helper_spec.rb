# frozen_string_literal: true

RSpec.describe "RailsFieldsKit FormBuilder table metadata custom helpers" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  CustomHelperDummyModel = Struct.new(:custom_value) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "CustomHelperDummyModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  class CustomHelperColumn
    def initialize(column)
      @column = column
    end

    def to_hash
      @column
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder
    model = CustomHelperDummyModel.new(nil)
    ActionView::Helpers::FormBuilder.new(:custom_helper_dummy_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit::TableRenderer.register_field_helper(
      :custom_field,
      :rfk_text_field
    )

    example.run
  ensure
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "renders custom registered filter helpers through rfk_table_filters" do
    columns = [
      CustomHelperColumn.new(
        filter: {
          field_type: "custom_field",
          method: "custom_value",
          options: {
            placeholder: "Custom filter"
          }
        }
      )
    ]

    html = form_builder.rfk_table_filters(columns)

    expect(html).to include("placeholder=\"Custom filter\"")
    expect(html).to include("custom_helper_dummy_model_custom_value")
  end

  it "renders custom registered cell editor helpers through rfk_table_cell_editors" do
    columns = [
      CustomHelperColumn.new(
        editor: {
          field_type: "custom_field",
          method: "custom_value",
          options: {
            placeholder: "Custom editor"
          }
        }
      )
    ]

    html = form_builder.rfk_table_cell_editors(columns)

    expect(html).to include("placeholder=\"Custom editor\"")
    expect(html).to include("custom_helper_dummy_model_custom_value")
  end
end
