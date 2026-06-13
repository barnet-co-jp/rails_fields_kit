# frozen_string_literal: true

require "spec_helper"

RSpec.describe "visual reference evidence handoff docs" do
  def read_repo_file(path)
    File.read(File.expand_path("../../#{path}", __dir__))
  end

  let(:visual_references) { read_repo_file("doc/visual_references.md") }
  let(:sample_app_results) { read_repo_file("doc/sample_app_results.md") }

  it "keeps the PR-level visual evidence handoff template explicit" do
    expect(visual_references).to include(
      "Visual reference evidence handoff",
      "Checked in this PR: source review / static render / CI / docs link review ...",
      "Not checked here: browser screenshot / real browser desktop / real browser narrow ...",
      "Remaining browser-capable check: ...",
      "Responsibility boundary: runtime behavior / production CSS / host-app copy remains out of scope",
      "Do not paste it as a release approval when the browser pass was not actually run"
    )
  end

  it "keeps sample-app release evidence separate from narrow PR comments" do
    expect(sample_app_results).to include(
      "A narrow PR can cite the relevant lane in a PR comment instead of filling every section here.",
      "Visual reference review",
      "Static HTML visual references or the one-screen visual reference index changed.",
      "Runtime helper behavior, production CSS approval, sample-app field behavior, or CI success as visual approval.",
      "the matrix records what was rendered, not new helper behavior",
      "review notes call out any intentionally deferred visual follow-up instead of treating CI green as visual approval"
    )
  end
end
