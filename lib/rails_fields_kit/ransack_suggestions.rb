# frozen_string_literal: true

module RailsFieldsKit
  module RansackSuggestions
    DEFAULT_OPERATORS = ["OR", "not()"].freeze

    class << self
      def build(fields:, operators: DEFAULT_OPERATORS, saved_searches: nil, value_field: nil, label_field: nil, description_field: nil, badge_field: nil)
        keys = field_keys(
          value_field: value_field,
          label_field: label_field,
          description_field: description_field,
          badge_field: badge_field
        )

        RailsFieldsKit::TokenSuggestions.build(
          operators: operators,
          saved_searches: saved_searches,
          value_field: keys[:value],
          label_field: keys[:label],
          description_field: keys[:description],
          badge_field: keys[:badge]
        ) + field_suggestions(fields, keys)
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

      def field_suggestions(fields, keys)
        fields.flat_map do |name, config|
          field_name = name.to_s
          field_config = normalize_field_config(field_name, config)
          suggestions = [field_option(field_name, field_config, keys)]
          suggestions.concat(value_options(field_name, field_config, keys))
          suggestions
        end
      end

      def normalize_field_config(field_name, config)
        case config
        when Hash
          normalized = config.transform_keys(&:to_s)
          predicate = normalized["predicate"] || normalized["ransack_predicate"] || normalized["ransack"] || normalized["param"] || field_name
          normalized.merge("predicate" => predicate.to_s)
        else
          {
            "predicate" => config.to_s,
            "label" => field_name.humanize
          }
        end
      end

      def field_option(field_name, field_config, keys)
        label = field_config["label"] || field_name.humanize
        token = field_config["token"] || "#{field_name}:"
        description = field_config["description"] || "Ransack predicate #{field_config["predicate"]}"
        option(keys, token, label, description: description, badge: field_config["badge"] || "ransack").merge(
          "ransack_predicate" => field_config["predicate"],
          "ransack_field" => field_name
        )
      end

      def value_options(field_name, field_config, keys)
        values = field_config["values"] || field_config["predicates"]
        Array(values).map do |value|
          case value
          when Hash
            value_option_from_hash(field_name, field_config, value, keys)
          else
            text = value.to_s
            value_option(
              field_name,
              field_config,
              text,
              text.humanize,
              keys
            )
          end
        end
      end

      def value_option_from_hash(field_name, field_config, value, keys)
        normalized = value.transform_keys(&:to_s)
        raw_value = normalized["value"] || normalized["token"] || normalized["label"]
        token = normalized["token"] || "#{field_name}:#{raw_value}"
        label = normalized["label"] || normalized["text"] || raw_value.to_s.humanize
        option = value_option(
          field_name,
          field_config,
          raw_value,
          label,
          keys,
          token: token,
          description: normalized["description"],
          badge: normalized["badge"]
        )
        normalized.each do |key, metadata_value|
          option[key] = metadata_value unless option.key?(key) || key == "token"
        end
        option
      end

      def value_option(field_name, field_config, raw_value, label, keys, token: nil, description: nil, badge: nil)
        token ||= "#{field_name}:#{raw_value}"
        option(
          keys,
          token,
          label,
          description: description || "#{field_config["label"] || field_name.humanize} value",
          badge: badge || "value"
        ).merge(
          "ransack_predicate" => field_config["predicate"],
          "ransack_field" => field_name,
          "ransack_value" => raw_value
        )
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
