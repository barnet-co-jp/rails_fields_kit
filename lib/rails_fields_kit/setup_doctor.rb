# frozen_string_literal: true

require "json"
require "pathname"

module RailsFieldsKit
  class SetupDoctor
    SETUP_NOTE_PATH = "doc/rails_fields_kit_setup.md"

    IMPORTMAP_PINS = {
      "rails_fields_kit" => "rails_fields_kit/index.js",
      "rails_fields_kit/native_field_accessibility_contract" => "rails_fields_kit/native_field_accessibility_contract.js",
      "rails_fields_kit/native_field_constraint_contract" => "rails_fields_kit/native_field_constraint_contract.js",
      "rails_fields_kit/read_rendered_error_surface" => "rails_fields_kit/read_rendered_error_surface.js",
      "rails_fields_kit/tom_select_controller" => "rails_fields_kit/tom_select_controller.js",
      "rails_fields_kit/tom_select_plugin_contract" => "rails_fields_kit/tom_select_plugin_contract.js",
      "rails_fields_kit/tom_select_text_override_contract" => "rails_fields_kit/tom_select_text_override_contract.js"
    }.freeze

    CSS_IMPORT_CANDIDATE_PATHS = [
      "app/assets/stylesheets/application.css",
      "app/assets/stylesheets/application.scss",
      "app/assets/stylesheets/application.sass",
      "app/javascript/application.js",
      "app/javascript/application.ts",
      "app/javascript/entrypoints/application.js",
      "app/javascript/entrypoints/application.ts",
      "app/javascript/entrypoints/application.jsx",
      "app/javascript/entrypoints/application.tsx",
      "app/frontend/entrypoints/application.js",
      "app/frontend/entrypoints/application.ts",
      "app/frontend/entrypoints/application.jsx",
      "app/frontend/entrypoints/application.tsx"
    ].freeze

    STIMULUS_REGISTRATION_CANDIDATE_PATHS = [
      "app/javascript/application.js",
      "app/javascript/application.ts",
      "app/javascript/controllers/index.js",
      "app/javascript/controllers/index.ts",
      "app/javascript/entrypoints/application.js",
      "app/javascript/entrypoints/application.ts",
      "app/javascript/entrypoints/application.jsx",
      "app/javascript/entrypoints/application.tsx",
      "app/frontend/entrypoints/application.js",
      "app/frontend/entrypoints/application.ts",
      "app/frontend/entrypoints/application.jsx",
      "app/frontend/entrypoints/application.tsx"
    ].freeze

    STIMULUS_REGISTRATION_SIGNALS = [
      "rails-fields-kit--tom-select",
      "TomSelectController"
    ].freeze

    BUNDLER_ALIAS_CANDIDATE_PATHS = [
      "vite.config.js",
      "vite.config.mjs",
      "vite.config.ts",
      "vite.config.mts",
      "config/vite.config.js",
      "config/vite.config.ts",
      "webpack.config.js",
      "webpack.config.mjs",
      "webpack.config.ts",
      "config/webpack/environment.js",
      "config/webpack/development.js",
      "config/webpack/production.js"
    ].freeze

    BUNDLER_ALIASES = [
      "rails_fields_kit",
      "rails_fields_kit/native_field_accessibility_contract",
      "rails_fields_kit/native_field_constraint_contract",
      "rails_fields_kit/read_rendered_error_surface",
      "rails_fields_kit/tom_select_controller",
      "rails_fields_kit/tom_select_plugin_contract",
      "rails_fields_kit/tom_select_text_override_contract"
    ].freeze

    TOM_SELECT_CSS_IMPORT_PATTERN = %r{tom-select/dist/css/tom-select(?:[.\w-]*)\.css}

    STATUS_LEGEND_LINES = [
      "Status legend: [OK] detected setup; [MISSING] needs action for the detected setup route; [MANUAL] host-app check, not an automatic failure.",
      "Next step: fix [MISSING] lines first, then review [MANUAL] lines for this app's JavaScript toolchain."
    ].freeze

    # Keep keyword initialization explicit because checks are constructed from named fields.
    # rubocop:disable Style/RedundantStructKeywordInit
    Check = Struct.new(:key, :label, :status, :message, keyword_init: true)
    # rubocop:enable Style/RedundantStructKeywordInit

    attr_reader :root

    def initialize(root: default_root)
      @root = Pathname.new(root.to_s)
    end

    def checks
      [
        initializer_check,
        generated_setup_note_check,
        importmap_check,
        tom_select_package_check,
        stimulus_registration_check,
        css_import_check,
        bundler_alias_check
      ]
    end

    def report_lines
      ["Rails Fields Kit setup doctor", ""] + STATUS_LEGEND_LINES + [""] + checks.map { |check| format_check(check) }
    end

    def report_payload
      report_checks = checks

      {
        "schema_version" => 1,
        "tool" => "rails_fields_kit:doctor",
        "summary" => {
          "ok" => report_checks.count { |check| check.status == :ok },
          "missing" => report_checks.count { |check| check.status == :missing },
          "manual" => report_checks.count { |check| check.status == :manual }
        },
        "checks" => report_checks.map { |check| format_check_payload(check) }
      }
    end

    def run(io: $stdout, format: :text)
      case format.to_s
      when "text", ""
        report_lines.each { |line| io.puts(line) }
      when "json"
        io.puts(JSON.pretty_generate(report_payload))
      else
        raise ArgumentError, "Unsupported setup doctor format: #{format.inspect}"
      end

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

    def generated_setup_note_check
      path = root.join(SETUP_NOTE_PATH)

      if path.file?
        Check.new(
          key: :generated_setup_note,
          label: "Generated setup note",
          status: :ok,
          message: "Found #{SETUP_NOTE_PATH}. Keep app-specific setup notes there and use doc/setup.md as the maintained reference."
        )
      else
        Check.new(
          key: :generated_setup_note,
          label: "Generated setup note",
          status: :manual,
          message: "#{SETUP_NOTE_PATH} was not found. This is OK when the app used --skip-setup-notes or keeps setup notes elsewhere; setup doctor does not create the note or inspect app-specific checklist quality."
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

      content = path.read
      missing_pins = IMPORTMAP_PINS.keys.reject do |name|
        importmap_pin_declared?(content, name)
      end
      target_mismatches = IMPORTMAP_PINS.filter_map do |name, expected_target|
        next unless importmap_pin_declared?(content, name)

        actual_target = importmap_pin_target(content, name)
        next if actual_target == expected_target

        [name, expected_target, actual_target]
      end

      if missing_pins.empty? && target_mismatches.empty?
        Check.new(
          key: :importmap,
          label: "Importmap pins",
          status: :ok,
          message: "Rails Fields Kit importmap pins are present in config/importmap.rb."
        )
      else
        message_parts = []
        message_parts << "Missing Rails Fields Kit importmap pins: #{missing_pins.join(", ")}." unless missing_pins.empty?
        unless target_mismatches.empty?
          message_parts << "Rails Fields Kit importmap pins with unexpected targets: #{format_importmap_target_mismatches(target_mismatches)}."
        end

        Check.new(
          key: :importmap,
          label: "Importmap pins",
          status: :missing,
          message: message_parts.join(" ")
        )
      end
    end

    def tom_select_package_check
      path = root.join("package.json")

      unless path.file?
        return Check.new(
          key: :tom_select_package,
          label: "Tom Select package",
          status: :manual,
          message: "package.json was not found. Skip this item for importmap-only apps, or confirm Tom Select through the host app's JavaScript package policy."
        )
      end

      package_json = JSON.parse(path.read)
      dependency_section = tom_select_dependency_section(package_json)

      if dependency_section
        Check.new(
          key: :tom_select_package,
          label: "Tom Select package",
          status: :ok,
          message: "Found tom-select in package.json #{dependency_section}. This is an advisory dependency visibility check only; version policy stays with the host app."
        )
      else
        Check.new(
          key: :tom_select_package,
          label: "Tom Select package",
          status: :manual,
          message: "package.json does not list tom-select in dependencies or devDependencies. Install it with the host app's JavaScript package manager when using Tom Select-backed helpers."
        )
      end
    rescue JSON::ParserError => error
      Check.new(
        key: :tom_select_package,
        label: "Tom Select package",
        status: :manual,
        message: "package.json could not be parsed (#{error.class}). Confirm the Tom Select package manually; setup doctor does not fail or rewrite package files."
      )
    end

    def stimulus_registration_check
      path = stimulus_registration_signal_path

      if path
        Check.new(
          key: :stimulus_registration,
          label: "Stimulus registration",
          status: :ok,
          message: "Found Rails Fields Kit Stimulus registration signal in #{path}. This is an advisory controller visibility check only; Stimulus boot policy stays with the host app."
        )
      else
        Check.new(
          key: :stimulus_registration,
          label: "Stimulus registration",
          status: :manual,
          message: "Rails Fields Kit Stimulus registration signal was not found in representative JavaScript entrypoints. Confirm the host app registers rails-fields-kit--tom-select with TomSelectController on the Stimulus application it already boots; setup doctor does not inspect every boot file or decide Application.start policy."
        )
      end
    end

    def css_import_check
      path = css_import_signal_path

      if path
        Check.new(
          key: :css_import,
          label: "CSS import",
          status: :ok,
          message: "Found Tom Select CSS import signal in #{path}. This is an advisory stylesheet visibility check only; stylesheet pipeline and theme policy stay with the host app."
        )
      else
        Check.new(
          key: :css_import,
          label: "CSS import",
          status: :manual,
          message: "Tom Select CSS import was not found in representative stylesheet or JavaScript entrypoints. Confirm the host app loads tom-select/dist/css/tom-select.css or a deliberate Tom Select theme through its own stylesheet or bundler pipeline; setup doctor does not inspect every asset path or rewrite style config."
        )
      end
    end

    def bundler_alias_check
      paths = existing_bundler_alias_candidate_paths

      if paths.empty?
        return Check.new(
          key: :bundler_alias,
          label: "Bundler alias",
          status: :manual,
          message: "Representative bundler config was not found. Skip this item for importmap-only apps, or confirm the documented Rails Fields Kit import paths through the host app's Vite, jsbundling, or custom resolver policy."
        )
      end

      readable_contents = paths.filter_map do |relative_path|
        path = root.join(relative_path)
        [relative_path, path.read]
      rescue
        nil
      end

      if readable_contents.empty?
        return Check.new(
          key: :bundler_alias,
          label: "Bundler alias",
          status: :manual,
          message: "Representative bundler config exists but could not be read. Confirm the documented Rails Fields Kit import paths manually; setup doctor does not fail or rewrite bundler config."
        )
      end

      found_aliases = BUNDLER_ALIASES.select do |name|
        readable_contents.any? { |_relative_path, content| bundler_alias_signal?(content, name) }
      end
      missing_aliases = BUNDLER_ALIASES - found_aliases

      if missing_aliases.empty?
        signal_paths = readable_contents.map(&:first).join(", ")
        Check.new(
          key: :bundler_alias,
          label: "Bundler alias",
          status: :ok,
          message: "Found Rails Fields Kit bundler alias signals in #{signal_paths}. This is an advisory resolver visibility check only; bundler choice and config policy stay with the host app."
        )
      else
        Check.new(
          key: :bundler_alias,
          label: "Bundler alias",
          status: :manual,
          message: "Representative bundler config did not show alias signals for #{missing_aliases.join(", ")}. Confirm the documented Rails Fields Kit import paths manually; setup doctor does not inspect every resolver shape or rewrite bundler config."
        )
      end
    end

    def stimulus_registration_signal_path
      STIMULUS_REGISTRATION_CANDIDATE_PATHS.find do |candidate_path|
        path = root.join(candidate_path)
        path.file? && stimulus_registration_signal?(path.read)
      end
    end

    def stimulus_registration_signal?(content)
      STIMULUS_REGISTRATION_SIGNALS.any? { |signal| content.include?(signal) }
    end

    def css_import_signal_path
      CSS_IMPORT_CANDIDATE_PATHS.find do |candidate_path|
        path = root.join(candidate_path)
        path.file? && path.read.match?(TOM_SELECT_CSS_IMPORT_PATTERN)
      end
    end

    def existing_bundler_alias_candidate_paths
      BUNDLER_ALIAS_CANDIDATE_PATHS.select do |candidate_path|
        root.join(candidate_path).file?
      end
    end

    def bundler_alias_signal?(content, name)
      if name == "rails_fields_kit"
        content.match?(/(?<![\w\/-])rails_fields_kit(?![\w\/-])/)
      else
        content.match?(/(?<![\w-])#{Regexp.escape(name)}(?![\w-])/)
      end
    end

    def tom_select_dependency_section(package_json)
      %w[dependencies devDependencies].find do |section|
        dependencies = package_json[section]
        dependencies.is_a?(Hash) && dependencies.key?("tom-select")
      end
    end

    def importmap_pin_declared?(content, name)
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

    def format_check(check)
      "[#{check.status.to_s.upcase}] #{check.label}: #{check.message}"
    end

    def format_check_payload(check)
      {
        "key" => check.key.to_s,
        "label" => check.label,
        "status" => check.status.to_s,
        "manual" => check.status == :manual,
        "message" => check.message
      }
    end
  end
end
