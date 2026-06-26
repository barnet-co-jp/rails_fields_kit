# frozen_string_literal: true

require "spec_helper"

RSpec.describe "generated initializer template" do
  INITIALIZER_ASSIGNMENT_DEFAULTS = {
    controller_name: "rails-fields-kit--tom-select",
    default_query_param: "q",
    default_selected_param: "id",
    default_selected_multiple_param: "ids",
    default_create_param: "text",
    default_value_field: "value",
    default_label_field: "text",
    default_search_field: "text",
    default_plugins: [],
    default_allow_clear: false,
    default_min_length: 0,
    default_max_options: nil,
    default_load_throttle: nil,
    default_preload: nil,
    default_open_on_focus: nil,
    default_close_after_select: nil,
    default_hide_selected: nil,
    default_persist: nil,
    default_option_description_field: nil,
    default_option_badge_field: nil,
    wrapper_class: "rfk-field",
    label_class: "rfk-label",
    hint_class: "rfk-hint",
    error_class: "rfk-error",
    field_error_class: "rfk-field--error",
    control_class: "rfk-control",
    prefix_class: "rfk-prefix",
    suffix_class: "rfk-suffix"
  }.freeze

  TEXT_DEFAULTS = {
    default_no_results_text: RailsFieldsKit::Configuration::DEFAULT_NO_RESULTS_TEXT,
    default_loading_text: RailsFieldsKit::Configuration::DEFAULT_LOADING_TEXT,
    default_create_text: RailsFieldsKit::Configuration::DEFAULT_CREATE_TEXT
  }.freeze

  let(:configuration) { RailsFieldsKit::Configuration.new }
  let(:template_path) do
    File.expand_path("../../lib/generators/rails_fields_kit/templates/rails_fields_kit.rb", __dir__)
  end
  let(:template) { File.read(template_path) }

  it "keeps the template coverage aligned with the configuration setter surface" do
    configuration_keys = RailsFieldsKit::Configuration.instance_methods(false)
      .grep(/=$/)
      .map { |method_name| method_name.to_s.delete_suffix("=").to_sym }

    expect(INITIALIZER_ASSIGNMENT_DEFAULTS.keys + TEXT_DEFAULTS.keys).to match_array(configuration_keys)
  end

  it "keeps assigned initializer defaults aligned with runtime defaults" do
    INITIALIZER_ASSIGNMENT_DEFAULTS.each do |name, expected_value|
      expect(configuration.public_send(name)).to eq(expected_value)
      expect(template).to match(/^\s*config\.#{Regexp.escape(name.to_s)} = #{Regexp.escape(expected_value.inspect)}$/)
    end
  end

  it "keeps locale-aware text defaults unset with commented guidance" do
    TEXT_DEFAULTS.each do |name, sentinel|
      expect(configuration.public_send(name)).to eq(sentinel)
      expect(template).not_to match(/^\s*config\.#{Regexp.escape(name.to_s)} =/)
    end

    expect(template).to include(
      "# Leave these unset to use the bundled locale-aware copy.",
      "# config.default_no_results_text = \"No results found\"",
      "# config.default_loading_text = \"Loading...\"",
      "# config.default_create_text = \"Add\""
    )
    expect(template).not_to include(
      "DEFAULT_NO_RESULTS_TEXT",
      "DEFAULT_LOADING_TEXT",
      "DEFAULT_CREATE_TEXT"
    )
  end
end
