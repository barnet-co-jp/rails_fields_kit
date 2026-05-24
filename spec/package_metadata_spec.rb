# frozen_string_literal: true

require "json"
require "spec_helper"

RSpec.describe "package metadata" do
  let(:package_json_path) { File.expand_path("../package.json", __dir__) }

  it "exports the documented JavaScript entrypoints" do
    package = JSON.parse(File.read(package_json_path))

    expect(package.fetch("name")).to eq("rails_fields_kit")
    expect(package.fetch("type")).to eq("module")
    expect(package.fetch("exports")).to eq(
      "." => "./app/javascript/rails_fields_kit/index.js",
      "./tom_select_controller" => "./app/javascript/rails_fields_kit/tom_select_controller.js"
    )
  end
end
