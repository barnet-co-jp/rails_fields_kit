# frozen_string_literal: true

require "spec_helper"

RSpec.describe "rails_fields_kit.gemspec" do
  subject(:specification) do
    Gem::Specification.load(File.expand_path("../../rails_fields_kit.gemspec", __dir__))
  end

  it "has expected package metadata" do
    expect(specification.name).to eq("rails_fields_kit")
    expect(specification.required_ruby_version).to be_satisfied_by(Gem::Version.new("3.1.0"))
    expect(specification.metadata["allowed_push_host"]).to eq("https://rubygems.org")
    expect(specification.metadata["rubygems_mfa_required"]).to eq("true")
    expect(specification.metadata).not_to have_key("homepage_uri")
    expect(specification.metadata["source_code_uri"]).to eq(specification.homepage)
    expect(specification.metadata["changelog_uri"]).to end_with("/CHANGELOG.md")
    expect(specification.metadata["documentation_uri"]).to end_with("/doc/setup.md")
  end

  it "depends on Rails 7 and 8" do
    rails_dependency = specification.dependencies.find { |dependency| dependency.name == "rails" }

    expect(rails_dependency).not_to be_nil
    expect(rails_dependency.requirement).to eq(Gem::Requirement.new(">= 7.0", "< 9.0"))
  end

  it "packages runtime files and documentation" do
    expect(specification.files).to include(
      "README.md",
      "CHANGELOG.md",
      "LICENSE.txt",
      "lib/rails_fields_kit.rb",
      "app/javascript/rails_fields_kit/tom_select_controller.js",
      "doc/setup.md",
      "doc/public_api.md",
      "doc/field_helpers.md",
      "doc/controller_helpers.md",
      "doc/configuration.md",
      "doc/events.md",
      "doc/development.md",
      "doc/sample_app_checklist.md",
      "doc/release.md"
    )
  end
end
