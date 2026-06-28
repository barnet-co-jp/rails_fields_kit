# frozen_string_literal: true

require "spec_helper"

RSpec.describe "README JavaScript export routing aid" do
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }
  let(:public_api) { File.read(File.expand_path("../doc/public_api.md", __dir__)) }

  it "keeps the README helper-family table as a routing aid instead of an export inventory" do
    readme_js_setup = markdown_section(readme, "### Direct imports and package exports")
    javascript_exports = markdown_section(public_api, "## JavaScript exports")

    expect(readme_js_setup).to include(
      "This README is a route map",
      "representative helper-family table below as the full package-root export inventory",
      "routing aid, not an exhaustive export list",
      "exact current export names or contract details",
      "[`doc/public_api.md`](doc/public_api.md#javascript-exports)",
      "do not infer a different import policy"
    )

    expect(javascript_exports).to include(
      "### Current package-root exports",
      "Prefer package-root imports for normal rendered-field contract helper use",
      "Direct helper subpaths are setup and troubleshooting routes",
      "keep README, setup, and generated setup notes as routing guidance rather than mirrors of every helper export"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
