# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "rails/engine"
require "rails_fields_kit/form_builder"
require "rails_fields_kit/form_builder_enum_i18n"
require "rails_fields_kit/form_builder_dependent_query_params"
require "rails_fields_kit/form_builder_check_box"
require "rails_fields_kit/form_builder_file_field"
require "rails_fields_kit/form_builder_label_fallback"
require "rails_fields_kit/form_builder_native_date_time_fields"
require "rails_fields_kit/form_builder_radio_button"
require "rails_fields_kit/form_builder_table_groups"
require "rails_fields_kit/form_builder_tom_select_class_names"
require "rails_fields_kit/form_builder_tom_select_behavior_options"
require "rails_fields_kit/option_html_context"

module RailsFieldsKit
  class Engine < ::Rails::Engine
    initializer "rails_fields_kit.assets" do |app|
      app.config.assets.paths << root.join("app/javascript") if app.config.respond_to?(:assets)
    end

    initializer "rails_fields_kit.form_builder" do
      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::FormBuilder.include RailsFieldsKit::FormBuilder
      end
    end

    rake_tasks do
      load root.join("lib/tasks/rails_fields_kit.rake").to_s
    end
  end
end
