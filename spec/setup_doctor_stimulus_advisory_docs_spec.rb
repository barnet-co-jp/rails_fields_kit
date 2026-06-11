# frozen_string_literal: true

require "spec_helper"

RSpec.describe "setup doctor Stimulus advisory docs" do
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }
  let(:product_profile) { File.read(File.expand_path("../Product Profile.md", __dir__)) }
  let(:sample_app_results) { File.read(File.expand_path("../doc/sample_app_results.md", __dir__)) }
  let(:generated_setup_note) do
    File.read(
      File.expand_path("../lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md", __dir__)
    )
  end

  it "keeps the read-only doctor boundary visible from the public setup docs" do
    expect(readme).to include(
      "rails rails_fields_kit:doctor",
      "Stimulus registration",
      "manual host-app checks",
      "doc/setup.md"
    )

    expect(product_profile).to include(
      "representative Stimulus registration advisory signal",
      "final Stimulus boot policy",
      "CSS import",
      "bundler aliases as host-app responsibilities"
    )
  end

  it "keeps generated setup and release evidence docs aligned with the advisory boundary" do
    expect(generated_setup_note).to include(
      "representative Stimulus registration advisory state",
      "Treat `[OK] Stimulus registration` as a representative source signal only",
      "[MANUAL] Stimulus registration",
      "host-app follow-up, not an automatic failure"
    )

    expect(sample_app_results).to include(
      "setup doctor output readability was checked with `doc/setup_doctor_output_review.md`",
      "manual checklist items for Tom Select package install, Stimulus registration, CSS import, and bundler aliases",
      "host-app responsibilities rather than automatic pass/fail gates"
    )
  end
end
