# frozen_string_literal: true

require "rails/engine"
require "rails_fields_kit/form_builder"

module RailsFieldsKit
  class Engine < ::Rails::Engine
    isolate_namespace RailsFieldsKit

    initializer "rails_fields_kit.form_builder" do
      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::FormBuilder.include RailsFieldsKit::FormBuilder
      end
    end
  end
end
