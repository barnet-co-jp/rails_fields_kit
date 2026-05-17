# frozen_string_literal: true

require "rails/generators"

module RailsFieldsKit
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates Rails Fields Kit configuration and setup notes."

      def copy_initializer
        template "rails_fields_kit.rb", "config/initializers/rails_fields_kit.rb"
      end

      def copy_setup_notes
        copy_file "rails_fields_kit_setup.md", "doc/rails_fields_kit_setup.md"
      end

      def show_next_steps
        say "Rails Fields Kit initializer created.", :green
        say "Next steps:", :yellow
        say "  1. Install Tom Select with your app's JavaScript toolchain: yarn add tom-select"
        say "  2. Register RailsFieldsKit::TomSelectController in your Stimulus application."
        say "  3. Load tom-select/dist/css/tom-select.css from your app stylesheet or bundler."
        say "See doc/rails_fields_kit_setup.md for examples."
      end
    end
  end
end
