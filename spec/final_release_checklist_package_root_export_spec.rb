# frozen_string_literal: true

require "spec_helper"

RSpec.describe "final release checklist package-root export matrix" do
  let(:public_api_path) { File.expand_path("../doc/public_api.md", __dir__) }
  let(:public_api) { File.read(public_api_path) }
  let(:checklist_path) { File.expand_path("../doc/final_release_checklist.md", __dir__) }
  let(:checklist) { File.read(checklist_path) }

  it "keeps the release matrix tied to the current public API export table" do
    public_exports = current_package_root_exports_from(public_api)
    checklist_exports = release_matrix_exports_from(checklist)
    representative_exports = [
      "TomSelectController",
      "nativeFieldAccessibilityContract(element)",
      "readRenderedSelectedPreloadConfig(element)",
      "tomSelectPluginContract(element)",
      "tomSelectTextOverrideContract(element)"
    ]
    source_of_truth_signals = [
      "doc/public_api.md#javascript-exports",
      "source of truth for current package-root exports",
      "future package-root helper exports",
      "before being added to this release verification matrix"
    ]

    expect(public_exports).not_to be_empty
    expect(checklist_exports).to include(*representative_exports)
    expect(checklist_exports - public_exports).to be_empty
    source_of_truth_signals.each { |signal| expect(checklist).to include(signal) }
  end

  def current_package_root_exports_from(document)
    current_exports_table = document
      .split("### Current package-root exports", 2)
      .fetch(1)
      .split("### Import patterns", 2)
      .first

    current_exports_table.scan(/^\| `([^`]+)` \|/).flatten
  end

  def release_matrix_exports_from(document)
    release_matrix = document
      .split("- [ ] Confirm the current package-root export matrix before release:", 2)
      .fetch(1)
      .split("- [ ] Confirm future package-root helper exports", 2)
      .first

    release_matrix.scan(/^  - \[ \] `([^`]+)`/).flatten
  end
end
