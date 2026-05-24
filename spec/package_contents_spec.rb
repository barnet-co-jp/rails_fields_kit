# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "package contents" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }

  it "ships the documented JavaScript package entrypoints" do
    expect(specification.files).to include(
      "package.json",
      "app/javascript/rails_fields_kit/index.js",
      "app/javascript/rails_fields_kit/tom_select_controller.js"
    )
  end

  it "ships the setup docs that describe the public import paths" do
    expect(specification.files).to include(
      "README.md",
      "doc/setup.md",
      "doc/sample_app_checklist.md"
    )
  end
end
