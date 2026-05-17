# frozen_string_literal: true

require "active_support/concern"

module RailsFieldsKit
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def rfk_search_with(model:, label:, value: :id, search:, limit: 20, query_param: nil, value_field: nil, label_field: nil)
        define_method(:index) do
          query_key = query_param || RailsFieldsKit.configuration.default_query_param
          query = params[query_key].to_s
          scope = model.all

          if query.present?
            columns = Array(search)
            escaped_query = model.sanitize_sql_like(query)
            predicates = columns.map do |column|
              model.arel_table[column].matches("%#{escaped_query}%")
            end
            scope = scope.where(predicates.reduce { |left, right| left.or(right) })
          end

          records = scope.limit(limit)
          render json: records.map do |record|
            rfk_option_json(
              record,
              value: value,
              label: label,
              value_field: value_field,
              label_field: label_field
            )
          end
        end
      end
    end

    private

    def rfk_option_json(record, value:, label:, value_field:, label_field:)
      {
        (value_field || RailsFieldsKit.configuration.default_value_field) => record.public_send(value),
        (label_field || RailsFieldsKit.configuration.default_label_field) => record.public_send(label)
      }
    end
  end
end
