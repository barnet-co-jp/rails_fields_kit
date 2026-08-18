# frozen_string_literal: true

require "rails/generators"
require "rails_fields_kit/setup_doctor"

module RailsFieldsKit
  module Generators
    class InstallGenerator < Rails::Generators::Base
      IMPORTMAP_PINS = RailsFieldsKit::SetupDoctor::IMPORTMAP_PINS

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

        content = File.read(absolute_path)
        missing_pins = IMPORTMAP_PINS.reject do |name, _target|
          importmap_pin_present?(content, name)
        end
        target_mismatches = IMPORTMAP_PINS.filter_map do |name, expected_target|
          next unless importmap_pin_present?(content, name)

          actual_target = importmap_pin_target(content, name)
          next if actual_target == expected_target

          [name, expected_target, actual_target]
        end

        unless target_mismatches.empty?
          say "Rails Fields Kit importmap pins have unexpected targets: #{format_importmap_target_mismatches(target_mismatches)}. Existing pins were not changed.", :yellow
        end

        if missing_pins.empty?
          if target_mismatches.empty?
            self.importmap_pin_status = :already_present
            say "Rails Fields Kit importmap pins already exist.", :green
          else
            self.importmap_pin_status = :target_mismatch
          end
          return
        end

        append_to_file importmap_path, "\n#{importmap_pin_lines(missing_pins)}\n"
        self.importmap_pin_status = target_mismatches.empty? ? :added : :added_with_target_mismatch
      end

      def show_next_steps
        say "Rails Fields Kit initializer created.", :green
        say "Next steps:", :yellow
        say "  1. Install Tom Select with your app's JavaScript toolchain: yarn add tom-select"
        say "  2. Import { TomSelectController } from \"rails_fields_kit\" and register it " \
          "as \"rails-fields-kit--tom-select\" in your Stimulus application."
        say "  3. Load tom-select/dist/css/tom-select.css from your app stylesheet or bundler."
        say "  4. #{importmap_next_step}"
        say "  5. Run rails rails_fields_kit:doctor to review detectable setup state and manual checklist items."
        say setup_notes_next_step
      end

      private

      attr_accessor :importmap_pin_status

      def setup_notes_next_step
        if options[:skip_setup_notes]
          "Use `bundle show rails_fields_kit` and read doc/setup.md from that installed gem so the guide matches this app's resolved version."
        else
          "See doc/rails_fields_kit_setup.md for version-matched documentation guidance and examples."
        end
      end

      def importmap_next_step
        case importmap_pin_status
        when :added
          "Rails Fields Kit importmap pins were added to config/importmap.rb."
        when :added_with_target_mismatch
          "Missing Rails Fields Kit importmap pins were added to config/importmap.rb. Existing pins with unexpected targets were not changed; update those targets manually."
        when :already_present
          "Rails Fields Kit importmap pins already exist in config/importmap.rb."
        when :target_mismatch
          "Rails Fields Kit importmap pins with unexpected targets were not changed; update those targets manually."
        when :missing_file
          "config/importmap.rb was not found; add the documented pins manually if this app uses importmap."
        else
          "If this app uses importmap, run with --importmap or add the documented pins manually."
        end
      end

      def importmap_pin_present?(content, name)
        content.match?(/^\s*pin\s+["']#{Regexp.escape(name)}["']/)
      end

      def importmap_pin_target(content, name)
        match = content.match(/^\s*pin\s+["']#{Regexp.escape(name)}["'](?:\s*,\s*to:\s*["']([^"']+)["'])?/)
        match && match[1]
      end

      def format_importmap_target_mismatches(target_mismatches)
        target_mismatches.map do |name, expected_target, actual_target|
          actual_target_label = actual_target || "no explicit target"
          "#{name} (expected #{expected_target}, found #{actual_target_label})"
        end.join(", ")
      end

      def importmap_pin_lines(pins)
        pins.map do |name, target|
          "pin #{name.inspect}, to: #{target.inspect}"
        end.join("\n")
      end
    end
  end
end
