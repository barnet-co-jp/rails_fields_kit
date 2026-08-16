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
      :rfk_lookup,
      :rfk_tags,
      :rfk_multi_select,
      :rfk_grouped_select,
      :rfk_enum_select,
      :rfk_token_search,
      :rfk_table_filters,
      :rfk_table_cell_editors,
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
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:from_type)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:known_types)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:known_type?)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:combobox)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:select)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:autocomplete)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:tags)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:multi_select)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:grouped_select)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:enum_select)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:text_field)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:text_area)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:number_field)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:money_field)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:percent_field)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:email_field)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:url_field)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:phone_field)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:search_field)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:token_search)
    expect(RailsFieldsKit::TableFilterInput).to respond_to(:ransack_filter)
    expect(RailsFieldsKit::TableFilterInput.new).to respond_to(:to_h)
    expect(RailsFieldsKit::TableFilterInput.new).to respond_to(:to_hash)
    expect(RailsFieldsKit::TableFilterInput.new).to respond_to(:to_table_filter)
  end

  it "exposes table cell editor factories" do
    expect(RailsFieldsKit::TableCellInput).to respond_to(:from_type)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:known_types)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:known_type?)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:combobox)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:select)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:autocomplete)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:tags)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:multi_select)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:grouped_select)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:enum_select)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:text_field)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:text_area)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:number_field)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:money_field)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:percent_field)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:email_field)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:url_field)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:phone_field)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:search_field)
    expect(RailsFieldsKit::TableCellInput).to respond_to(:token_search)
    expect(RailsFieldsKit::TableCellInput.new).to respond_to(:to_h)
    expect(RailsFieldsKit::TableCellInput.new).to respond_to(:to_hash)
    expect(RailsFieldsKit::TableCellInput.new).to respond_to(:to_table_cell_editor)
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
    expect(RailsFieldsKit::TableRenderer).to respond_to(:registered_field_types)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:helper_for)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:registered_field_type?)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:register_field_helper)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:unregister_field_helper)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:with_field_helpers)
    expect(RailsFieldsKit::TableRenderer).to respond_to(:reset_field_helpers!)
  end

  it "exposes table renderer exception classes" do
    expect(defined?(RailsFieldsKit::TableRenderer::UnknownFieldType)).to eq("constant")
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
