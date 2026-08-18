# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilderTomSelectBehaviorOptions
    private

    TOM_SELECT_BEHAVIOR_OPTIONS = %i[
      add_precedence
      create_on_blur
      clear_after_select
    ].freeze

    def rfk_tom_select_field(method, field_kind, collection: nil, **options)
      behavior_options = {}
      TOM_SELECT_BEHAVIOR_OPTIONS.each do |key|
        behavior_options[key] = options.delete(key) if options.key?(key)
      end

      if behavior_options.any?
        html_options = (options[:html] || {}).dup
        data = rfk_tom_select_behavior_data(html_options)
        behavior_options.each { |key, value| rfk_assign_data_value(data, key, value) }
        html_options[:data] = data
        options[:html] = html_options
      end

      super
    end

    def rfk_tom_select_behavior_data(html_options)
      data = {}
      string_data = html_options["data"]
      symbol_data = html_options[:data]
      data.merge!(string_data) if string_data.is_a?(Hash)
      data.merge!(symbol_data) if symbol_data.is_a?(Hash)
      data
    end
  end

  FormBuilder.prepend(FormBuilderTomSelectBehaviorOptions)
end
