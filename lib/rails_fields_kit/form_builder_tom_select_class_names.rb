# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    private

    def rfk_promote_html_options!(options, html_options)
      %i[required readonly autocomplete].each do |key|
        html_options[key] = options.delete(key) if options.key?(key)
      end

      html_options[:disabled] = options.delete(:disabled) if [true, false].include?(options[:disabled])
      data = html_options[:data] ||= {}
      rfk_assign_data_value(data, :class_names, options.delete(:tom_select_class_names))
    end
  end
end
