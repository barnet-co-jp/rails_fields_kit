# frozen_string_literal: true

require "spec_helper"

RSpec.describe "setup doctor output review evidence" do
  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end

  let(:output_review_path) { File.expand_path("../doc/setup_doctor_output_review.md", __dir__) }
  let(:output_review) { File.read(output_review_path) }
  let(:sample_app_results_path) { File.expand_path("../doc/sample_app_results.md", __dir__) }
  let(:sample_app_results) { File.read(sample_app_results_path) }
  let(:release_handoff) { markdown_section(output_review, "## Release Evidence Handoff") }
  let(:narrow_matrix) { markdown_section(output_review, "## Representative Narrow Review States") }
  let(:sample_setup_doctor_section) { markdown_section(sample_app_results, "## Setup doctor checks") }

  it "keeps setup doctor review evidence pointed at the release results lane" do
    expect(release_handoff).to include(
      "Record release-wide results in `doc/sample_app_results.md` under `Setup doctor checks`",
      "including the app setup path: importmap, jsbundling, bundler-managed JavaScript, or another route",
      "Treat `[MANUAL]` lines as host-app responsibility checks",
      "Do not count them as failed automatic checks",
      "Keep auto-fix behavior, exit-code policy, and host-app setup policy decisions out of release evidence notes"
    )

    expect(sample_setup_doctor_section).to include(
      "Use `doc/setup_doctor_output_review.md` when the release or PR needs evidence",
      "setup doctor output readability was checked with `doc/setup_doctor_output_review.md`",
      "evidence notes distinguish setup behavior from CLI output readability evidence",
      "manual checklist items for Tom Select package install, Stimulus registration, CSS import, and bundler aliases were reviewed as host-app responsibilities"
    )
  end

  it "keeps the narrow evidence note matrix aligned with checklist responsibilities" do
    expect(narrow_matrix).to include(
      "First-run mixed status",
      "Advisory Tom Select package",
      "Stimulus registration advisory",
      "CSS import advisory",
      "Importmap target mismatch",
      "Status Interpretation",
      "Advisory Ownership",
      "Wrapping Evidence",
      "Legend position",
      "setup path",
      "host-app stylesheet / bundler boundary"
    )

    expect(sample_setup_doctor_section).to include(
      "initializer visibility was recorded",
      "importmap pin visibility was recorded",
      "representative Stimulus registration evidence was recorded",
      "`[OK] Stimulus registration` was not treated as proof of the host app's final Stimulus boot policy",
      "manual checklist items"
    )
  end

  it "keeps CLI output readability separate from runtime setup doctor behavior" do
    expect(output_review).to include(
      "This artifact is not production UI and does not define setup doctor runtime behavior",
      "They are review scenarios, not new setup doctor output variants",
      "Do not create a new runtime output mode just to satisfy this review",
      "Do not change setup doctor runtime behavior or output wording here",
      "Do not introduce a terminal UI framework"
    )

    expect(sample_setup_doctor_section).to include(
      "without changing files",
      "recorded without treating bundler apps as failures",
      "instead of treating this section as a source of new doctor behavior or output wording"
    )
  end
end
