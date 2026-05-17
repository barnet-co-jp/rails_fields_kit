# frozen_string_literal: true

require "rails/generators"

module RailsFieldsKit
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a Rails Fields Kit initializer."

      def copy_initializer
        template "rails_fields_kit.rb", "config/initializers/rails_fields_kit.rb"
      end
    end
  end
end
