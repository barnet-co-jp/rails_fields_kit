# frozen_string_literal: true

require "rails/generators"

module RailsFieldsKit
  module Generators
    class InstallGenerator < Rails::Generators::Base
      IMPORTMAP_PINS = {
        "rails_fields_kit" => "rails_fields_kit/index.js",
        "rails_fields_kit/tom_select_controller" => "rails_fields_kit/tom_select_controller.js"
      }.freeze

      source_root File.expand_path("templates", __dir__)

      desc "Creates Rails Fields Kit configuration and optional setup notes."
      class_option :importmap,
        type: :boolean,
        default: false,
        desc: "Append Rails Fields Kit importmap pins when config/importmap.rb exists."
      class_option :skip_setup_notes,
        type: :boolean,
        default: false,
        desc: "Skip generating doc/rails_fields_kit_setup.md while still creating the initializer."

      def copy_initializer
        template "rails_fields_kit.rb", "config/initializers/rails_fields_kit.rb"
      end

      def copy_setup_notes
        return if options[:skip_setup_notes]

        copy_file "rails_fields_kit_setup.md", "doc/rails_fields_kit_setup.md"
      end

      def add_importmap_pins
        self.importmap_pin_status = :not_requested
        return unless options[:importmap]

        importmap_path = "config/importmap.rb"
        absolute_path = File.join(destination_root, importmap_path)

        unless File.exist?(absolute_path)
          self.importmap_pin_status = :missing_file
          say "config/importmap.rb was not found; add Rails Fields Kit importmap pins manually if this app uses importmap.", :yellow
          return
        end

        missing_pins = IMPORTMAP_PINS.reject do |name, _target|
          importmap_pin_present?(absolute_path, name)
        end

        if missing_pins.empty?
          self.importmap_pin_status = :already_present
          say "Rails Fields Kit importmap pins already exist.", :green
          return
        end

        append_to_file importmap_path, "\n#{importmap_pin_lines(missing_pins)}\n"
        self.importmap_pin_status = :added
      end

      def show_next_steps
        say "Rails Fields Kit initializer created.", :green
        say "Next steps:", :yellow
        say "  1. Install Tom Select with your app's JavaScript toolchain: yarn add tom-select"
        say "  2. Register RailsFieldsKit::TomSelectController in your Stimulus application."
        say "  3. Load tom-select/dist/css/tom-select.css from your app stylesheet or bundler."
        say "  4. #{importmap_next_step}"
        say setup_notes_next_step
      end

      private

      attr_accessor :importmap_pin_status

      def setup_notes_next_step
        if options[:skip_setup_notes]
          "Setup examples remain in the maintained guide: https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/doc/setup.md"
        else
          "See doc/rails_fields_kit_setup.md for examples."
        end
      end

      def importmap_next_step
        case importmap_pin_status
        when :added
          "Rails Fields Kit importmap pins were added to config/importmap.rb."
        when :already_present
          "Rails Fields Kit importmap pins already exist in config/importmap.rb."
        when :missing_file
          "config/importmap.rb was not found; add the documented pins manually if this app uses importmap."
        else
          "If this app uses importmap, run with --importmap or add the documented pins manually."
        end
      end

      def importmap_pin_present?(path, name)
        File.read(path).match?(/^\s*pin\s+["']#{Regexp.escape(name)}["']/)
      end

      def importmap_pin_lines(pins)
        pins.map do |name, target|
          "pin #{name.inspect}, to: #{target.inspect}"
        end.join("\n")
      end
    end
  end
end
