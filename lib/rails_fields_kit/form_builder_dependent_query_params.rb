# frozen_string_literal: true

require "json"

module RailsFieldsKit
  module FormBuilderDependentQueryParams
    private

    def rfk_tom_select_field(method, field_kind, collection: nil, **options)
      depends_on = options.delete(:depends_on)
      clear_on_dependency_change = options.delete(:clear_on_dependency_change)

      if depends_on || !clear_on_dependency_change.nil?
        html_options = (options[:html] || {}).dup
        data = rfk_dependent_query_params_data(html_options)
        rfk_assign_data_value(data, :depends_on, depends_on)
        rfk_assign_data_value(data, :clear_on_dependency_change, clear_on_dependency_change)
        html_options[:data] = data
        options[:html] = html_options
      end

      super
    end

    def rfk_dependent_query_params_data(html_options)
      symbol_data = html_options[:data]
      string_data = html_options["data"]
      data = {}
      data.merge!(string_data) if string_data.is_a?(Hash)
      data.merge!(symbol_data) if symbol_data.is_a?(Hash)
      data
    end
  end

  FormBuilder.prepend(FormBuilderDependentQueryParams)
end
