# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "visual reference browser evidence guide" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:browser_evidence_guide) { read_doc("doc/visual_reference_browser_evidence.md") }

  it "keeps the manual browser evidence guide packaged and discoverable" do
    expect(specification.files).to include("doc/visual_reference_browser_evidence.md")
    expect(readme).to include(
      "[`doc/visual_reference_browser_evidence.md`](doc/visual_reference_browser_evidence.md)",
      "manual desktop/narrow browser-capable evidence beyond CI or source review"
    )
    expect(visual_references).to include(
      "If the run is connector-only and no browser screenshot is available, say what was checked instead",
      "Do not paste it as a release approval when the browser pass was not actually run"
    )
  end

  it "keeps CI/source review separate from browser visual approval" do
    expect(browser_evidence_guide).to include(
      "manual reviewer aid, not CI automation, screenshot approval, or a merge bot",
      "CI success and source review are useful context, but they are not browser visual approval",
      "Do not mark a visual reference as browser-approved unless the desktop and narrow browser review actually ran"
    )
    expect(browser_evidence_guide).to include(
      "Desktop: about `1280x900`",
      "Narrow: about `390x844`",
      "labels, hints, validation copy, and boundary copy remain readable",
      "runtime behavior, production CSS, host-app copy, and merge approval remain out of scope"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
