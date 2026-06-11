# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    def rfk_grouped_select(method, grouped_collection:, **options)
      grouped_disabled = options[:disabled] unless [true, false].include?(options[:disabled])
      options.delete(:disabled) unless [true, false].include?(options[:disabled])
      options.delete(:option_html)

      if grouped_disabled
        options[:selected] = rfk_grouped_select_selected_options(method, options[:selected], grouped_disabled)
      end

      options[:grouped_collection] = grouped_collection
      rfk_tom_select_field(method, :select, collection: nil, **options)
    end

    private

    def rfk_grouped_select_selected_options(method, selected, disabled)
      disabled_values = Array(disabled).map(&:to_s)

      if selected.is_a?(Hash)
        selected.merge(disabled: Array(selected[:disabled] || selected["disabled"]).map(&:to_s) | disabled_values)
      else
        selected_value = selected
        selected_value = object.public_send(method) if selected_value.nil? && object.respond_to?(method)
        return {disabled: disabled_values} if selected_value.nil?

        {selected: selected_value, disabled: disabled_values}
      end
    end
  end
end
