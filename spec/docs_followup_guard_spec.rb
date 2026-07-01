# frozen_string_literal: true

require "json"
require "rubygems"
require "spec_helper"

RSpec.describe "docs follow-up guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:package_json) { JSON.parse(read_doc("package.json")) }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:readme) { read_doc("README.md") }
  let(:mention_boundary) { read_doc("doc/mention_field_boundary.md") }
  let(:mention_evidence) { read_doc("doc/mention_field_boundary_sample_evidence.html") }
  let(:typescript_evidence) { read_doc("doc/typescript_declaration_release_evidence.md") }
  let(:package_root_helper_evidence) { read_doc("doc/package_root_helper_release_evidence.md") }
  let(:grouped_select) { read_doc("doc/grouped_select.md") }
  let(:product_profile) { read_doc("Product Profile.md") }

  it "keeps mention proposal-only evidence packaged without promoting a helper" do
    expect(specification.files).to include("doc/mention_field_boundary_sample_evidence.html")
    expect(mention_boundary).to include(
      "[`mention_field_boundary_sample_evidence.html`](mention_field_boundary_sample_evidence.html)",
      "proposal-only review evidence",
      "kept out of `visual_references.md`, `visual_reference_index.html`, release evidence, and `public_api.md`"
    )
    expect(mention_evidence).to include(
      "Proposal-only evidence",
      "No current `rfk_mention_field` exists.",
      "hidden metadata: not part of this proposal",
      "No visual reference registration",
      "No runtime behavior"
    )
    expect(public_api).not_to include("rfk_mention_field", "mention_field_boundary_sample_evidence.html")
    expect(visual_references).not_to include("mention_field_boundary_sample_evidence.html")
    expect(readme).not_to include("mention_field_boundary_sample_evidence.html")
  end

  it "keeps direct helper TypeScript metadata scoped to package metadata" do
    direct_helper_entrypoints = {
      "tom_select_text_override_contract" => "tomSelectTextOverrideContract",
      "native_field_accessibility_contract" => "nativeFieldAccessibilityContract",
      "native_field_constraint_contract" => "nativeFieldConstraintContract"
    }

    direct_helper_entrypoints.each do |entrypoint, helper_name|
      export = package_json.fetch("exports").fetch("./#{entrypoint}")
      declaration = read_doc("app/javascript/rails_fields_kit/#{entrypoint}.d.ts")

      expect(export).to include(
        "types" => "./app/javascript/rails_fields_kit/#{entrypoint}.d.ts",
        "import" => "./app/javascript/rails_fields_kit/#{entrypoint}.js",
        "default" => "./app/javascript/rails_fields_kit/#{entrypoint}.js"
      )
      expect(declaration).to include(
        helper_name,
        "#{helper_name} as default",
        "from \"./index.js\""
      )
    end

    javascript_exports = markdown_section(public_api, "## JavaScript exports")
    expect(javascript_exports).to include(
      "Direct helper subpath imports are supported only for helper files that `package.json` exports",
      "they do not add helper names, return shapes, or responsibility boundaries beyond the package-root table above"
    )
    expect(typescript_evidence).to include(
      "This is a package metadata and editor-assistance lane",
      "Any direct helper subpath with a documented `types` entry still matches a documented runtime subpath in `package.json`",
      "Evidence notes distinguish declaration metadata from runtime import behavior and host-app TypeScript configuration"
    )
  end

  it "keeps grouped select kind evidence anchored to read-only docs" do
    javascript_exports = markdown_section(public_api, "## JavaScript exports")

    expect(javascript_exports).to include(
      "tomSelectFieldKindContract(element)",
      "reports only the rendered helper-lane kind value"
    )
    expect(grouped_select).to include(
      "rendered field kind is `grouped_select`",
      "read-only contract checks through `tomSelectFieldKindContract(element)`",
      "ordinary select submission, selected values, disabled values, and `<optgroup>` rendering stay in the same collection-backed select lane"
    )
    expect(package_root_helper_evidence).to include(
      "Use this guide only for release or sample-app evidence lanes",
      "a scoped PR comment or `doc/sample_app_results.md` note is enough"
    )
  end

  it "keeps Product Profile Key docs grouped without mirroring every docs file" do
    key_docs = markdown_section(product_profile, "## Key docs")

    expect(key_docs).to include(
      "intentionally more complete than the README Docs map",
      "First-reader and repo orientation",
      "Setup and generated host-app notes",
      "Public API and behavior sources of truth",
      "Helper boundary docs",
      "Proposal-only boundary docs",
      "Visual reference family",
      "Release and evidence docs"
    )
    expect(key_docs).to include(
      "`doc/masked_input_boundary.md`",
      "`doc/slug_helper_boundary.md`",
      "`doc/datalist_boundary.md`",
      "`doc/mention_field_boundary.md`"
    )
    expect(readme).to include(
      "Use this map as a first reader route, not a full documentation inventory"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
