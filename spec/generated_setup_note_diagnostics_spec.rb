# frozen_string_literal: true

require "spec_helper"

RSpec.describe "generated setup note diagnostics" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:setup_doc) { File.read(File.join(repo_root, "doc/setup.md")) }
  let(:generated_setup_note) do
    File.read(File.join(repo_root, "lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md"))
  end
  let(:setup_doctor_review) { File.read(File.join(repo_root, "doc/setup_doctor_output_review.md")) }

  it "keeps importmap target drift diagnostics visible without turning them into auto-fix policy" do
    expect(setup_doc).to include(
      "point at the documented entrypoints",
      "Missing pins, unexpected targets, and pins without explicit targets are reported as read-only diagnostics",
      "does not rewrite `config/importmap.rb`",
      "validate bundler aliases",
      "host app's non-importmap policy"
    )

    expect(generated_setup_note).to include(
      "importmap pin target diagnostics",
      "Use the doctor output as a read-only prompt",
      "missing importmap pins",
      "unexpected Rails Fields Kit pin targets",
      "target-omitted pins",
      "bundler aliases for documented Rails Fields Kit entrypoints remain host-app setup responsibilities",
      "The doctor does not inspect or rewrite bundler config"
    )
  end

  it "keeps first-run status guidance visible in maintained and generated setup docs" do
    expect(setup_doc).to include(
      "The output starts with a status legend",
      "fix `[MISSING]` lines first",
      "review `[MANUAL]` lines as host-app JavaScript toolchain checks rather than automatic failures"
    )

    expect(generated_setup_note).to include(
      "Read the setup doctor status legend first",
      "fix `[MISSING]` lines before treating `[MANUAL]` lines as host-app JavaScript toolchain checks"
    )

    expect(setup_doctor_review).to include(
      "Status legend: [OK] detected setup; [MISSING] needs action for the detected setup route; [MANUAL] host-app check, not an automatic failure.",
      "The status legend appears before individual check lines.",
      "The evidence note distinguishes `[MISSING]` action items from `[MANUAL]` host-app checks."
    )
  end
end