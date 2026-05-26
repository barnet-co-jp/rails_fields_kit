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
    TABLE_ADAPTER_METADATA_KEYS = %i[adapter param_name fields].freeze
    TABLE_RENDER_ADAPTER_METADATA_OPTION = :_rfk_table_render_adapter_metadata

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

        if normalized_field_type.empty?
          raise ArgumentError, field_type.nil? ? "table field type is required" : "field type is required"
        end

        if normalized_helper_name.empty?
          raise ArgumentError, helper_name.nil? ? "table helper name is required" : "helper name is required"
        end

        registered_field_helpers[normalized_field_type] = normalized_helper_name.to_sym
      end

      def reset_field_helpers!
        @field_helpers = DEFAULT_FIELD_HELPERS.dup
      end

      def filter_call(filter)
        call_spec(normalize_filter(filter))
      end

      def filter_calls(filters)
        normalize_metadata_list(filters).compact.map { |filter| filter_call(filter) }
      end

      def cell_editor_call(editor)
        call_spec(normalize_cell_editor(editor))
      end

      def cell_editor_calls(editors)
        normalize_metadata_list(editors).compact.map { |editor| cell_editor_call(editor) }
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

      def normalize_metadata_list(metadata)
        return [] if metadata.nil?
        return [metadata] if metadata.is_a?(Hash)
        return metadata if metadata.is_a?(Array)
        return [metadata] if single_metadata_object?(metadata)
        return metadata.to_a if metadata.respond_to?(:to_a)

        Array(metadata)
      end

      def single_metadata_object?(metadata)
        metadata.respond_to?(:to_table_filter) ||
          metadata.respond_to?(:to_table_cell_editor) ||
          metadata.respond_to?(:to_hash)
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

        normalize_metadata_hash(normalized_metadata.to_hash)
      end

      def call_spec(metadata)
        metadata = normalize_metadata_hash(metadata)
        raw_field_type = metadata[:field_type]
        field_type = normalize_field_type(raw_field_type)

        if field_type.empty?
          error_class = raw_field_type.nil? ? UnknownFieldType : ArgumentError
          raise error_class, "table metadata field_type is required"
        end

        helper = helper_for(field_type)
        raise UnknownFieldType, "unknown Rails Fields Kit table field type: #{field_type}" unless helper

        method = normalize_method_name(metadata[:method])
        raise ArgumentError, "table metadata method is required" unless method

        options = normalize_options(metadata[:options])

        {
          helper: helper,
          method: method,
          options: options
        }
      end

      def normalize_metadata_hash(metadata)
        raise ArgumentError, "table metadata must be a hash" unless metadata.respond_to?(:each_pair)

        normalized_hash = {}

        metadata.each_pair do |key, value|
          normalized_key = key.respond_to?(:to_sym) ? key.to_sym : key
          next if normalized_hash.key?(normalized_key) && value.nil?

          normalized_hash[normalized_key] = value
        end

        normalized_hash
      end

      def render_call(form_builder, call)
        method = call.fetch(:method)
        raise ArgumentError, "table metadata method is required" unless method

        options = call.fetch(:options).dup
        if table_render_adapter_metadata?(call.fetch(:helper), options)
          options[TABLE_RENDER_ADAPTER_METADATA_OPTION] = true
        end

        form_builder.public_send(call.fetch(:helper), method, **options)
      end

      def table_render_adapter_metadata?(helper_name, options)
        helper_name == :rfk_token_search &&
          TABLE_ADAPTER_METADATA_KEYS.any? { |key| options.key?(key) || options.key?(key.to_s) }
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