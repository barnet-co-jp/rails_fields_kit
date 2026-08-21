# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    def rfk_file_field(method, **options)
      rfk_native_field(method, :file_field, **options)
    end
  end
end
