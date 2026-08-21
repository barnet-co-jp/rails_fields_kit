# frozen_string_literal: true

module RailsFieldsKit
  module Searchable
    class_methods do
      def rfk_token_suggestions_with(suggestions:, action: :index, query_param: nil, value_field: nil, label_field: nil, description_field: nil, badge_field: nil, match_fields: nil, limit: 20, minimum_query_length: 0, wrap: nil)
        define_method(action) do
          query_key = query_param || RailsFieldsKit.configuration.default_query_param
          query = params[query_key].to_s

          if query.strip.length < minimum_query_length.to_i
            render json: rfk_wrap_options([], wrap: wrap)
            next
          end

          options = rfk_token_suggestion_options(
            suggestions,
            query: query,
            value_field: value_field,
            label_field: label_field,
            description_field: description_field,
            badge_field: badge_field,
            match_fields: match_fields
          )
          options = options.first(limit) if limit

          render json: rfk_wrap_options(options, wrap: wrap)
        end
      end
    end
  end
end
