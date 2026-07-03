# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "map-only sample evidence inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:mention_boundary) { read_doc("doc/mention_field_boundary.md") }
  let(:mention_sample) { read_doc("doc/mention_field_boundary_sample_evidence.html") }
  let(:native_select_sample) { read_doc("doc/native_select_boundary_sample_evidence.html") }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:visual_reference_index) { read_doc("doc/visual_reference_index.html") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:release_guide) { read_doc("doc/release.md") }

  it "keeps mention proposal evidence packaged without promoting a current helper" do
    expect(specification.files).to include("doc/mention_field_boundary_sample_evidence.html")

    expect(mention_boundary).to include(
      "[`mention_field_boundary_sample_evidence.html`](mention_field_boundary_sample_evidence.html)",
      "proposal-only review evidence",
      "kept out of `visual_references.md`, `visual_reference_index.html`, release evidence, and `public_api.md`",
      "Do not add `rfk_mention_field`"
    )

    expect(mention_sample).to include(
      "Mention Field Proposal-Only Evidence",
      "No current `rfk_mention_field` exists.",
      "No visual reference registration",
      "Do not infer `rfk_mention_field`, `mention:` options, or package-root exports from this page.",
      "This is static evidence only. It does not add overlay JavaScript, endpoint contracts, production CSS, or parsing."
    )

    expect(visual_references).not_to include("mention_field_boundary_sample_evidence.html")
    expect(visual_reference_index).not_to include("mention_field_boundary_sample_evidence.html")
    expect(public_api).not_to include("rfk_mention_field")
    expect(release_guide).not_to include("mention_field_boundary_sample_evidence.html")
  end

  it "keeps native select boundary sample evidence packaged and map-only" do
    expect(specification.files).to include("doc/native_select_boundary_sample_evidence.html")

    expect(visual_references).to include(
      "[`native_select_boundary_sample_evidence.html`](native_select_boundary_sample_evidence.html)",
      "map-only companion",
      "plain native select, grouped optgroup select, and Tom Select-backed collection lanes",
      "remote optgroup endpoints, custom renderers, option payload mapping, search execution, authorization, persistence, and production CSS outside Rails Fields Kit"
    )

    expect(native_select_sample).to include(
      "Native Select Boundary Evidence",
      "Map-only native helper evidence",
      "Static review artifact only.",
      "Plain select stays browser-native",
      "Grouped select preserves optgroup meaning",
      "Searchable choices use Tom Select lanes",
      "No search, async loading, custom renderer, chip UI, or endpoint behavior is implied."
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
