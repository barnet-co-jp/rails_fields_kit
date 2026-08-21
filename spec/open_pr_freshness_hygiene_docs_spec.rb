# frozen_string_literal: true

require "spec_helper"

RSpec.describe "open PR freshness hygiene docs" do
  def markdown_section(markdown, heading)
    start_index = markdown.index(heading)
    raise "Missing heading: #{heading}" unless start_index

    rest = markdown[start_index..]
    next_heading_index = rest.index(/^## (?!#)/, heading.length)
    next_heading_index ? rest[0...next_heading_index] : rest
  end

  let(:development_path) { File.expand_path("../doc/development.md", __dir__) }
  let(:development) { File.read(development_path) }
  let(:freshness_section) { markdown_section(development, "## Open PR freshness checks") }

  it "keeps workflow run and mergeability checks separate for open PR triage" do
    expect(freshness_section).to include(
      "latest workflow run state for the PR head commit",
      "combined status or status list is empty",
      "check the head commit's GitHub Actions workflow runs",
      "PR metadata `mergeable` value",
      "behind, diverged, or superseded by a replacement PR",
      "base branch freshness"
    )
  end

  it "keeps replacement and duplicate-closing PR handling human-reviewed" do
    expect(freshness_section).to include(
      "When a replacement PR supersedes an older PR",
      "link the replacement",
      "older PR cannot be closed safely because the replacement changes scope, risk, or public API surface",
      "When multiple open PRs close the same issue",
      "do not treat that as an automatic merge or close signal",
      "keep the duplicate closing PRs visible for human review"
    )
  end

  it "keeps queue hygiene manual instead of introducing GitHub automation" do
    expect(freshness_section).to include(
      "Keep this as a manual queue hygiene guard",
      "Do not add a GitHub API-dependent CI job",
      "automatic branch refresh",
      "force push",
      "stale PR cleanup",
      "merge decision automation"
    )
  end
end
