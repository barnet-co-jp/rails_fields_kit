# frozen_string_literal: true

module RailsFieldsKit
  class Configuration
    attr_accessor :controller_name,
                  :default_query_param,
                  :default_create_param,
                  :default_value_field,
                  :default_label_field,
                  :default_search_field,
                  :default_plugins,
                  :default_min_length,
                  :wrapper_class,
                  :label_class,
                  :hint_class,
                  :error_class,
                  :field_error_class

    def initialize
      @controller_name = "rails-fields-kit--tom-select"
      @default_query_param = "q"
      @default_create_param = "text"
      @default_value_field = "value"
      @default_label_field = "text"
      @default_search_field = "text"
      @default_plugins = []
      @default_min_length = 0
      @wrapper_class = "rfk-field"
      @label_class = "rfk-label"
      @hint_class = "rfk-hint"
      @error_class = "rfk-error"
      @field_error_class = "rfk-field--error"
    end
  end
end
