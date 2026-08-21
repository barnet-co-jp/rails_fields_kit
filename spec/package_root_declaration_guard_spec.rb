# frozen_string_literal: true

require "json"
require "spec_helper"

RSpec.describe "package root declaration guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:package_json) { JSON.parse(File.read(File.join(root, "package.json"))) }
  let(:index_js) { File.read(File.join(root, "app/javascript/rails_fields_kit/index.js")) }
  let(:index_dts) { File.read(File.join(root, "app/javascript/rails_fields_kit/index.d.ts")) }

  it "keeps the package root type entrypoint aligned with the root export" do
    root_types_path = "./app/javascript/rails_fields_kit/index.d.ts"

    expect(package_json.fetch("types")).to eq(root_types_path)
    expect(package_json.fetch("exports").fetch(".").fetch("types")).to eq(root_types_path)
    expect(package_json.fetch("exports").fetch(".").fetch("import")).to eq("./app/javascript/rails_fields_kit/index.js")
  end

  it "keeps package root helper exports declared in index.d.ts" do
    helper_exports = index_js.scan(/^export function\s+([A-Za-z0-9_]+)\s*\(/).flatten.sort
    helper_declarations = index_dts.scan(/^export function\s+([A-Za-z0-9_]+)\s*\(/).flatten.sort

    expected_current_helpers = %w[
      nativeFieldAccessibilityContract
      nativeFieldConstraintContract
      readRenderedErrorSurface
      readRenderedOptionPayloadMapping
      readRenderedSelectedPreloadConfig
      readRenderedTableFilterMetadata
      readRenderedTomSelectInteractionConfig
      tomSelectFieldKindContract
      tomSelectPluginContract
      tomSelectRequestContract
      tomSelectSelectionContract
      tomSelectTextOverrideContract
    ]

    expect(helper_exports).to include(*expected_current_helpers)
    expect(helper_declarations).to include(*expected_current_helpers)

    missing_declarations = helper_exports - helper_declarations
    stale_declarations = helper_declarations - helper_exports

    expect(missing_declarations).to be_empty, "missing TypeScript declarations for #{missing_declarations.join(', ')}"
    expect(stale_declarations).to be_empty, "stale TypeScript declarations without package-root exports: #{stale_declarations.join(', ')}"
  end
end
