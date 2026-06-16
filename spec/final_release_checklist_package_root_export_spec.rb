# frozen_string_literal: true

require "spec_helper"

RSpec.describe "final release checklist package-root export matrix" do
  let(:public_api_path) { File.expand_path("../doc/public_api.md", __dir__) }
  let(:public_api) { File.read(public_api_path) }
  let(:checklist_path) { File.expand_path("../doc/final_release_checklist.md", __dir__) }
  let(:checklist) { File.read(checklist_path) }

  it "keeps the release matrix aligned with the public API export table" do
    public_exports = current_package_root_exports_from(public_api)
    checklist_exports = release_matrix_exports_from(checklist)

    expect(public_exports).not_to be_empty
    expect(checklist_exports).to match_array(public_exports)
    expect(checklist).to include(
      "Confirm `doc/public_api.md#javascript-exports` is the source of truth for current package-root exports",
      "Confirm future package-root helper exports are added to `doc/public_api.md#javascript-exports` before being added to this release verification matrix"
    )
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
