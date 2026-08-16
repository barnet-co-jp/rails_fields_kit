# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    def rfk_radio_button(method, tag_value, **options)
      wrapper_options = rfk_extract_wrapper_options(options)
      html_options = options.delete(:html) || {}
      field_options = options.merge(html_options)
      rfk_apply_accessibility!(method, field_options, wrapper_options)
      field_html = radio_button(method, tag_value, field_options)
      field_html = rfk_wrap_control(field_html, wrapper_options)
      rfk_apply_radio_label_value!(tag_value, wrapper_options)

      rfk_wrap_field(method, field_html, wrapper_options)
    end

    private

    def rfk_apply_radio_label_value!(tag_value, wrapper_options)
      return if wrapper_options[:label] == false

      label_html = wrapper_options[:label_html]
      label_html[:value] = tag_value unless label_html.key?(:value) || label_html.key?("value")
    end
  end
end
