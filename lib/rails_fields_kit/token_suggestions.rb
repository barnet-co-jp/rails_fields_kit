# frozen_string_literal: true

module RailsFieldsKit
  module TokenSuggestions
    DEFAULT_OPERATOR_LABELS = {
      "OR" => "OR",
      "not()" => "Not",
      "not:" => "Not",
      "AND" => "AND"
    }.freeze

    class << self
      def build(fields: nil, predicates: nil, operators: nil, saved_searches: nil, value_field: nil, label_field: nil, description_field: nil, badge_field: nil)
        keys = field_keys(
          value_field: value_field,
          label_field: label_field,
          description_field: description_field,
          badge_field: badge_field
        )

        suggestions = []
        suggestions.concat(operator_suggestions(operators, keys))
        suggestions.concat(field_suggestions(fields, keys))
        suggestions.concat(predicate_suggestions(predicates, keys))
        suggestions.concat(saved_search_suggestions(saved_searches, keys))
        suggestions
      end

      private

      def field_keys(value_field:, label_field:, description_field:, badge_field:)
        {
          value: value_field || RailsFieldsKit.configuration.default_value_field,
          label: label_field || RailsFieldsKit.configuration.default_label_field,
          description: description_field || RailsFieldsKit.configuration.default_option_description_field || "description",
          badge: badge_field || RailsFieldsKit.configuration.default_option_badge_field || "badge"
        }
      end

      def operator_suggestions(operators, keys)
        Array(operators).map do |operator|
          case operator
          when Hash
            option_from_hash(operator, keys, default_badge: "operator")
          else
            token = operator.to_s
            option(
              keys,
              token,
              DEFAULT_OPERATOR_LABELS.fetch(token, token),
              description: "Search operator",
              badge: "operator"
            )
          end
        end
      end

      def field_suggestions(fields, keys)
        case fields
        when nil
          []
        when Hash
          fields.flat_map do |name, config|
            field_name = name.to_s
            case config
            when Hash
              label = config[:label] || config["label"] || field_name.humanize
              token = config[:token] || config["token"] || "#{field_name}:"
              description = config[:description] || config["description"] || "Search by #{label}"
              badge = config[:badge] || config["badge"] || "field"
              values = config[:values] || config["values"]
              predicates = config[:predicates] || config["predicates"]
              field_options = [option(keys, token, label, description: description, badge: badge)]
              field_options.concat(value_suggestions(field_name, values, keys, label: label))
              field_options.concat(value_suggestions(field_name, predicates, keys, label: label))
              field_options
            else
              label = config || field_name.humanize
              option(keys, "#{field_name}:", label, description: "Search by #{label}", badge: "field")
            end
          end
        else
          Array(fields).map do |field|
            field_name = field.to_s
            option(keys, "#{field_name}:", field_name.humanize, description: "Search by #{field_name.humanize}", badge: "field")
          end
        end
      end

      def predicate_suggestions(predicates, keys)
        case predicates
        when nil
          []
        when Hash
          predicates.flat_map do |field_name, values|
            value_suggestions(field_name, values, keys)
          end
        else
          Array(predicates).map do |predicate|
            case predicate
            when Hash
              option_from_hash(predicate, keys, default_badge: "predicate")
            else
              token = predicate.to_s
              option(keys, token, token.humanize, description: "Search predicate", badge: "predicate")
            end
          end
        end
      end

      def saved_search_suggestions(saved_searches, keys)
        Array(saved_searches).map do |saved_search|
          case saved_search
          when Hash
            option_from_hash(saved_search, keys, default_badge: "saved")
          else
            token = saved_search.to_s
            option(keys, token, token, description: "Saved search", badge: "saved")
          end
        end
      end

      def value_suggestions(field_name, values, keys, label: nil)
        Array(values).map do |value|
          case value
          when Hash
            token = value[:token] || value["token"] || "#{field_name}:#{value[:value] || value["value"] || value[:label] || value["label"]}"
            option_from_hash(value.merge(token: token), keys, default_badge: "value")
          else
            text = value.to_s
            option(
              keys,
              "#{field_name}:#{text}",
              [label, text.humanize].compact.join(" "),
              description: "#{field_name.to_s.humanize} value",
              badge: "value"
            )
          end
        end
      end

      def option_from_hash(hash, keys, default_badge:)
        normalized = hash.transform_keys(&:to_s)
        token = normalized["token"] || normalized["value"] || normalized["text"] || normalized["label"]
        label = normalized["label"] || normalized["text"] || normalized["name"] || token
        option = option(
          keys,
          token,
          label,
          description: normalized["description"],
          badge: normalized["badge"] || default_badge
        )
        normalized.each do |key, value|
          option[key] = value unless option.key?(key) || key == "token"
        end
        option
      end

      def option(keys, value, label, description: nil, badge: nil)
        payload = {
          keys[:value] => value,
          keys[:label] => label
        }
        payload[keys[:description]] = description if description
        payload[keys[:badge]] = badge if badge
        payload
      end
    end
  end
end
