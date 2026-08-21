# frozen_string_literal: true

require "json"
require "spec_helper"
require "rails_fields_kit/setup_doctor"

RSpec.describe "importmap package exports" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:package_json) { JSON.parse(File.read(File.join(repo_root, "package.json"))) }
  let(:package_name) { package_json.fetch("name") }
  let(:package_exports) { package_json.fetch("exports") }
  let(:importmap_pins) { RailsFieldsKit::SetupDoctor::IMPORTMAP_PINS }

  def importmap_name_for_export(export_name)
    return package_name if export_name == "."

    "#{package_name}/#{export_name.delete_prefix("./")}"
  end

  def importmap_target_for_export(export_target)
    javascript_target = export_target.is_a?(Hash) ? export_target.fetch("default", export_target.fetch("import")) : export_target

    javascript_target.delete_prefix("./app/javascript/")
  end

  it "keeps importmap pins aligned with their package exports" do
    expected_pins = package_exports.select { |export_name, _export_target| importmap_pins.key?(importmap_name_for_export(export_name)) }
      .transform_keys { |export_name| importmap_name_for_export(export_name) }
      .transform_values { |export_target| importmap_target_for_export(export_target) }

    expect(importmap_pins).to eq(expected_pins)
  end

  it "keeps the direct Tom Select controller entrypoint explicit" do
    expect(importmap_pins).to include(
      "rails_fields_kit" => "rails_fields_kit/index.js",
      "rails_fields_kit/tom_select_controller" => "rails_fields_kit/tom_select_controller.js"
    )
  end
end
