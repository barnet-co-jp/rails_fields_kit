# frozen_string_literal: true

RailsFieldsKit.configure do |config|
  # Stimulus controller name used by Rails Fields Kit helpers.
  config.controller_name = "rails-fields-kit--tom-select"

  # Query parameter used for remote search requests.
  config.default_query_param = "q"

  # JSON key sent when create-on-the-fly posts a new option.
  config.default_create_param = "text"

  # Default Tom Select field names for remote JSON options.
  config.default_value_field = "value"
  config.default_label_field = "text"
  config.default_search_field = "text"

  # Minimum query length before remote search runs.
  config.default_min_length = 0

  # Default Tom Select plugins applied by helpers.
  config.default_plugins = []
end
