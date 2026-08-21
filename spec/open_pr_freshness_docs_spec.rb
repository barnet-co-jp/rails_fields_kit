# frozen_string_literal: true

require "spec_helper"

RSpec.describe "open PR freshness documentation" do
  let(:development_doc_path) { File.expand_path("../doc/development.md", __dir__) }
  let(:development_doc) { File.read(development_doc_path) }
  let(:freshness_section) { markdown_section(development_doc, "## Open PR freshness checks") }

  it "keeps review queue classifications and CI evidence boundaries visible" do
    expect(freshness_section).to include(
      "latest workflow run state for the PR head commit",
      "when the combined status or status list is empty",
      "head commit's GitHub Actions workflow runs",
      "PR metadata `mergeable` value",
      "behind, diverged, or superseded by a replacement PR",
      "browser-capable desktop or narrow viewport evidence",
      "public helper, package-root export, or additive API PR"
    )

    expect(freshness_section).to include(
      "`review-ready`",
      "head workflow is green",
      "`needs-refresh`",
      "compare shows `behind_by > 0` or `status:diverged`",
      "`needs-browser-evidence`",
      "desktop or narrow viewport proof is missing",
      "`needs-human`",
      "public adoption boundary"
    )

    expect(freshness_section).to include(
      "manual queue hygiene guard",
      "Do not add a GitHub API-dependent CI job",
      "automatic branch refresh",
      "merge decision automation"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
