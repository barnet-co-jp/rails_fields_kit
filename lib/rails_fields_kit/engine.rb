# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "rails/engine"
require "rails_fields_kit/form_builder"

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
  end
end
