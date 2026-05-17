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
                  :default_min_length

    def initialize
      @controller_name = "rails-fields-kit--tom-select"
      @default_query_param = "q"
      @default_create_param = "text"
      @default_value_field = "value"
      @default_label_field = "text"
      @default_search_field = "text"
      @default_plugins = []
      @default_min_length = 0
    end
  end
end
