# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilderEnumI18n
    private

    def rfk_enum_label(method, value, explicit: false)
      return value.to_s.humanize if explicit && !object.class.respond_to?(:human_attribute_name)

      i18n_key = RailsFieldsKit.configuration.enum_i18n_key.call(method, value)
      object.class.human_attribute_name(i18n_key, default: value.to_s.humanize)
    end
  end
end

RailsFieldsKit::FormBuilder.prepend(RailsFieldsKit::FormBuilderEnumI18n)
