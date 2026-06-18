# frozen_string_literal: true

require "spec_helper"

RSpec.describe "setup doctor docs inventory" do
  def read_repo_file(relative_path)
    File.read(File.expand_path("../#{relative_path}", __dir__))
  end

  let(:readme) { read_repo_file("README.md") }
  let(:product_profile) { read_repo_file("Product Profile.md") }
  let(:roadmap) { read_repo_file("ROADMAP.md") }
  let(:release_guide) { read_repo_file("doc/release.md") }

  it "keeps the README setup doctor route discoverable without implying auto-fix behavior" do
    expect(readme).to include(
      "rails rails_fields_kit:doctor",
      "inspect the host app's setup visibility without changing files",
      "read-only/manual-check boundary",
      "doc/setup_doctor.md",
      "doc/setup_doctor_output_review.md",
      "Tom Select package install",
      "final Stimulus boot policy",
      "CSS import",
      "bundler alias confirmation"
    )
  end

  it "keeps root maintainer inventory docs aligned with the read-only setup verification surface" do
    expect(product_profile).to include(
      "read-only setup verification through `rails rails_fields_kit:doctor`",
      "RailsFieldsKit::SetupDoctor",
      "structured JSON representation",
      "Tom Select package install",
      "final Stimulus boot policy",
      "bundler aliases as host-app responsibilities",
      "auto-fixing host app setup or frontend toolchain wiring",
      "doc/setup_doctor.md",
      "doc/setup_doctor_machine_readable.md",
      "doc/setup_doctor_output_review.md"
    )

    expect(roadmap).to include(
      "read-only setup verification through `rails rails_fields_kit:doctor`",
      "initializer and importmap pin visibility",
      "Tom Select package install",
      "Stimulus registration",
      "CSS import",
      "bundler alias confirmation as host-app manual responsibilities"
    )
  end

  it "keeps release evidence pointed at setup doctor as a manual verification lane" do
    expect(release_guide).to include(
      "rails rails_fields_kit:doctor",
      "Record whether it reports the initializer and, when importmap is present, the Rails Fields Kit pins.",
      "Tom Select package install, Stimulus registration, CSS import, and bundler alias output as manual checklist reminders",
      "rather than automatic pass/fail gates or auto-fix behavior",
      "setup_doctor_output_review.md",
      "[OK]",
      "[MISSING]",
      "[MANUAL]"
    )
  end
end
