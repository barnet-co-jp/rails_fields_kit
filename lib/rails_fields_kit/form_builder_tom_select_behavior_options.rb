# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilderTomSelectBehaviorOptions
    private

    def rfk_tom_select_field(method, field_kind, collection: nil, **options)
      behavior_options = {
        add_precedence: options.delete(:add_precedence),
        create_on_blur: options.delete(:create_on_blur),
        clear_after_select: options.delete(:clear_after_select)
      }

      if behavior_options.values.any? { |value| !value.nil? }
        html_options = (options[:html] || {}).dup
        data = (html_options[:data] || {}).dup
        behavior_options.each { |key, value| rfk_assign_data_value(data, key, value) }
        html_options[:data] = data
        options[:html] = html_options
      end

      super
    end
  end

  FormBuilder.prepend(FormBuilderTomSelectBehaviorOptions)
end
