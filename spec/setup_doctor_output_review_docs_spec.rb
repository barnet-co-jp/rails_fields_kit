# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "setup doctor output review docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }
  let(:setup_doctor_doc) { File.read(File.expand_path("../doc/setup_doctor.md", __dir__)) }
  let(:output_review_doc) { File.read(File.expand_path("../doc/setup_doctor_output_review.md", __dir__)) }

  it "ships the setup doctor output review route and keeps it discoverable" do
    expect(specification.files).to include(
      "doc/setup_doctor.md",
      "doc/setup_doctor_output_review.md",
      "doc/setup_doctor_output_narrow_wrap_review.md"
    )

    expect(readme).to include(
      "doc/setup_doctor.md",
      "doc/setup_doctor_output_review.md",
      "CLI diagnostic evidence review"
    )
  end

  it "keeps output review evidence focused on release handoff instead of runtime policy" do
    expect(output_review_doc).to include(
      "Release Evidence Handoff",
      "Use this artifact as the review aid for setup doctor evidence",
      "doc/sample_app_checklist.md",
      "doc/sample_app_results.md",
      "PR comment is enough when it names the command",
      "setup path",
      "representative `[OK]` / `[MISSING]` / `[MANUAL]` lines",
      "Keep auto-fix behavior, exit-code policy, and host-app setup policy decisions out of release evidence notes"
    )
  end

  it "keeps status labels readable without turning manual checks into failures" do
    expect(output_review_doc).to include(
      "Status legend: [OK] detected setup; [MISSING] needs action for the detected setup route; [MANUAL] host-app check, not an automatic failure.",
      "`[OK]` means the doctor could read the expected setup signal.",
      "`[MISSING]` means the doctor could not find an expected setup signal for the detected route.",
      "`[MANUAL]` means the doctor cannot safely verify the host app decision automatically; it is not a hard failure by itself.",
      "Manual checklist lines are not described as failed automatic checks."
    )
  end

  it "keeps the setup doctor read-only boundary separate from evidence review" do
    expect(setup_doctor_doc).to include(
      "read-only diagnostic helper",
      "It does not rewrite app files, install JavaScript packages, decide CI policy, or turn setup gaps into command failures.",
      "Text evidence",
      "`report_lines` is not a JSON schema, SARIF/JUnit contract, or stable machine-readable report format"
    )

    expect(output_review_doc).to include(
      "This artifact is not production UI and does not define setup doctor runtime behavior.",
      "Keep command behavior, wording source, host app setup policy, and auto-fix decisions outside this artifact."
    )
  end
end
