# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "visual reference browser evidence docs inventory" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:gemspec_path) { File.join(root, "rails_fields_kit.gemspec") }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:runbook_path) { File.join(root, "doc/visual_reference_browser_evidence.md") }
  let(:runbook) { File.read(runbook_path) }
  let(:development) { File.read(File.join(root, "doc/development.md")) }
  let(:freshness_note) { File.read(File.join(root, ".github/pr_freshness_queue_note.md")) }

  it "ships the manual browser evidence runbook with packaged docs" do
    expect(File.file?(runbook_path)).to be(true)
    expect(specification.files).to include("doc/visual_reference_browser_evidence.md")
  end

  it "keeps development and freshness guidance routed to the runbook" do
    expect(development).to include(
      "needs-browser-evidence",
      ".github/pr_freshness_queue_note.md",
      "CI and source review cannot replace"
    )
    expect(freshness_note).to include(
      "needs-browser-evidence",
      "doc/visual_reference_browser_evidence.md",
      "CI success and source review do not replace this"
    )
  end

  it "preserves the manual visual approval boundary signals" do
    expect(runbook).to include(
      "not CI automation, screenshot approval, or a merge bot",
      "CI success and source review are useful context, but they are not browser visual approval",
      "Desktop: about `1280x900`",
      "Narrow: about `390x844`",
      "## PR comment format",
      "Do not mark a visual reference as browser-approved unless the desktop and narrow browser review actually ran"
    )
  end
end
