# frozen_string_literal: true

require "spec_helper"

RSpec.describe "PR freshness queue note" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:queue_note) { File.read(File.join(root, ".github/pr_freshness_queue_note.md")) }
  let(:development_doc) { File.read(File.join(root, "doc/development.md")) }

  it "keeps reviewer-facing freshness signals aligned with development guidance" do
    shared_signals = [
      "head",
      "workflow run",
      "combined status",
      "compare",
      "mergeability",
      "changed files"
    ]

    shared_signals.each do |signal|
      expect(queue_note).to include(signal)
      expect(development_doc).to include(signal)
    end

    expect(queue_note).to include(
      "remaining gate",
      "next reviewer action"
    )
    expect(development_doc).to include(
      "remaining decision owner",
      "When those signals disagree"
    )
  end

  it "keeps classification vocabulary aligned without automating review decisions" do
    classifications = %w[
      review-ready
      needs-refresh
      needs-browser-evidence
      needs-human
    ]

    classifications.each do |classification|
      expect(queue_note).to include(classification)
      expect(development_doc).to include(classification)
    end

    expect(queue_note).to include(
      "Do not use this template as a merge decision",
      "branch-refresh automation",
      "visual approval substitute"
    )
    expect(development_doc).to include(
      "manual queue hygiene guard",
      "Do not add a GitHub API-dependent CI job",
      "merge decision automation"
    )
  end

  it "keeps CI fallback and browser-evidence boundaries explicit" do
    expect(queue_note).to include(
      "if empty, workflow runs were checked separately",
      "browser-capable desktop/narrow viewport evidence",
      "CI success and source review do not replace this"
    )
    expect(development_doc).to include(
      "combined status or status list is empty",
      "check the head commit's GitHub Actions workflow runs",
      "static visual reference PR",
      "browser-capable desktop or narrow viewport evidence",
      "CI and source review cannot replace"
    )
  end
end
