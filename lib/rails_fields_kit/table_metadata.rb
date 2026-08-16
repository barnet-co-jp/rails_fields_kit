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

          normalize_metadata_value(value, protocol)
        end
      end

      def normalize_metadata_value(value, protocol)
        metadata = if value.respond_to?(protocol)
          value.public_send(protocol)
        elsif value.respond_to?(:to_hash)
          normalize_hash_like_metadata(value)
        else
          value
        end

        duplicate_metadata(metadata)
      end

      def duplicate_metadata(metadata)
        return metadata unless metadata.respond_to?(:to_hash)

        duplicate_metadata_hash(metadata.to_hash)
      end

      def normalize_hash_like_metadata(value)
        metadata = value.to_hash
        raise ArgumentError, "table metadata to_hash must return a hash" unless metadata.respond_to?(:to_hash)

        duplicate_metadata_hash(metadata.to_hash)
      end

      def normalize_hash_like_column(column)
        normalized_column = column.to_hash
        raise ArgumentError, "table column to_hash must return a hash" unless normalized_column.respond_to?(:to_hash)

        duplicate_metadata_hash(normalized_column.to_hash)
      end

      def duplicate_metadata_hash(hash)
        duplicated_hash = {}
        canonical_keys = {}

        hash.each_pair do |key, value|
          canonical_key = normalize_metadata_key(key)

          if canonical_keys.key?(canonical_key)
            existing_key = canonical_keys[canonical_key]
            next if value.nil?

            if duplicated_hash[existing_key].nil?
              duplicated_hash.delete(existing_key)
              duplicated_hash[key] = duplicate_metadata_value(canonical_key, value)
              canonical_keys[canonical_key] = key
            end

            next
          end

          duplicated_hash[key] = duplicate_metadata_value(canonical_key, value)
          canonical_keys[canonical_key] = key
        end

        duplicated_hash
      end

      def normalize_metadata_key(key)
        key.respond_to?(:to_sym) ? key.to_sym : key
      end

      def duplicate_metadata_value(key, value)
        return value.dup if key == :options && value.respond_to?(:dup)
        return value.dup if value.is_a?(Hash)

        value
      end

      def normalize_columns(columns)
        source = columns.respond_to?(:columns) ? columns.columns : columns
        return [] if source.nil?
        return [source] if source.is_a?(Hash)
        return source if source.is_a?(Array)
        return [source] if metadata_column_object?(source)

        hash_like_source = normalized_hash_like_column_or_nil(source)
        return [hash_like_source] if hash_like_source && metadata_hash_column?(hash_like_source)

        return source.to_a if enumerable_columns?(source)

        Array(source)
      end

      def normalized_hash_like_column_or_nil(source)
        return unless source.respond_to?(:to_hash)

        normalize_hash_like_column(source)
      end

      def metadata_hash_column?(column)
        (FILTER_KEYS + CELL_EDITOR_KEYS).any? do |key|
          column.key?(key) || column.key?(key.to_s)
        end
      end

      def metadata_column_object?(source)
        (FILTER_KEYS + CELL_EDITOR_KEYS).any? { |key| column_metadata_reader(source, key) }
      end

      def enumerable_columns?(source)
        source.respond_to?(:to_a)
      end

      def read_first_column_value(column, keys)
        hash_column = (column.is_a?(Hash) || metadata_column_object?(column)) ? column : normalized_hash_like_column_or_nil(column)

        keys.each do |key|
          value = read_column_value(column, key, hash_column)
          return value unless value.nil?
        end
        nil
      end

      def read_column_value(column, key, hash_column = nil)
        return read_hash_column_value(hash_column, key) if hash_column.is_a?(Hash)
        return read_object_column_value(column, key) if metadata_column_object?(column)

        nil
      end

      def read_hash_column_value(column, key)
        return column[key] if column.key?(key)

        column[key.to_s] if column.key?(key.to_s)
      end

      def read_object_column_value(column, key)
        reader = column_metadata_reader(column, key)
        return unless reader

        reader.call
      end

      def column_metadata_reader(column, key)
        return struct_metadata_reader(column, key) if column.respond_to?(:members)
        return unless column.respond_to?(key)

        reader = column.public_method(key)
        return if reader.owner == Enumerable

        reader
      rescue NameError
        nil
      end

      def struct_metadata_reader(column, key)
        return unless column.members.map(&:to_sym).include?(key)

        column.public_method(key)
      end
    end
  end
end
