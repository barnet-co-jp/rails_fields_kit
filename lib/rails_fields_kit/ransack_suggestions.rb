# frozen_string_literal: true

module RailsFieldsKit
  class RansackSuggestions
    class << self
      def build(fields:, query:, predicates: nil, values: nil, selected_field: nil, selected_predicate: nil, selected_value: nil, value_field: "value", label_field: "text", description_field: "description", badge_field: "badge", limit: 20)
        keys = {
          value: value_field,
          label: label_field,
          description: description_field,
          badge: badge_field
        }
        normalized_query = query.to_s.strip

        options = if normalized_query.empty?
          field_options(fields, predicates, values, keys)
        elsif normalized_query.include?(":")
          value_options(fields, normalized_query, predicates, values, keys)
        else
          predicate_options(fields, normalized_query, predicates, values, keys)
        end

        selected_option = selected_option(fields, selected_field, selected_predicate, selected_value, keys)
        options = [selected_option, *options] if selected_option
        options.uniq.first(limit)
      end

      private

      def field_options(fields, predicates, values, keys)
        Array(fields).flat_map do |field|
          field_name, field_config = normalize_field(field)
          Array(predicates || field_config["predicates"] || ["cont"]).map do |predicate|
            option(
              keys,
              "#{field_name}_#{predicate}",
              "#{field_config["label"] || field_name.humanize} #{predicate_label(predicate)}",
              description: field_config["description"],
              badge: field_config["badge"]
            )
          end
        end
      end

      def predicate_options(fields, query, predicates, values, keys)
        Array(fields).flat_map do |field|
          field_name, field_config = normalize_field(field)
          next [] unless matches?(field_name, field_config, query)

          Array(predicates || field_config["predicates"] || ["cont"]).map do |predicate|
            option(
              keys,
              "#{field_name}_#{predicate}",
              "#{field_config["label"] || field_name.humanize} #{predicate_label(predicate)}",
              description: field_config["description"],
              badge: field_config["badge"]
            )
          end
        end
      end

      def value_options(fields, raw_value, predicates, values, keys)
        field_name, query = raw_value.split(":", 2)
        return [] if query.to_s.empty?

        field = Array(fields).find { |candidate| normalize_field(candidate).first == field_name }
        return [] unless field

        normalized_field_name, field_config = normalize_field(field)
        predicate = Array(predicates || field_config["predicates"] || ["cont"]).first
        candidates = values.respond_to?(:call) ? values.call(normalized_field_name, query) : Array(values)

        candidates.map do |candidate|
          normalized = normalize_value(candidate)
          option(
            keys,
            "#{normalized_field_name}_#{predicate}:#{normalized["value"]}",
            normalized["label"],
            description: normalized["description"],
            badge: normalized["badge"]
          )
        end
      end

      def selected_option(fields, selected_field, selected_predicate, selected_value, keys)
        return unless selected_field && selected_predicate

        field = Array(fields).find { |candidate| normalize_field(candidate).first == selected_field.to_s }
        return unless field

        field_name, field_config = normalize_field(field)
        label = "#{field_config["label"] || field_name.humanize} #{predicate_label(selected_predicate)}"
        label = "#{label}: #{selected_value}" if selected_value
        option(
          keys,
          [field_name, selected_predicate, selected_value].compact.join(":"),
          label,
          description: field_config["description"],
          badge: field_config["badge"]
        )
      end

      def normalize_field(field)
        case field
        when Hash
          [field[:name]&.to_s || field["name"].to_s, field.transform_keys(&:to_s)]
        else
          [field.to_s, {}]
        end
      end

      def normalize_value(value)
        case value
        when Hash
          normalized = value.transform_keys(&:to_s)
          {
            "value" => normalized["value"] || normalized["id"] || normalized["text"] || normalized["label"],
            "label" => normalized["label"] || normalized["text"] || normalized["name"] || normalized["value"] || normalized["id"],
            "description" => normalized["description"],
            "badge" => normalized["badge"]
          }
        when Array
          {
            "value" => value.second || value.first,
            "label" => value.first,
            "description" => nil,
            "badge" => nil
          }
        else
          {
            "value" => value.to_s,
            "label" => value.to_s,
            "description" => nil,
            "badge" => nil
          }
        end
      end

      def predicate_label(predicate)
        predicate.to_s.tr("_", " ")
      end

      def matches?(field_name, field_config, query)
        normalized_query = query.to_s.downcase
        [field_name, field_config["label"], field_config["description"], field_config["badge"]]
          .compact
          .any? { |value| value.to_s.downcase.include?(normalized_query) }
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
