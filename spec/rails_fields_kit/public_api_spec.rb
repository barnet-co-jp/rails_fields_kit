# frozen_string_literal: true

require "spec_helper"

RSpec.describe "public API" do
  it "exposes version and configuration APIs" do
    expect(RailsFieldsKit::VERSION).to match(/\A\d+\.\d+\.\d+/)
    expect(RailsFieldsKit).to respond_to(:configuration)
    expect(RailsFieldsKit).to respond_to(:configure)
    expect(RailsFieldsKit).to respond_to(:reset_configuration!)
  end

  it "exposes FormBuilder helpers" do
    expect(RailsFieldsKit::FormBuilder.instance_methods).to include(
      :rfk_select,
      :rfk_combobox,
      :rfk_autocomplete,
      :rfk_tags,
      :rfk_multi_select,
      :rfk_grouped_select,
      :rfk_enum_select,
      :rfk_token_search,
      :rfk_text_field,
      :rfk_text_area,
      :rfk_number_field,
      :rfk_money_field,
      :rfk_percent_field,
      :rfk_email_field,
      :rfk_url_field,
      :rfk_phone_field,
      :rfk_search_field
    )
  end

  it "exposes Searchable controller helpers" do
    expect(RailsFieldsKit::Searchable::ClassMethods.instance_methods).to include(
      :rfk_search_with,
      :rfk_find_with,
      :rfk_create_with,
      :rfk_token_suggestions_with
    )
  end

  it "exposes token suggestion builders" do
    expect(RailsFieldsKit::TokenSuggestions).to respond_to(:build)
    expect(RailsFieldsKit::RansackSuggestions).to respond_to(:build)
  end

  it "exposes table filter factories" do
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:token_search)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:ransack_filter)
  end

  it "exposes table metadata renderer" do
    expect(RailsFieldsKit::TableRenderer).to respond_to(:filter_call)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:filter_calls)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:cell_editor_call)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:cell_editor_calls)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:render_filter)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:render_filters)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:render_cell_editor)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:render_cell_editors)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:field_helpers)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:register_field_helper)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:reset_field_helpers!)
  end

  it "exposes table metadata collector" do
    expect(RailsFieldsKit::TableMetadata).to respond_to(:filters)
    expect(RailsFieldsKit::TableMetadata).to respond_to(:cell_editors)
    expect(RailsFieldsKit::TableMetadata).to respond_to(:filter_calls)
    expect(RailsFieldsKit::TableMetadata).to respond_to(:cell_editor_calls)
    expect(RailsFieldsKit::TableMetadata).to respond_to(:render_filters)
    expect(RailsFieldsKit::TableMetadata).to respond_to(:render_cell_editors)
  end
end