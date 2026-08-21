# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "stringio"
require "tmpdir"

RSpec.describe RailsFieldsKit::SetupDoctor do
  def write_file(root, path, content = "")
    absolute_path = File.join(root, path)
    FileUtils.mkdir_p(File.dirname(absolute_path))
    File.write(absolute_path, content)
  end

  def check_for(doctor, key)
    doctor.checks.find { |check| check.key == key }
  end

  it "reports whether the initializer is present" do
    Dir.mktmpdir do |root|
      expect(check_for(described_class.new(root: root), :initializer).status).to eq(:missing)

      write_file(root, "config/initializers/rails_fields_kit.rb")

      initializer_check = check_for(described_class.new(root: root), :initializer)
      expect(initializer_check.status).to eq(:ok)
      expect(initializer_check.message).to include("config/initializers/rails_fields_kit.rb")
    end
  end

  it "reports generated setup note presence without treating skipped notes as missing" do
    Dir.mktmpdir do |root|
      setup_note_check = check_for(described_class.new(root: root), :generated_setup_note)

      expect(setup_note_check.status).to eq(:manual)
      expect(setup_note_check.message).to include("doc/rails_fields_kit_setup.md was not found")
      expect(setup_note_check.message).to include("--skip-setup-notes")
      expect(setup_note_check.message).to include("does not create the note")

      write_file(root, "doc/rails_fields_kit_setup.md", "# App setup notes\n")

      setup_note_check = check_for(described_class.new(root: root), :generated_setup_note)
      expect(setup_note_check.status).to eq(:ok)
      expect(setup_note_check.message).to include("Found doc/rails_fields_kit_setup.md")
    end
  end

  it "includes generated setup note state in text and JSON output" do
    Dir.mktmpdir do |root|
      write_file(root, "config/initializers/rails_fields_kit.rb")
      doctor = described_class.new(root: root)
      text_output = StringIO.new
      json_output = StringIO.new

      expect(doctor.run(io: text_output)).to eq(true)
      expect(text_output.string).to include("[MANUAL] Generated setup note")
      expect(text_output.string).to include("--skip-setup-notes")

      expect(doctor.run(io: json_output, format: :json)).to eq(true)
      payload = JSON.parse(json_output.string)
      setup_note = payload.fetch("checks").find { |check| check.fetch("key") == "generated_setup_note" }

      expect(payload.fetch("summary")).to include("manual" => 6)
      expect(setup_note).to include(
        "label" => "Generated setup note",
        "status" => "manual",
        "manual" => true
      )
    end
  end

  it "keeps importmap as a manual item when config/importmap.rb is absent" do
    Dir.mktmpdir do |root|
      importmap_check = check_for(described_class.new(root: root), :importmap)

      expect(importmap_check.status).to eq(:manual)
      expect(importmap_check.message).to include("config/importmap.rb was not found")
    end
  end

  it "reports complete importmap pins when config/importmap.rb exists" do
    Dir.mktmpdir do |root|
      write_file(root, "config/importmap.rb", <<~RUBY)
        pin "rails_fields_kit", to: "rails_fields_kit/index.js"
        pin "rails_fields_kit/native_field_accessibility_contract", to: "rails_fields_kit/native_field_accessibility_contract.js"
        pin "rails_fields_kit/native_field_constraint_contract", to: "rails_fields_kit/native_field_constraint_contract.js"
        pin "rails_fields_kit/read_rendered_error_surface", to: "rails_fields_kit/read_rendered_error_surface.js"
        pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"
        pin "rails_fields_kit/tom_select_plugin_contract", to: "rails_fields_kit/tom_select_plugin_contract.js"
        pin "rails_fields_kit/tom_select_text_override_contract", to: "rails_fields_kit/tom_select_text_override_contract.js"
      RUBY

      importmap_check = check_for(described_class.new(root: root), :importmap)

      expect(importmap_check.status).to eq(:ok)
      expect(importmap_check.message).to include("Rails Fields Kit importmap pins are present")
    end
  end

  it "reports importmap pins with unexpected targets" do
    Dir.mktmpdir do |root|
      write_file(root, "config/importmap.rb", <<~RUBY)
        pin "rails_fields_kit", to: "rails_fields_kit.js"
        pin "rails_fields_kit/tom_select_controller"
      RUBY

      importmap_check = check_for(described_class.new(root: root), :importmap)

      expect(importmap_check.status).to eq(:missing)
      expect(importmap_check.message).to include("unexpected targets")
      expect(importmap_check.message).to include("rails_fields_kit (expected rails_fields_kit/index.js, found rails_fields_kit.js)")
      expect(importmap_check.message).to include("rails_fields_kit/tom_select_controller (expected rails_fields_kit/tom_select_controller.js, found no explicit target)")
    end
  end

  it "prints a status legend before individual setup checks" do
    Dir.mktmpdir do |root|
      output = StringIO.new

      described_class.new(root: root).run(io: output)

      expect(output.string).to include("Status legend: [OK] detected setup; [MISSING] needs action for the detected setup route; [MANUAL] host-app check, not an automatic failure.")
      expect(output.string).to include("Next step: fix [MISSING] lines first, then review [MANUAL] lines for this app's JavaScript toolchain.")
      expect(output.string).to match(/Next step:.*\n\n\[MISSING\] Initializer/m)
    end
  end

  it "keeps checks, report_lines, and run as a read-only diagnostic surface" do
    Dir.mktmpdir do |root|
      doctor = described_class.new(root: root)
      output = StringIO.new

      checks = doctor.checks
      expect(checks).to all(be_a(described_class::Check))
      expect(checks.map(&:key)).to include(:initializer, :generated_setup_note, :importmap, :tom_select_package, :css_import)
      expect(checks.map(&:status)).to include(:missing, :manual)
      checks.each do |check|
        expect(check.key).to be_a(Symbol)
        expect(check.label).to be_a(String)
        expect(check.status).to be_a(Symbol)
        expect(check.message).to be_a(String)
      end

      report_lines = doctor.report_lines
      expect(report_lines).to all(be_a(String))
      expect(report_lines).to include("Rails Fields Kit setup doctor")
      expect(report_lines).to include(a_string_matching(/\[MISSING\] Initializer:/))
      expect(report_lines).to include(a_string_matching(/\[MANUAL\] Generated setup note:/))
      expect(report_lines).to include(a_string_matching(/\[MANUAL\] Importmap pins:/))

      expect(doctor.run(io: output)).to eq(true)
      expect(output.string).to eq(report_lines.join("\n") + "\n")
    end
  end

  it "prints machine-readable JSON without turning manual checks into failures" do
    Dir.mktmpdir do |root|
      write_file(root, "config/initializers/rails_fields_kit.rb")
      output = StringIO.new

      expect(described_class.new(root: root).run(io: output, format: :json)).to eq(true)
      payload = JSON.parse(output.string)

      expect(payload).to include(
        "schema_version" => 1,
        "tool" => "rails_fields_kit:doctor"
      )
      expect(payload.fetch("summary")).to eq(
        "ok" => 1,
        "missing" => 0,
        "manual" => 6
      )

      initializer = payload.fetch("checks").find { |check| check.fetch("key") == "initializer" }
      importmap = payload.fetch("checks").find { |check| check.fetch("key") == "importmap" }
      setup_note = payload.fetch("checks").find { |check| check.fetch("key") == "generated_setup_note" }

      expect(initializer).to include(
        "label" => "Initializer",
        "status" => "ok",
        "manual" => false,
        "message" => "Found config/initializers/rails_fields_kit.rb."
      )
      expect(setup_note).to include(
        "label" => "Generated setup note",
        "status" => "manual",
        "manual" => true
      )
      expect(importmap).to include(
        "label" => "Importmap pins",
        "status" => "manual",
        "manual" => true
      )
      expect(output.string).not_to include("[OK] Initializer")
    end
  end

  it "rejects unsupported setup doctor output formats" do
    Dir.mktmpdir do |root|
      expect {
        described_class.new(root: root).run(io: StringIO.new, format: :xml)
      }.to raise_error(ArgumentError, /Unsupported setup doctor format/)
    end
  end

  it "keeps Tom Select package visibility manual when package.json is absent" do
    Dir.mktmpdir do |root|
      package_check = check_for(described_class.new(root: root), :tom_select_package)

      expect(package_check.status).to eq(:manual)
      expect(package_check.message).to include("package.json was not found")
      expect(package_check.message).to include("host app's JavaScript package policy")
    end
  end

  it "reports Tom Select when package.json dependencies include tom-select" do
    Dir.mktmpdir do |root|
      write_file(root, "package.json", <<~JSON)
        {
          "dependencies": {
            "tom-select": "^2.4.0"
          }
        }
      JSON

      package_check = check_for(described_class.new(root: root), :tom_select_package)

      expect(package_check.status).to eq(:ok)
      expect(package_check.message).to include("Found tom-select in package.json dependencies")
      expect(package_check.message).to include("version policy stays with the host app")
    end
  end

  it "reports Tom Select when package.json devDependencies include tom-select" do
    Dir.mktmpdir do |root|
      write_file(root, "package.json", <<~JSON)
        {
          "devDependencies": {
            "tom-select": "^2.4.0"
          }
        }
      JSON

      package_check = check_for(described_class.new(root: root), :tom_select_package)

      expect(package_check.status).to eq(:ok)
      expect(package_check.message).to include("Found tom-select in package.json devDependencies")
    end
  end

  it "keeps missing Tom Select package as a manual advisory" do
    Dir.mktmpdir do |root|
      write_file(root, "package.json", <<~JSON)
        {
          "dependencies": {
            "@hotwired/stimulus": "^3.2.0"
          }
        }
      JSON

      package_check = check_for(described_class.new(root: root), :tom_select_package)

      expect(package_check.status).to eq(:manual)
      expect(package_check.message).to include("does not list tom-select")
      expect(package_check.message).to include("host app's JavaScript package manager")
    end
  end

  it "does not fail when package.json cannot be parsed" do
    Dir.mktmpdir do |root|
      write_file(root, "package.json", "{ invalid json")
      doctor = described_class.new(root: root)
      output = StringIO.new
      package_check = check_for(doctor, :tom_select_package)

      expect(package_check.status).to eq(:manual)
      expect(package_check.message).to include("package.json could not be parsed")
      expect(package_check.message).to include("does not fail or rewrite package files")
      expect(doctor.run(io: output)).to eq(true)
      expect(output.string).to include("[MANUAL] Tom Select package")
    end
  end

  it "reports Stimulus registration from a representative JavaScript entrypoint" do
    Dir.mktmpdir do |root|
      write_file(root, "app/javascript/controllers/index.js", <<~JS)
        import { application } from "controllers/application"
        import { TomSelectController } from "rails_fields_kit"

        application.register("rails-fields-kit--tom-select", TomSelectController)
      JS

      stimulus_check = check_for(described_class.new(root: root), :stimulus_registration)

      expect(stimulus_check.status).to eq(:ok)
      expect(stimulus_check.message).to include("Found Rails Fields Kit Stimulus registration signal in app/javascript/controllers/index.js")
      expect(stimulus_check.message).to include("Stimulus boot policy stays with the host app")
    end
  end

  it "keeps missing Stimulus registration signal as a manual advisory" do
    Dir.mktmpdir do |root|
      doctor = described_class.new(root: root)
      output = StringIO.new
      stimulus_check = check_for(doctor, :stimulus_registration)

      expect(stimulus_check.status).to eq(:manual)
      expect(stimulus_check.message).to include("representative JavaScript entrypoints")
      expect(stimulus_check.message).to include("does not inspect every boot file")
      expect(doctor.run(io: output)).to eq(true)
      expect(output.string).to include("[MANUAL] Stimulus registration")
    end
  end

  it "keeps missing Tom Select CSS import as a manual advisory" do
    Dir.mktmpdir do |root|
      css_check = check_for(described_class.new(root: root), :css_import)

      expect(css_check.status).to eq(:manual)
      expect(css_check.label).to eq("CSS import")
      expect(css_check.message).to include("Tom Select CSS import was not found")
      expect(css_check.message).to include("does not inspect every asset path or rewrite style config")
    end
  end

  it "reports Tom Select CSS import from a representative JavaScript entrypoint" do
    Dir.mktmpdir do |root|
      write_file(root, "app/javascript/application.js", <<~JS)
        import "tom-select/dist/css/tom-select.css"
      JS

      css_check = check_for(described_class.new(root: root), :css_import)

      expect(css_check.status).to eq(:ok)
      expect(css_check.message).to include("Found Tom Select CSS import signal in app/javascript/application.js")
      expect(css_check.message).to include("stylesheet pipeline and theme policy stay with the host app")
    end
  end

  it "reports Tom Select theme CSS import from a representative stylesheet" do
    Dir.mktmpdir do |root|
      write_file(root, "app/assets/stylesheets/application.css", <<~CSS)
        @import "tom-select/dist/css/tom-select.bootstrap5.css";
      CSS

      css_check = check_for(described_class.new(root: root), :css_import)

      expect(css_check.status).to eq(:ok)
      expect(css_check.message).to include("Found Tom Select CSS import signal in app/assets/stylesheets/application.css")
    end
  end

  it "keeps bundler alias manual when representative config is absent" do
    Dir.mktmpdir do |root|
      bundler_check = check_for(described_class.new(root: root), :bundler_alias)

      expect(bundler_check.status).to eq(:manual)
      expect(bundler_check.message).to include("Representative bundler config was not found")
      expect(bundler_check.message).to include("host app's Vite, jsbundling, or custom resolver policy")
    end
  end

  it "reports bundler alias signals from representative Vite config" do
    Dir.mktmpdir do |root|
      write_file(root, "vite.config.ts", <<~TS)
        import { defineConfig } from "vite"

        export default defineConfig({
          resolve: {
            alias: [
              { find: /^rails_fields_kit$/, replacement: "/bundle/rails_fields_kit/index.js" },
              { find: /^rails_fields_kit\/native_field_accessibility_contract$/, replacement: "/bundle/rails_fields_kit/native_field_accessibility_contract.js" },
              { find: /^rails_fields_kit\/native_field_constraint_contract$/, replacement: "/bundle/rails_fields_kit/native_field_constraint_contract.js" },
              { find: /^rails_fields_kit\/read_rendered_error_surface$/, replacement: "/bundle/rails_fields_kit/read_rendered_error_surface.js" },
              { find: /^rails_fields_kit\/tom_select_controller$/, replacement: "/bundle/rails_fields_kit/tom_select_controller.js" },
              { find: /^rails_fields_kit\/tom_select_plugin_contract$/, replacement: "/bundle/rails_fields_kit/tom_select_plugin_contract.js" },
              { find: /^rails_fields_kit\/tom_select_text_override_contract$/, replacement: "/bundle/rails_fields_kit/tom_select_text_override_contract.js" },
            ],
          },
        })
      TS

      bundler_check = check_for(described_class.new(root: root), :bundler_alias)

      expect(bundler_check.status).to eq(:ok)
      expect(bundler_check.message).to include("Found Rails Fields Kit bundler alias signals in vite.config.ts")
      expect(bundler_check.message).to include("bundler choice and config policy stay with the host app")
    end
  end

  it "keeps bundler alias config without direct helper subpaths as manual advisory" do
    Dir.mktmpdir do |root|
      write_file(root, "vite.config.ts", <<~TS)
        export default {
          resolve: {
            alias: [
              { find: /^rails_fields_kit$/, replacement: "/bundle/rails_fields_kit/index.js" },
              { find: /^rails_fields_kit\/tom_select_controller$/, replacement: "/bundle/rails_fields_kit/tom_select_controller.js" },
            ],
          },
        }
      TS

      bundler_check = check_for(described_class.new(root: root), :bundler_alias)

      expect(bundler_check.status).to eq(:manual)
      expect(bundler_check.message).to include("did not show alias signals for rails_fields_kit/native_field_accessibility_contract")
      expect(bundler_check.message).to include("rails_fields_kit/native_field_constraint_contract")
      expect(bundler_check.message).to include("rails_fields_kit/read_rendered_error_surface")
      expect(bundler_check.message).to include("rails_fields_kit/tom_select_plugin_contract")
      expect(bundler_check.message).to include("rails_fields_kit/tom_select_text_override_contract")
      expect(bundler_check.message).not_to include("rails_fields_kit/tom_select_controller.")
      expect(bundler_check.message).to include("does not inspect every resolver shape or rewrite bundler config")
    end
  end

  it "keeps incomplete bundler alias config as manual advisory" do
    Dir.mktmpdir do |root|
      write_file(root, "vite.config.ts", <<~TS)
        export default {
          resolve: {
            alias: [
              { find: /^rails_fields_kit\/tom_select_controller$/, replacement: "/bundle/rails_fields_kit/tom_select_controller.js" },
            ],
          },
        }
      TS

      bundler_check = check_for(described_class.new(root: root), :bundler_alias)

      expect(bundler_check.status).to eq(:manual)
      expect(bundler_check.message).to include("did not show alias signals for rails_fields_kit")
      expect(bundler_check.message).to include("rails_fields_kit/native_field_accessibility_contract")
      expect(bundler_check.message).to include("rails_fields_kit/native_field_constraint_contract")
      expect(bundler_check.message).to include("rails_fields_kit/read_rendered_error_surface")
      expect(bundler_check.message).to include("rails_fields_kit/tom_select_plugin_contract")
      expect(bundler_check.message).to include("does not inspect every resolver shape or rewrite bundler config")
    end
  end

  it "reports missing importmap pins without treating toolchain variance as an invocation failure" do
    Dir.mktmpdir do |root|
      write_file(root, "config/importmap.rb", <<~RUBY)
        pin "rails_fields_kit", to: "rails_fields_kit/index.js"
      RUBY

      doctor = described_class.new(root: root)
      importmap_check = check_for(doctor, :importmap)
      output = StringIO.new

      expect(importmap_check.status).to eq(:missing)
      expect(importmap_check.message).to include("rails_fields_kit/read_rendered_error_surface")
      expect(importmap_check.message).to include("rails_fields_kit/tom_select_controller")
      expect(importmap_check.message).to include("rails_fields_kit/tom_select_plugin_contract")
      expect(doctor.run(io: output)).to eq(true)
      expect(output.string).to include("[MISSING] Importmap pins")
      expect(output.string).to include("[MANUAL] Generated setup note")
      expect(output.string).to include("[MANUAL] Tom Select package")
      expect(output.string).to include("[MANUAL] Stimulus registration")
      expect(output.string).to include("[MANUAL] CSS import")
      expect(output.string).to include("[MANUAL] Bundler alias")
      expect(output.string).to include("documented Rails Fields Kit import paths")
      expect(output.string).to include("host app's Vite, jsbundling, or custom resolver policy")
      expect(output.string).to include("does not inspect every boot file")
    end
  end
end
