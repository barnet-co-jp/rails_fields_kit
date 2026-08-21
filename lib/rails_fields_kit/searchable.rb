# frozen_string_literal: true

require "active_support/concern"

module RailsFieldsKit
  module Searchable
    extend ActiveSupport::Concern

    SEARCH_MATCH_STRATEGIES = %i[contains prefix exact].freeze

    class_methods do
      def rfk_search_with(model:, label:, search:, action: :index, value: :id, limit: 20, query_param: nil, value_field: nil, label_field: nil, description: nil, badge: nil, description_field: nil, badge_field: nil, scope: nil, order: nil, distinct: false, minimum_query_length: 0, match: :contains, wrap: nil)
        match_strategy = match.to_sym
        unless SEARCH_MATCH_STRATEGIES.include?(match_strategy)
          raise ArgumentError, "Unsupported rfk_search_with match strategy: #{match.inspect}. Expected one of: #{SEARCH_MATCH_STRATEGIES.join(", ")}"
        end

        define_method(action) do
          query_key = query_param || RailsFieldsKit.configuration.default_query_param
          query = params[query_key].to_s

          if query.strip.length < minimum_query_length.to_i
            render json: rfk_wrap_options([], wrap: wrap)
            next
          end

          relation = rfk_search_scope(model, scope)

          if query.present?
            columns = Array(search)
            escaped_query = model.sanitize_sql_like(query)
            search_pattern = rfk_search_pattern(escaped_query, match_strategy)
            predicates = columns.map do |column|
              model.arel_table[column].matches(search_pattern)
            end
            relation = relation.where(predicates.reduce { |left, right| left.or(right) })
          end

          relation = relation.distinct if distinct
          relation = relation.order(order) if order
          records = relation.limit(limit)
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

      def rfk_find_with(model:, label:, action: :show, value: :id, id_param: :id, ids_param: :ids, value_field: nil, label_field: nil, description: nil, badge: nil, description_field: nil, badge_field: nil, scope: nil, order: nil, preserve_order: false, wrap: nil)
        define_method(action) do
          ids = rfk_find_ids(id_param: id_param, ids_param: ids_param)
          relation = rfk_search_scope(model, scope)
          relation = relation.where(value => ids)
          relation = relation.order(order) if order
          records = relation.limit(ids.size)
          records = rfk_preserve_find_order(records, ids, value) if preserve_order || order.nil?
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

          payload = ids.one? ? options.first : options
          render json: rfk_wrap_find_result(payload, wrap: wrap, multiple: ids.many?)
        end
      end

      def rfk_create_with(model:, label:, action: :create, value: :id, create_attribute: nil, create_param: nil, value_field: nil, label_field: nil, description: nil, badge: nil, description_field: nil, badge_field: nil, permitted_attributes: nil, assign: nil, authorize: nil, before_save: nil, wrap: nil)
        define_method(action) do
          attribute_name = create_attribute || label
          param_name = create_param || RailsFieldsKit.configuration.default_create_param
          attributes = rfk_create_attributes(
            attribute_name: attribute_name,
            param_name: param_name,
            permitted_attributes: permitted_attributes
          )
          record = model.new(attributes)
          rfk_apply_assignments(record, assign) if assign

          unless rfk_authorized?(record, authorize)
            render json: {errors: {base: ["not authorized"]}}, status: :forbidden
            next
          end

          unless rfk_before_save(record, before_save)
            render json: {errors: rfk_record_errors(record, fallback: "could not be saved")}, status: :unprocessable_entity
            next
          end

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
            render json: {errors: rfk_record_errors(record)}, status: :unprocessable_entity
          end
        end
      end

      def rfk_token_suggestions_with(suggestions:, action: :index, query_param: nil, value_field: nil, label_field: nil, description_field: nil, badge_field: nil, match_fields: nil, limit: 20, wrap: nil)
        define_method(action) do
          query_key = query_param || RailsFieldsKit.configuration.default_query_param
          query = params[query_key].to_s
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

    private

    def rfk_search_scope(model, scope)
      case scope
      when nil
        model.all
      when Symbol, String
        model.public_send(scope)
      else
        scope.respond_to?(:call) ? instance_exec(&scope) : scope
      end
    end

    def rfk_search_pattern(escaped_query, match)
      case match
      when :contains
        "%#{escaped_query}%"
      when :prefix
        "#{escaped_query}%"
      when :exact
        escaped_query.to_s
      end
    end

    def rfk_find_ids(id_param:, ids_param:)
      ids_value = params[ids_param] || params[ids_param.to_s]
      ids = if ids_value
        ids_value.is_a?(String) ? ids_value.split(",") : Array(ids_value)
      else
        [params[id_param] || params[id_param.to_s]]
      end

      ids.map(&:to_s).map(&:strip).reject(&:empty?)
    end

    def rfk_preserve_find_order(records, ids, value)
      order_by_id = ids.each_with_index.to_h

      records.sort_by do |record|
        order_by_id.fetch(rfk_read_option_value(record, value).to_s, ids.length)
      end
    end

    def rfk_apply_assignments(record, assign)
      attributes = case assign
      when Symbol, String
        public_send(assign, record)
      when Hash
        assign
      else
        assign.respond_to?(:call) ? instance_exec(record, &assign) : assign
      end

      return unless attributes.respond_to?(:each)

      attributes.each do |attribute, value|
        writer = "#{attribute}="
        record.public_send(writer, value) if record.respond_to?(writer)
      end
    end

    def rfk_authorized?(record, authorize)
      return true unless authorize

      result = case authorize
      when Symbol, String
        public_send(authorize, record)
      else
        authorize.respond_to?(:call) ? instance_exec(record, &authorize) : authorize
      end

      result != false
    end

    def rfk_before_save(record, before_save)
      return true unless before_save

      result = case before_save
      when Symbol, String
        public_send(before_save, record)
      else
        before_save.respond_to?(:call) ? instance_exec(record, &before_save) : before_save
      end

      result != false
    end

    def rfk_record_errors(record, fallback: nil)
      if record.respond_to?(:errors) && record.errors.respond_to?(:to_hash)
        errors = record.errors.to_hash(true)
        return errors if errors.respond_to?(:empty?) && !errors.empty?
      end

      fallback ? {base: [fallback]} : {}
    end

    def rfk_option_json(record, value:, label:, value_field:, label_field:, description:, badge:, description_field:, badge_field:)
      option = {
        value_field || RailsFieldsKit.configuration.default_value_field => rfk_read_option_value(record, value),
        label_field || RailsFieldsKit.configuration.default_label_field => rfk_read_option_value(record, label)
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

      {wrap => options}
    end

    def rfk_wrap_option(option, wrap:)
      return option if wrap.nil? || wrap == false

      {wrap => option}
    end

    def rfk_wrap_find_result(payload, wrap:, multiple:)
      return payload if wrap.nil? || wrap == false

      {wrap => payload}
    end

    def rfk_create_attributes(attribute_name:, param_name:, permitted_attributes:)
      base_attributes = {attribute_name => params[param_name]}
      return base_attributes if permitted_attributes.nil?

      permitted = params.permit(*Array(permitted_attributes)).to_h.symbolize_keys
      base_attributes.merge(permitted)
    end

    def rfk_token_suggestion_options(suggestions, query:, value_field:, label_field:, description_field:, badge_field:, match_fields:)
      source = case suggestions
      when Symbol, String
        public_send(suggestions, query)
      else
        suggestions.respond_to?(:call) ? instance_exec(query, &suggestions) : suggestions
      end

      Array(source).map do |suggestion|
        rfk_token_suggestion_json(
          suggestion,
          value_field: value_field,
          label_field: label_field,
          description_field: description_field,
          badge_field: badge_field
        )
      end.select do |option|
        rfk_token_suggestion_matches?(option, query, match_fields: match_fields)
      end
    end

    def rfk_token_suggestion_json(suggestion, value_field:, label_field:, description_field:, badge_field:)
      value_key = value_field || RailsFieldsKit.configuration.default_value_field
      label_key = label_field || RailsFieldsKit.configuration.default_label_field
      description_key = description_field || RailsFieldsKit.configuration.default_option_description_field || "description"
      badge_key = badge_field || RailsFieldsKit.configuration.default_option_badge_field || "badge"

      case suggestion
      when Hash
        normalized = suggestion.transform_keys(&:to_s)
        value = rfk_token_suggestion_value_for(normalized, value_key, "value", "id", "token", "text", "label")
        label = rfk_token_suggestion_value_for(normalized, label_key, "text", "label", "name")
        label = value if label.nil?
        option = {value_key => value, label_key => label}
        option[description_key] = rfk_token_suggestion_value_for(normalized, description_key, "description") if normalized.key?(description_key) || normalized.key?("description")
        option[badge_key] = rfk_token_suggestion_value_for(normalized, badge_key, "badge") if normalized.key?(badge_key) || normalized.key?("badge")
        normalized.each do |key, value_for_key|
          option[key] = value_for_key unless option.key?(key)
        end
        option
      when Array
        {value_key => suggestion.second || suggestion.first, label_key => suggestion.first}
      else
        {value_key => suggestion.to_s, label_key => suggestion.to_s}
      end
    end

    def rfk_token_suggestion_value_for(normalized, *keys)
      keys.each do |key|
        next unless normalized.key?(key)

        value = normalized[key]
        return value unless value.nil?
      end

      nil
    end

    def rfk_token_suggestion_matches?(option, query, match_fields: nil)
      return true if query.to_s.empty?

      normalized_query = query.to_s.downcase
      values = if match_fields.nil?
        option.values
      else
        Array(match_fields).map { |field| option[field.to_s] }
      end

      values.any? { |value| value.to_s.downcase.include?(normalized_query) }
    end
  end
end
