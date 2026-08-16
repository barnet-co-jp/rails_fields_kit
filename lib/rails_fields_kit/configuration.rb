# frozen_string_literal: true

module RailsFieldsKit
  class Configuration
    DEFAULT_NO_RESULTS_TEXT = :__rails_fields_kit_default_no_results_text__
    DEFAULT_LOADING_TEXT = :__rails_fields_kit_default_loading_text__
    DEFAULT_CREATE_TEXT = :__rails_fields_kit_default_create_text__

    attr_accessor :controller_name,
      :default_query_param,
      :default_selected_param,
      :default_selected_multiple_param,
      :default_create_param,
      :default_value_field,
      :default_label_field,
      :default_search_field,
      :default_plugins,
      :default_allow_clear,
      :default_min_length,
      :default_max_options,
      :default_load_throttle,
      :default_preload,
      :default_open_on_focus,
      :default_close_after_select,
      :default_hide_selected,
      :default_persist,
      :default_no_results_text,
      :default_loading_text,
      :default_create_text,
      :default_option_description_field,
      :default_option_badge_field,
      :wrapper_class,
      :label_class,
      :hint_class,
      :error_class,
      :field_error_class,
      :control_class,
      :prefix_class,
      :suffix_class

    def initialize
      @controller_name = "rails-fields-kit--tom-select"
      @default_query_param = "q"
      @default_selected_param = "id"
      @default_selected_multiple_param = "ids"
      @default_create_param = "text"
      @default_value_field = "value"
      @default_label_field = "text"
      @default_search_field = "text"
      @default_plugins = []
      @default_allow_clear = false
      @default_min_length = 0
      @default_max_options = nil
      @default_load_throttle = nil
      @default_preload = nil
      @default_open_on_focus = nil
      @default_close_after_select = nil
      @default_hide_selected = nil
      @default_persist = nil
      @default_no_results_text = DEFAULT_NO_RESULTS_TEXT
      @default_loading_text = DEFAULT_LOADING_TEXT
      @default_create_text = DEFAULT_CREATE_TEXT
      @default_option_description_field = nil
      @default_option_badge_field = nil
      @wrapper_class = "rfk-field"
      @label_class = "rfk-label"
      @hint_class = "rfk-hint"
      @error_class = "rfk-error"
      @field_error_class = "rfk-field--error"
      @control_class = "rfk-control"
      @prefix_class = "rfk-prefix"
      @suffix_class = "rfk-suffix"
    end
  end
end
