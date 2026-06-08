# frozen_string_literal: true

require "spec_helper"

RSpec.describe "docs evidence guard" do
  let(:root) { File.expand_path("../..", __dir__) }
  let(:setup_doctor_review) { File.read(File.join(root, "doc/setup_doctor_output_review.md")) }
  let(:sample_app_results) { File.read(File.join(root, "doc/sample_app_results.md")) }
  let(:helper_release_evidence) { File.read(File.join(root, "doc/package_root_helper_release_evidence.md")) }
  let(:public_api) { File.read(File.join(root, "doc/public_api.md")) }

  it "keeps setup doctor output review examples aligned with current report line wording" do
    expect(setup_doctor_review).to include(
      "`RailsFieldsKit::SetupDoctor#report_lines` formats each check as `[STATUS] Label: message`.",
      "[OK] Initializer: Found config/initializers/rails_fields_kit.rb.",
      "[OK] Importmap pins: Rails Fields Kit importmap pins are present in config/importmap.rb.",
      "[MISSING] Importmap pins: Missing Rails Fields Kit importmap pins: rails_fields_kit/tom_select_controller.",
      "rails_fields_kit (expected rails_fields_kit/index.js, found rails_fields_kit)",
      "rails_fields_kit/tom_select_controller (expected rails_fields_kit/tom_select_controller.js, found no explicit target)",
      "[MANUAL] Tom Select package: Install Tom Select with the JavaScript package manager already used by this app.",
      "[MANUAL] Stimulus registration: Register rails-fields-kit--tom-select on the Stimulus application this app already boots.",
      "[MANUAL] CSS import: Load tom-select/dist/css/tom-select.css from the app stylesheet or bundler entrypoint.",
      "[MANUAL] Bundler alias: If this app uses Vite or another bundler"
    )

    expect(setup_doctor_review).not_to include(
      "[OK] initializer found at",
      "[MISSING] importmap pin rails_fields_kit expected target"
    )
  end

  it "keeps sample app package-root helper evidence pointed at public exports" do
    javascript_exports = markdown_section(public_api, "## JavaScript exports")
    javascript_setup_checks = markdown_section(sample_app_results, "## JavaScript setup checks")

    expect(javascript_exports).to include(
      "### Current package-root exports",
      "`TomSelectController`",
      "`tomSelectTextOverrideContract(element)`",
      "`readRenderedSelectedPreloadConfig(element)`",
      "`nativeFieldAccessibilityContract(element)`"
    )

    expect(javascript_setup_checks).to include(
      "package-root helper lanes in release scope were selected from `doc/package_root_helper_release_evidence.md` and matched the current `doc/public_api.md#javascript-exports` helper list",
      "Package-root helper lanes checked:"
    )

    expect(helper_release_evidence).to include(
      "Use `doc/public_api.md#javascript-exports` as the source of truth for the current package-root helper list",
      "For each release or narrow PR, choose only the package-root helper lanes that are in scope for that change.",
      "For other current helpers listed in `doc/public_api.md#javascript-exports`, record the same minimal evidence shape:",
      "Do not add helper-specific sections for open PR helpers, proposal names, or roadmap-only helpers."
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
