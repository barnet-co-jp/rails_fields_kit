# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "visual reference browser evidence docs inventory" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:browser_evidence) { read_doc("doc/visual_reference_browser_evidence.md") }

  it "keeps the browser evidence runbook packaged and reachable from the visual reference map" do
    expect(specification.files).to include("doc/visual_reference_browser_evidence.md")

    expect(readme).to include(
      "[`doc/visual_reference_browser_evidence.md`](doc/visual_reference_browser_evidence.md)",
      "manual desktop/narrow browser-capable evidence beyond CI or source review"
    )

    expect(visual_references).to include(
      "Evidence shorthand: source review checks file content, links, headings, and scope text; browser visual approval checks the rendered artifact at the stated viewport.",
      "If the run is connector-only and no browser screenshot is available, say what was checked instead"
    )
  end

  it "keeps browser evidence scoped away from CI automation and merge approval" do
    expect(browser_evidence).to include(
      "manual reviewer aid, not CI automation, screenshot approval, or a merge bot",
      "Do not use this as proof for runtime behavior, Tom Select lifecycle behavior, request execution, production CSS, host-app copy policy, or public API adoption decisions.",
      "CI success and source review are useful context, but they are not browser visual approval.",
      "Do not mark a visual reference as browser-approved unless the desktop and narrow browser review actually ran."
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
