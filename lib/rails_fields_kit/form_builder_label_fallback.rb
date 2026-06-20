# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilderLabelFallback
    private

    def rfk_tom_select_field(method, field_kind, collection: nil, **options)
      if options.key?(:label_fallback)
        html_options = options[:html] ||= {}
        data = html_options[:data] ||= {}
        data[:rails_fields_kit__tom_select_label_fallback_value] = options.delete(:label_fallback)
      end

      super
    end
  end
end

RailsFieldsKit::FormBuilder.prepend RailsFieldsKit::FormBuilderLabelFallback
