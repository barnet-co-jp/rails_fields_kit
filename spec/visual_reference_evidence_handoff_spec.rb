# frozen_string_literal: true

require "spec_helper"

RSpec.describe "visual reference evidence handoff docs" do
  let(:visual_references_path) { File.expand_path("../doc/visual_references.md", __dir__) }
  let(:visual_references) { File.read(visual_references_path) }
  let(:sample_app_results_path) { File.expand_path("../doc/sample_app_results.md", __dir__) }
  let(:sample_app_results) { File.read(sample_app_results_path) }

  it "keeps the PR handoff template concrete without treating CI as visual approval" do
    template_section = visual_references.split("Visual reference evidence handoff", 2).last

    expect(template_section).to include(
      "- Artifact: `doc/...html`",
      "- Viewports: desktop ..., narrow ...",
      "- Lane/state: ...",
      "- Checked in this PR: source review / static render / CI / docs link review ...",
      "- Not checked here: browser screenshot / real browser desktop / real browser narrow ...",
      "- Remaining browser-capable check: ...",
      "- Responsibility boundary: runtime behavior / production CSS / host-app copy remains out of scope",
      "- Result or blocker: ...",
      "Do not paste it as a release approval when the browser pass was not actually run."
    )
  end

  it "keeps release evidence recording separate from PR-level browser-review handoff" do
    visual_route_map = sample_app_results.split("\n## Target release\n", 2).first
    render_checks = sample_app_results.split("## Visual reference render checks", 2).last

    expect(visual_route_map).to include(
      "Visual reference review",
      "Static HTML visual references or the one-screen visual reference index changed.",
      "Runtime helper behavior, production CSS approval, sample-app field behavior, or CI success as visual approval."
    )

    expect(render_checks).to include(
      "PASS only when the named viewport was actually reviewed in a browser",
      "SOURCE REVIEW ONLY when connector-only or source-level review checked the changed HTML/CSS without rendering it",
      "DEFERRED when browser-capable review is intentionally handed off",
      "Do not treat CI success or source review alone as visual approval."
    )
  end
end
