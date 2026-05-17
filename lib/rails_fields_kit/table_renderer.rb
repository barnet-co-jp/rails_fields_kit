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
        @field_helpers ||= DEFAULT_FIELD_HELPERS.dup
      end

      def register_field_helper(field_type, helper_name)
        field_helpers[field_type.to_s] = helper_name.to_sym
      end

      def reset_field_helpers!
        @field_helpers = DEFAULT_FIELD_HELPERS.dup
      end

      def filter_call(filter)
        call_spec(normalize_filter(filter))
      end

      def cell_editor_call(editor)
        call_spec(normalize_cell_editor(editor))
      end

      def render_filter(form_builder, filter)
        render_call(form_builder, filter_call(filter))
      end

      def render_cell_editor(form_builder, editor)
        render_call(form_builder, cell_editor_call(editor))
      end

      private

      def normalize_filter(filter)
        filter.respond_to?(:to_table_filter) ? filter.to_table_filter : filter
      end

      def normalize_cell_editor(editor)
        editor.respond_to?(:to_table_cell_editor) ? editor.to_table_cell_editor : editor
      end

      def call_spec(metadata)
        metadata = metadata.transform_keys(&:to_sym)
        field_type = metadata.fetch(:field_type).to_s
        helper = field_helpers.fetch(field_type) do
          raise UnknownFieldType, "unknown Rails Fields Kit table field type: #{field_type}"
        end
        method = metadata[:method]&.to_sym
        options = (metadata[:options] || {}).dup

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
    end
  end
end