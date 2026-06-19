# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table metadata native helper inventory" do
  let(:root_path) { File.expand_path("../..", __dir__) }
  let(:form_builder_source) { File.read(File.join(root_path, "lib/rails_fields_kit/form_builder.rb")) }
  let(:table_filter_input_source) { File.read(File.join(root_path, "lib/rails_fields_kit/table_filter_input.rb")) }
  let(:table_cell_input_source) { File.read(File.join(root_path, "lib/rails_fields_kit/table_cell_input.rb")) }
  let(:table_renderer_source) { File.read(File.join(root_path, "lib/rails_fields_kit/table_renderer.rb")) }

  it "keeps table metadata native factories aligned with the FormBuilder native helper inventory" do
    native_field_types = native_helper_field_types_from(form_builder_source)
    intentional_table_metadata_exceptions = {}
    expected_table_metadata_types = native_field_types - intentional_table_metadata_exceptions.keys

    filter_factory_types = common_field_types_from(table_filter_input_source)
    cell_factory_types = common_field_types_from(table_cell_input_source)
    renderer_field_types = default_renderer_field_types_from(table_renderer_source)

    expect_no_missing_types("TableFilterInput::COMMON_FIELD_TYPES", filter_factory_types, expected_table_metadata_types, intentional_table_metadata_exceptions)
    expect_no_missing_types("TableCellInput::COMMON_FIELD_TYPES", cell_factory_types, expected_table_metadata_types, intentional_table_metadata_exceptions)
    expect_no_missing_types("TableRenderer::DEFAULT_FIELD_HELPERS", renderer_field_types, expected_table_metadata_types, intentional_table_metadata_exceptions)

    intentional_table_metadata_exceptions.each_key do |field_type|
      expect(filter_factory_types).not_to include(field_type)
      expect(cell_factory_types).not_to include(field_type)
      expect(renderer_field_types).not_to include(field_type)
    end
  end

  def native_helper_field_types_from(source)
    source.scan(/^    def (rfk_[a-z_]+).*?\n(.*?)^    end/m).filter_map do |helper_name, body|
      helper_name.delete_prefix("rfk_").to_sym if body.include?("rfk_native_field(")
    end
  end

  def common_field_types_from(source)
    match = source.match(/^    COMMON_FIELD_TYPES = %i\[\n(?<list>.*?)^    \]\.freeze/m)
    raise "COMMON_FIELD_TYPES inventory not found" unless match

    match[:list].scan(/^\s+([a-z_]+)$/).flatten.map(&:to_sym)
  end

  def default_renderer_field_types_from(source)
    match = source.match(/^    DEFAULT_FIELD_HELPERS = \{\n(?<list>.*?)^    \}\.freeze/m)
    raise "DEFAULT_FIELD_HELPERS inventory not found" unless match

    match[:list].scan(/^\s+"([a-z_]+)"\s*=>\s*:rfk_[a-z_]+/).flatten.map(&:to_sym)
  end

  def expect_no_missing_types(surface, actual_types, expected_types, intentional_exceptions)
    missing_types = expected_types - actual_types
    exception_note = intentional_exceptions.map { |field_type, reason| "#{field_type}: #{reason}" }.join("; ")

    expect(missing_types).to be_empty,
      "#{surface} is missing native helper field types #{missing_types.inspect}. " \
      "Add the built-in table metadata factory/renderer mapping or list an intentional exception. " \
      "Current intentional exceptions: #{exception_note}"
  end
end
