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
      :rfk_create_with
    )
  end
end