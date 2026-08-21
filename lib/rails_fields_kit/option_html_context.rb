# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    private

    def rfk_normalize_collection(collection, value_method:, label_method:, disabled: nil, option_html: {})
      disabled_values = Array(disabled).map(&:to_s)

      case collection
      when nil
        []
      when Hash
        collection.map do |label, value|
          rfk_choice_with_html(label, value, disabled_values: disabled_values, option_html: option_html)
        end
      else
        collection.map do |item|
          if item.is_a?(Array) && item.size == 2
            rfk_choice_with_html(item.first, item.second, disabled_values: disabled_values, option_html: option_html)
          else
            value = rfk_read_selected_value(item, value_method)
            label = rfk_read_selected_label(item, label_method)
            rfk_choice_with_html(label, value, disabled_values: disabled_values, option_html: option_html, item: item)
          end
        end
      end
    end

    def rfk_choice_with_html(label, value, disabled_values:, option_html:, item: nil)
      html = rfk_option_html_for(value, option_html, label: label, item: item)
      html[:disabled] = true if disabled_values.include?(value.to_s)
      html.empty? ? [label, value] : [label, value, html]
    end

    def rfk_option_html_for(value, option_html, label: nil, item: nil)
      case option_html
      when Proc
        rfk_call_option_html_proc(option_html, value, label, item) || {}
      when Hash
        option_html[value] || option_html[value.to_s] || {}
      else
        {}
      end
    end

    def rfk_call_option_html_proc(option_html, value, label, item)
      parameters = option_html.parameters

      return option_html.call(value, label, item) if parameters.any? { |kind, _name| kind == :rest }

      argument_count = parameters.count { |kind, _name| %i[req opt].include?(kind) }

      case argument_count
      when 0
        option_html.call
      when 1
        option_html.call(value)
      when 2
        option_html.call(value, label)
      else
        option_html.call(value, label, item)
      end
    end
  end
end
