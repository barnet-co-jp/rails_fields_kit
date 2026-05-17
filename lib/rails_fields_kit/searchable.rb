# frozen_string_literal: true

require "active_support/concern"

module RailsFieldsKit
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def rfk_search_with(model:, label:, value: :id, search:, limit: 20, query_param: nil, value_field: nil, label_field: nil, description: nil, badge: nil, description_field: nil, badge_field: nil, wrap: nil)
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
          options = records.map do |record|
            rfk_option_json(
              record,
              value: value,
              label: label,
              value_field: value_field,
              label_field: label_field,
              description: description,
              badge: badge,
              description_field: description_field,
              badge_field: badge_field
            )
          end
          render json: rfk_wrap_options(options, wrap: wrap)
        end
      end

      def rfk_create_with(model:, label:, value: :id, create_attribute: nil, create_param: nil, value_field: nil, label_field: nil, description: nil, badge: nil, description_field: nil, badge_field: nil, permitted_attributes: nil, wrap: nil)
        define_method(:create) do
          attribute_name = create_attribute || label
          param_name = create_param || RailsFieldsKit.configuration.default_create_param
          attributes = rfk_create_attributes(
            attribute_name: attribute_name,
            param_name: param_name,
            permitted_attributes: permitted_attributes
          )
          record = model.new(attributes)

          if record.save
            option = rfk_option_json(
              record,
              value: value,
              label: label,
              value_field: value_field,
              label_field: label_field,
              description: description,
              badge: badge,
              description_field: description_field,
              badge_field: badge_field
            )
            render json: rfk_wrap_option(option, wrap: wrap), status: :created
          else
            render json: { errors: record.errors.to_hash(true) }, status: :unprocessable_entity
          end
        end
      end
    end

    private

    def rfk_option_json(record, value:, label:, value_field:, label_field:, description:, badge:, description_field:, badge_field:)
      option = {
        (value_field || RailsFieldsKit.configuration.default_value_field) => rfk_read_option_value(record, value),
        (label_field || RailsFieldsKit.configuration.default_label_field) => rfk_read_option_value(record, label)
      }

      if description
        option[description_field || RailsFieldsKit.configuration.default_option_description_field || "description"] = rfk_read_option_value(record, description)
      end

      if badge
        option[badge_field || RailsFieldsKit.configuration.default_option_badge_field || "badge"] = rfk_read_option_value(record, badge)
      end

      option
    end

    def rfk_read_option_value(record, method_or_proc)
      return method_or_proc.call(record) if method_or_proc.respond_to?(:call)

      record.public_send(method_or_proc)
    end

    def rfk_wrap_options(options, wrap:)
      return options if wrap.nil? || wrap == false

      { wrap => options }
    end

    def rfk_wrap_option(option, wrap:)
      return option if wrap.nil? || wrap == false

      { wrap => option }
    end

    def rfk_create_attributes(attribute_name:, param_name:, permitted_attributes:)
      base_attributes = { attribute_name => params[param_name] }
      return base_attributes if permitted_attributes.nil?

      permitted = params.permit(*Array(permitted_attributes)).to_h.symbolize_keys
      base_attributes.merge(permitted)
    end
  end
end
