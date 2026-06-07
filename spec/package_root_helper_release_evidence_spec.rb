# frozen_string_literal: true

require "spec_helper"

RSpec.describe "package-root helper release evidence guide" do
  let(:evidence_guide_path) { File.expand_path("../doc/package_root_helper_release_evidence.md", __dir__) }
  let(:evidence_guide) { File.read(evidence_guide_path) }

  it "keeps current helper names and return shapes delegated to the public API docs" do
    expect(evidence_guide).to include(
      "Use `doc/public_api.md#javascript-exports` as the source of truth",
      "current package-root helper list",
      "documented return-shape boundaries",
      "This guide should not duplicate every helper's full return shape"
    )
  end

  it "keeps helper-family evidence scoped to in-scope current public API lanes" do
    expect(evidence_guide).to include(
      "choose only the package-root helper lanes that are in scope for that change",
      "Do not add helper-specific sections for open PR helpers",
      "If a helper exists only on an open branch",
      "leave this guide pointed at the current public API table",
      "link or point back to `doc/public_api.md`"
    )
  end
end
