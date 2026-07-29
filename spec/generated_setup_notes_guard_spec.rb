# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "generated setup notes guard" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:template_path) { File.expand_path("../lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md", __dir__) }
  let(:template) { File.read(template_path) }

  it "ships the generated setup notes template as a host app route map" do
    expect(specification.files).to include("lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md")

    expect(template).to include(
      "lightweight adoption checklist",
      "not become a second setup guide",
      "upstream setup guide as the maintained source of truth"
    )
  end

  it "keeps representative upstream setup links and responsibility boundaries visible" do
    expect(template).to include(
      "README.md#first-field-quickstart",
      "doc/setup.md#rfk-select-setup-lane",
      "doc/setup.md#setup-doctor-status-legend",
      "doc/setup_doctor_output_review.md",
      "doc/setup.md#unresolved-imports",
      "doc/setup.md#turbo-and-stimulus-reconnection",
      "README.md#support-boundary"
    )

    expect(template).to include(
      "Use the doctor output as a read-only prompt",
      "missing importmap pins",
      "bundler aliases for documented Rails Fields Kit entrypoints remain host-app setup responsibilities",
      "does not inspect or rewrite bundler config",
      "final Stimulus boot policy",
      "host-app follow-up"
    )
  end

  it "keeps the generated notes compact instead of mirroring every upstream helper" do
    reference_links = markdown_section(template, "## Reference links")

    expect(reference_links).to include(
      "Keep these links here for later lookup",
      "add app-specific notes above instead of turning this generated file into a full docs inventory",
      "doc/setup.md",
      "README.md"
    )
    expect(reference_links).not_to include("doc/public_api.md#javascript-exports")
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
