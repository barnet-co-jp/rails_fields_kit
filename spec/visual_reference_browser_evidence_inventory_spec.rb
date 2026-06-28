# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "visual reference browser evidence inventory" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:development_doc) { read_doc("doc/development.md") }
  let(:browser_evidence_runbook) { read_doc("doc/visual_reference_browser_evidence.md") }

  it "keeps the browser evidence runbook packaged and scoped as manual review guidance" do
    expect(specification.files).to include("doc/visual_reference_browser_evidence.md")

    expect(visual_references).to include(
      "## Recording browser evidence",
      "If the run is connector-only and no browser screenshot is available",
      "Do not paste it as a release approval when the browser pass was not actually run"
    )

    expect(development_doc).to include(
      "whether a static visual reference PR is still waiting for browser-capable desktop or narrow viewport evidence",
      "needs-browser-evidence"
    )

    expect(browser_evidence_runbook).to include(
      "manual reviewer aid, not CI automation, screenshot approval, or a merge bot",
      "CI success and source review are useful context, but they are not browser visual approval.",
      "Desktop: about `1280x900`",
      "Narrow: about `390x844`",
      "PR comment format",
      "Do not mark a visual reference as browser-approved unless the desktop and narrow browser review actually ran."
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
