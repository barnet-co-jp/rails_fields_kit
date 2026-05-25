# frozen_string_literal: true

module RailsFieldsKit
  class TokenSuggestions
    class << self
      def build(source, query:, value_field: "value", label_field: "text", description_field: "description", badge_field: "badge", limit: 20)
        keys = {
          value: value_field,
          label: label_field,
          description: description_field,
          badge: badge_field
        }

        Array(source).filter_map do |item|
          normalized = normalize(item)
          next unless matches?(normalized, query)

          option(
            keys,
            normalized["value"] || normalized["id"] || normalized["token"] || normalized["text"] || normalized["label"],
            normalized["text"] || normalized["label"] || normalized["name"] || normalized["value"] || normalized["id"] || normalized["token"],
            description: normalized["description"],
            badge: normalized["badge"] || default_badge
          )
        end.first(limit)
      end

      def matches?(option, query)
        return true if query.to_s.empty?

        normalized_query = query.to_s.downcase
        option.values.any? { |value| value.to_s.downcase.include?(normalized_query) }
      end

      private

      def normalize(item)
        case item
        when Hash
          item.transform_keys(&:to_s)
        when Array
          {"label" => item.first, "value" => item.second || item.first}
        else
          {"label" => item.to_s, "value" => item.to_s}
        end
      end

      def default_badge
        nil
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
