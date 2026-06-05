# frozen_string_literal: true

require "pathname"

module RailsFieldsKit
  class SetupDoctor
    IMPORTMAP_PINS = {
      "rails_fields_kit" => "rails_fields_kit/index.js",
      "rails_fields_kit/tom_select_controller" => "rails_fields_kit/tom_select_controller.js"
    }.freeze

    MANUAL_CHECKS = [
      ["Tom Select package", "Install Tom Select with the JavaScript package manager already used by this app."],
      ["Stimulus registration", "Register rails-fields-kit--tom-select on the Stimulus application this app already boots."],
      ["CSS import", "Load tom-select/dist/css/tom-select.css from the app stylesheet or bundler entrypoint."],
      ["Bundler alias", "If this app uses Vite or another bundler, verify the rails_fields_kit import aliases in that toolchain."]
    ].freeze

    Check = Struct.new(:key, :label, :status, :message, keyword_init: true)

    attr_reader :root

    def initialize(root: default_root)
      @root = Pathname.new(root.to_s)
    end

    def checks
      [initializer_check, importmap_check] + manual_checks
    end

    def report_lines
      ["Rails Fields Kit setup doctor", ""] + checks.map { |check| format_check(check) }
    end

    def run(io: $stdout)
      report_lines.each { |line| io.puts(line) }
      true
    end

    private

    def default_root
      if defined?(Rails) && Rails.respond_to?(:root) && Rails.root
        Rails.root
      else
        Dir.pwd
      end
    end

    def initializer_check
      path = root.join("config/initializers/rails_fields_kit.rb")

      if path.file?
        Check.new(
          key: :initializer,
          label: "Initializer",
          status: :ok,
          message: "Found config/initializers/rails_fields_kit.rb."
        )
      else
        Check.new(
          key: :initializer,
          label: "Initializer",
          status: :missing,
          message: "config/initializers/rails_fields_kit.rb was not found; run rails generate rails_fields_kit:install or confirm this app intentionally configures the gem elsewhere."
        )
      end
    end

    def importmap_check
      path = root.join("config/importmap.rb")

      unless path.file?
        return Check.new(
          key: :importmap,
          label: "Importmap pins",
          status: :manual,
          message: "config/importmap.rb was not found. Skip this item if the app does not use importmap; otherwise add the documented Rails Fields Kit pins manually."
        )
      end

      missing_pins = IMPORTMAP_PINS.keys.reject do |name|
        importmap_pin_present?(path.read, name)
      end

      if missing_pins.empty?
        Check.new(
          key: :importmap,
          label: "Importmap pins",
          status: :ok,
          message: "Rails Fields Kit importmap pins are present in config/importmap.rb."
        )
      else
        Check.new(
          key: :importmap,
          label: "Importmap pins",
          status: :missing,
          message: "Missing Rails Fields Kit importmap pins: #{missing_pins.join(", ")}."
        )
      end
    end

    def manual_checks
      MANUAL_CHECKS.map do |label, message|
        Check.new(
          key: label.downcase.tr(" ", "_").to_sym,
          label: label,
          status: :manual,
          message: message
        )
      end
    end

    def importmap_pin_present?(content, name)
      content.match?(/^\s*pin\s+["']#{Regexp.escape(name)}["']/)
    end

    def format_check(check)
      "[#{check.status.to_s.upcase}] #{check.label}: #{check.message}"
    end
  end
end
