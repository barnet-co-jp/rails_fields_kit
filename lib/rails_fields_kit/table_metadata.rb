# frozen_string_literal: true

module RailsFieldsKit
  module TableMetadata
    FILTER_KEYS = %i[filter filter_input search_filter].freeze
    CELL_EDITOR_KEYS = %i[editor cell_editor cell_input].freeze

    class << self
      def filters(columns)
        collect(columns, FILTER_KEYS, :to_table_filter)
      end

      def cell_editors(columns)
        collect(columns, CELL_EDITOR_KEYS, :to_table_cell_editor)
      end

      def filter_calls(columns)
        TableRenderer.filter_calls(filters(columns))
      end

      def cell_editor_calls(columns)
        TableRenderer.cell_editor_calls(cell_editors(columns))
      end

      def render_filters(form_builder, columns)
        TableRenderer.render_filters(form_builder, filters(columns))
      end

      def render_cell_editors(form_builder, columns)
        TableRenderer.render_cell_editors(form_builder, cell_editors(columns))
      end

      private

      def collect(columns, keys, protocol)
        normalize_columns(columns).filter_map do |column|
          value = read_first_column_value(column, keys)
          next if value.nil? || value == false

          value.respond_to?(protocol) ? value.public_send(protocol) : value
        end
      end

      def normalize_columns(columns)
        source = columns.respond_to?(:columns) ? columns.columns : columns
        return [] if source.nil?
        return source if source.is_a?(Array)
        return source.to_a if enumerable_columns?(source)

        Array(source)
      end

      def enumerable_columns?(source)
        source.respond_to?(:to_a) && !source.is_a?(Hash)
      end

      def read_first_column_value(column, keys)
        keys.each do |key|
          value = read_column_value(column, key)
          return value unless value.nil?
        end
        nil
      end

      def read_column_value(column, key)
        case column
        when Hash
          return column[key] if column.key?(key)
          return column[key.to_s] if column.key?(key.to_s)
        else
          read_object_column_value(column, key)
        end
      end

      def read_object_column_value(column, key)
        return unless column_metadata_reader?(column, key)

        column.public_send(key)
      end

      def column_metadata_reader?(column, key)
        return false unless column.respond_to?(key)
        return column.members.map(&:to_sym).include?(key) if column.respond_to?(:members)

        reader = column.method(key)
        reader.owner != Enumerable
      end
    end
  end
end