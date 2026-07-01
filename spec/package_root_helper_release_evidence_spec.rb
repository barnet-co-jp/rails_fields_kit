# frozen_string_literal: true

require "spec_helper"

RSpec.describe "package-root helper release evidence guide" do
  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end

  let(:public_api_path) { File.expand_path("../doc/public_api.md", __dir__) }
  let(:public_api) { File.read(public_api_path) }
  let(:javascript_exports) { markdown_section(public_api, "## JavaScript exports") }
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

  it "keeps helper-specific evidence lanes aligned with current public JavaScript exports" do
    current_package_root_helpers = javascript_exports.scan(/`([a-z][A-Za-z0-9]+\(element\))`/).flatten.uniq

    expect(current_package_root_helpers).to contain_exactly(
      "tomSelectTextOverrideContract(element)",
      "tomSelectPluginContract(element)",
      "tomSelectSelectionContract(element)",
      "tomSelectRequestContract(element)",
      "tomSelectFieldKindContract(element)",
      "readRenderedErrorSurface(element)",
      "readRenderedTomSelectInteractionConfig(element)",
      "readRenderedSelectedPreloadConfig(element)",
      "readRenderedOptionPayloadMapping(element)",
      "readRenderedTableFilterMetadata(element)",
      "nativeFieldAccessibilityContract(element)",
      "nativeFieldConstraintContract(element)"
    )

    expect(evidence_guide).to include(
      "For other current helpers listed in `doc/public_api.md#javascript-exports`",
      "name the helper exactly as documented in `doc/public_api.md#javascript-exports`"
    )

    helper_specific_lanes = evidence_guide.scan(/import \{ ([a-z][A-Za-z0-9]+) \} from "rails_fields_kit"/).flatten

    expect(helper_specific_lanes).to contain_exactly(
      "readRenderedSelectedPreloadConfig",
      "readRenderedTomSelectInteractionConfig",
      "readRenderedOptionPayloadMapping",
      "readRenderedTableFilterMetadata",
      "tomSelectTextOverrideContract",
      "tomSelectPluginContract",
      "tomSelectSelectionContract",
      "tomSelectRequestContract",
      "readRenderedErrorSurface",
      "nativeFieldAccessibilityContract"
    )
    expect(helper_specific_lanes).to all(satisfy do |helper_name|
      current_package_root_helpers.include?("#{helper_name}(element)")
    end)
  end
end
