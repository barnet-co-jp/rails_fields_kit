# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    def rfk_grouped_select(method, grouped_collection:, **options)
      grouped_disabled = options[:disabled] unless [true, false].include?(options[:disabled])
      options.delete(:disabled) unless [true, false].include?(options[:disabled])
      option_html = options.delete(:option_html) || {}
      value_method = options[:collection_value_method] || options[:value_method] || :id
      label_method = options[:collection_label_method] || options[:label_method] || :to_s

      options[:grouped_collection] = grouped_collection.map do |group_label, items|
        [
          group_label,
          rfk_normalize_collection(
            items,
            value_method: value_method,
            label_method: label_method,
            disabled: grouped_disabled,
            option_html: option_html
          )
        ]
      end
      rfk_tom_select_field(method, :select, collection: nil, **options)
    end

    private

    def rfk_normalize_collection(collection, value_method:, label_method:, disabled: nil, option_html: {})
      disabled_values = Array(disabled).map(&:to_s)

      case collection
      when nil
        []
      when Hash
        collection.map { |label, value| rfk_choice_with_html(label, value, disabled_values: disabled_values, option_html: option_html) }
      else
        collection.map do |item|
          if item.is_a?(Array) && item.size == 3 && item[2].is_a?(Hash)
            item
          elsif item.is_a?(Array) && item.size == 2
            rfk_choice_with_html(item.first, item.second, disabled_values: disabled_values, option_html: option_html)
          else
            value = rfk_read_selected_value(item, value_method)
            label = rfk_read_selected_label(item, label_method)
            rfk_choice_with_html(label, value, disabled_values: disabled_values, option_html: option_html)
          end
        end
      end
    end
  end
end
