# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select data value drift" do
  REPO_ROOT = File.expand_path("../..", __dir__)
  FORM_BUILDER_DATA_VALUE_SOURCES = [
    File.read(File.join(REPO_ROOT, "lib/rails_fields_kit/form_builder.rb")),
    File.read(File.join(REPO_ROOT, "lib/rails_fields_kit/form_builder_dependent_query_params.rb")),
    File.read(File.join(REPO_ROOT, "lib/rails_fields_kit/form_builder_label_fallback.rb")),
    File.read(File.join(REPO_ROOT, "lib/rails_fields_kit/form_builder_tom_select_class_names.rb"))
  ].freeze
  TOM_SELECT_CONTROLLER_SOURCE = File.read(File.join(REPO_ROOT, "app/javascript/rails_fields_kit/tom_select_controller.js"))

  JS_ONLY_STATIC_VALUES = {}.freeze

  def camelize_data_value(value_name)
    value_name.to_s.split("_").then do |parts|
      parts.first + parts.drop(1).map(&:capitalize).join
    end
  end

  def generated_data_value_names
    FORM_BUILDER_DATA_VALUE_SOURCES
      .flat_map do |source|
        source.scan(/rfk_assign_data_value\(data,\s*:(\w+)/).flatten +
          source.scan(/data\[:rails_fields_kit__tom_select_(\w+)_value\]/).flatten
      end
      .uniq
      .map { |value_name| camelize_data_value(value_name) }
      .sort
  end

  def tom_select_static_value_names
    static_values_body = TOM_SELECT_CONTROLLER_SOURCE.match(
      /static values = \{(?<body>[\s\S]*?)\n  \}\n\n  connect\(\)/
    )

    expect(static_values_body).not_to be_nil

    static_values_body[:body]
      .scan(/^\s{4}([A-Za-z]\w*):/)
      .flatten
      .uniq
      .sort
  end

  it "keeps every FormBuilder-generated Tom Select data value readable by Stimulus" do
    missing_static_values = generated_data_value_names - tom_select_static_value_names

    expect(missing_static_values).to be_empty,
      "Add matching TomSelectController.static values for FormBuilder-generated data values: #{missing_static_values.join(', ')}"
  end

  it "documents Tom Select static values that are not generated through FormBuilder data values" do
    undocumented_static_values = tom_select_static_value_names - generated_data_value_names - JS_ONLY_STATIC_VALUES.keys

    expect(undocumented_static_values).to be_empty,
      "Document intentionally JS-only values or add matching FormBuilder data values: #{undocumented_static_values.join(', ')}"
  end

  it "keeps JS-only value exceptions small and current" do
    JS_ONLY_STATIC_VALUES.each do |value_name, reason|
      expect(tom_select_static_value_names).to include(value_name)
      expect(reason).not_to be_empty
    end
  end
end
