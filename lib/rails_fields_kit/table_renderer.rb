# frozen_string_literal: true

module RailsFieldsKit
  module TableRenderer
    DEFAULT_FIELD_HELPERS = {
      "select" => :rfk_select,
      "combobox" => :rfk_combobox,
      "autocomplete" => :rfk_autocomplete,
      "tags" => :rfk_tags,
      "multi_select" => :rfk_multi_select,
      "grouped_select" => :rfk_grouped_select,
      "enum_select" => :rfk_enum_select,
      "token_search" => :rfk_token_search,
      "text_field" => :rfk_text_field,
      "text_area" => :rfk_text_area,
      "number_field" => :rfk_number_field,
      "money_field" => :rfk_money_field,
      "percent_field" => :rfk_percent_field,
      "email_field" => :rfk_email_field,
      "url_field" => :rfk_url_field,
      "phone_field" => :rfk_phone_field,
      "search_field" => :rfk_search_field
    }.freeze

    class UnknownFieldType < StandardError; end

    class << self
      def field_helpers
        registered_field_helpers.dup
      end

      def helper_for(field_type)
        registered_field_helpers[normalize_field_type(field_type)]
      end

      def registered_field_type?(field_type)
        !helper_for(field_type).nil?
      end

      def register_field_helper(field_type, helper_name)
        normalized_field_type = normalize_field_type(field_type)
        normalized_helper_name = normalize_helper_name(helper_name)
        raise ArgumentError, "table field type is required" if normalized_field_type.empty?
        raise ArgumentError, "table helper name is required" if normalized_helper_name.empty?

        registered_field_helpers[normalized_field_type] = normalized_helper_name.to_sym
      end

      def reset_field_helpers!
        @field_helpers = DEFAULT_FIELD_HELPERS.dup
      end

      def filter_call(filter)
        call_spec(normalize_filter(filter))
      end

      def filter_calls(filters)
        Array(filters).compact.map { |filter| filter_call(filter) }
      end

      def cell_editor_call(editor)
        call_spec(normalize_cell_editor(editor))
      end

      def cell_editor_calls(editors)
        Array(editors).compact.map { |editor| cell_editor_call(editor) }
      end

      def render_filter(form_builder, filter)
        render_call(form_builder, filter_call(filter))
      end

      def render_filters(form_builder, filters)
        filter_calls(filters).map { |call| render_call(form_builder, call) }
      end

      def render_cell_editor(form_builder, editor)
        render_call(form_builder, cell_editor_call(editor))
      end

      def render_cell_editors(form_builder, editors)
        cell_editor_calls(editors).map { |call| render_call(form_builder, call) }
      end

      private

      def registered_field_helpers
        @field_helpers ||= DEFAULT_FIELD_HELPERS.dup
      end

      def normalize_filter(filter)
        return filter.to_table_filter if filter.respond_to?(:to_table_filter)

        normalize_hash_like_metadata(filter)
      end

      def normalize_cell_editor(editor)
        return editor.to_table_cell_editor if editor.respond_to?(:to_table_cell_editor)

        normalize_hash_like_metadata(editor)
      end

      def normalize_hash_like_metadata(metadata)
        return metadata unless metadata.respond_to?(:to_hash)

        normalized_metadata = metadata.to_hash
        raise ArgumentError, "table metadata to_hash must return a hash" unless normalized_metadata.respond_to?(:to_hash)

        normalized_metadata.to_hash
      end

      def call_spec(metadata)
        metadata = metadata.transform_keys(&:to_sym)
        field_type = normalize_field_type(metadata.fetch(:field_type, nil))
        raise UnknownFieldType, "table metadata field_type is required" if field_type.empty?

        helper = helper_for(field_type)
        raise UnknownFieldType, "unknown Rails Fields Kit table field type: #{field_type}" unless helper

        method = normalize_method_name(metadata[:method])
        options = normalize_options(metadata[:options])

        {
          helper: helper,
          method: method,
          options: options
        }
      end

      def render_call(form_builder, call)
        method = call.fetch(:method)
        raise ArgumentError, "table metadata method is required" unless method

        form_builder.public_send(call.fetch(:helper), method, **call.fetch(:options))
      end

      def normalize_field_type(field_type)
        field_type.to_s.strip
      end

      def normalize_helper_name(helper_name)
        helper_name.to_s.strip
      end

      def normalize_method_name(method_name)
        normalized_method_name = method_name.to_s.strip
        return nil if normalized_method_name.empty?

        normalized_method_name.to_sym
      end

      def normalize_options(options)
        return {} if options.nil?
        raise ArgumentError, "table metadata options must be a hash" unless options.respond_to?(:to_hash)

        options.to_hash.dup
      end
    end
  end
end