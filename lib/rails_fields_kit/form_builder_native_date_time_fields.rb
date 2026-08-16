# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    def rfk_date_field(method, **options)
      rfk_native_field(method, :date_field, **options)
    end

    def rfk_time_field(method, **options)
      rfk_native_field(method, :time_field, **options)
    end

    def rfk_datetime_local_field(method, **options)
      rfk_native_field(method, :datetime_local_field, **options)
    end

    def rfk_color_field(method, **options)
      rfk_native_field(method, :color_field, **options)
    end
  end
end
