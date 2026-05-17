# frozen_string_literal: true

module RailsFieldsKit
  module TableMetadata
    class << self
      def filters(columns)
        collect(columns, :filter, :to_table_filter)
      end

      def cell_editors(columns)
        collect(columns, :editor, :to_table_cell_editor)
      end

      def filter_calls(columns)
        TableRenderer.filter_calls(filters(columns))
      end

      def cell_editor_calls(columns)
        TableRenderer.cell_editor_calls(cell_editors(columns))
      end

      private

      def collect(columns, key, protocol)
        Array(columns).filter_map do |column|
          value = read_column_value(column, key)
          next if value.nil? || value == false

          value.respond_to?(protocol) ? value.public_send(protocol) : value
        end
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