# frozen_string_literal: true

module RailsFieldsKit
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def rfk_search_with(model:, label:, value: :id, search:, limit: 20)
        define_method(:index) do
          query = params[RailsFieldsKit.configuration.default_query_param].to_s
          scope = model.all

          if query.present?
            columns = Array(search)
            predicates = columns.map { |column| model.arel_table[column].matches("%#{model.sanitize_sql_like(query)}%") }
            scope = scope.where(predicates.inject { |left, right| left.or(right) })
          end

          records = scope.limit(limit)
          render json: records.map { |record| { value => record.public_send(value), label => record.public_send(label) } }
        end
      end
    end
  end
end
