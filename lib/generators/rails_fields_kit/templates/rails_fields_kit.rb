# frozen_string_literal: true

RailsFieldsKit.configure do |config|
  # Stimulus controller name used by Rails Fields Kit helpers.
  config.controller_name = "rails-fields-kit--tom-select"

  # Query parameter used for remote search requests.
  config.default_query_param = "q"

  # Query parameters used for selected option preload requests.
  config.default_selected_param = "id"
  config.default_selected_multiple_param = "ids"

  # JSON key sent when create-on-the-fly posts a new option.
  config.default_create_param = "text"

  # Default Tom Select field names for remote JSON options.
  config.default_value_field = "value"
  config.default_label_field = "text"
  config.default_search_field = "text"

  # Default Tom Select remote search behavior.
  config.default_min_length = 0
  config.default_max_options = nil
  config.default_load_throttle = nil
  config.default_preload = nil

  # Default Tom Select UX behavior. Leave nil to use Tom Select defaults.
  config.default_open_on_focus = nil
  config.default_close_after_select = nil
  config.default_hide_selected = nil
  config.default_persist = nil

  # Default Tom Select rendered messages.
  # Leave these unset to use the bundled locale-aware copy.
  # config.default_no_results_text = "No results found"
  # config.default_loading_text = "Loading..."
  # config.default_create_text = "Add"

  # Default rich option render fields.
  config.default_option_description_field = nil
  config.default_option_badge_field = nil

  # Default Tom Select plugins applied by helpers.
  config.default_plugins = []

  # Add Tom Select's clear_button plugin when a helper omits allow_clear:.
  config.default_allow_clear = false

  # Optional wrapper classes used when helpers are called with wrapper: true.
  config.wrapper_class = "rfk-field"
  config.label_class = "rfk-label"
  config.hint_class = "rfk-hint"
  config.error_class = "rfk-error"
  config.field_error_class = "rfk-field--error"
  config.control_class = "rfk-control"
  config.prefix_class = "rfk-prefix"
  config.suffix_class = "rfk-suffix"
end
