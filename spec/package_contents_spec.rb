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

  it "ships the install-flow docs and generator artifacts described by README and setup" do
    expect(specification.files).to include(
      "README.md",
      "doc/setup.md",
      "doc/sample_app_checklist.md",
      "lib/generators/rails_fields_kit/install_generator.rb",
      "lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md"
    )
  end

  it "ships the maintained public reference docs linked from README and setup" do
    expect(specification.files).to include(
      "doc/public_api.md",
      "doc/select_migration.md",
      "doc/field_helpers.md",
      "doc/controller_helpers.md",
      "doc/configuration.md",
      "doc/events.md",
      "doc/token_suggestions.md",
      "doc/ransack_suggestions.md",
      "doc/table_adapters.md"
    )
  end

  it "ships the release-facing verification docs linked from README" do
    expect(specification.files).to include(
      "doc/development.md",
      "doc/sample_app_results.md",
      "doc/final_release_checklist.md",
      "doc/release_notes_0_1_0.md"
    )
  end
end
