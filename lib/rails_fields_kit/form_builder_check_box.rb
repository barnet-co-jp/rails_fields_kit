# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    def rfk_check_box(method, checked_value: "1", unchecked_value: "0", **options)
      wrapper_options = rfk_extract_wrapper_options(options)
      html_options = options.delete(:html) || {}
      field_options = options.merge(html_options)
      rfk_apply_accessibility!(method, field_options, wrapper_options)
      field_html = check_box(method, field_options, checked_value, unchecked_value)
      field_html = rfk_wrap_control(field_html, wrapper_options)

      rfk_wrap_field(method, field_html, wrapper_options)
    end
  end
end
