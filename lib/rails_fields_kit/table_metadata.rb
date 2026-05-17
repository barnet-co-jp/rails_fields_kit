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

      private

      def collect(columns, keys, protocol)
        Array(columns).filter_map do |column|
          value = read_first_column_value(column, keys)
          next if value.nil? || value == false

          value.respond_to?(protocol) ? value.public_send(protocol) : value
        end
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
          column[key] || column[key.to_s]
        else
          column.public_send(key) if column.respond_to?(key)
        end
      end
    end
  end
end