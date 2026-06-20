# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "mention field boundary docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:boundary_doc) { File.read(File.expand_path("../doc/mention_field_boundary.md", __dir__)) }
  let(:public_api) { File.read(File.expand_path("../doc/public_api.md", __dir__)) }
  let(:roadmap) { File.read(File.expand_path("../ROADMAP.md", __dir__)) }
  let(:visual_references) { File.read(File.expand_path("../doc/visual_references.md", __dir__)) }

  it "ships the mention field boundary doc as maintained package documentation" do
    expect(specification.files).to include("doc/mention_field_boundary.md")
  end

  it "keeps the mention field proposal routed from the roadmap without promoting it to public API" do
    roadmap_mention_lane = roadmap.split("- mention fields", 2).last.split("\n- saved search selectors", 2).first
    form_builder_section = markdown_section(public_api, "## FormBuilder helpers")

    expect(roadmap_mention_lane).to include(
      "[`doc/mention_field_boundary.md`](doc/mention_field_boundary.md)",
      "Current support stays in `rfk_autocomplete`",
      "`rfk_token_search`",
      "`rfk_tags`",
      "`rfk_text_area`",
      "host-app-owned parsing, authorization, and persistence"
    )
    expect(form_builder_section).not_to include("rfk_mention_field")
  end

  it "keeps mention proposal names out of the current visual reference family" do
    expect(visual_references).not_to include("rfk_mention_field")
    expect(visual_references).not_to include("mention overlay")
    expect(visual_references).not_to include("mention-specific")
  end

  it "keeps the boundary doc explicit about current lanes and host-owned responsibilities" do
    expect(boundary_doc).to include(
      "proposal boundary, not an implemented API contract",
      "Do not add `rfk_mention_field`",
      "mention overlay screenshots",
      "keep it out of `visual_references.md`, `visual_reference_index.html`, release evidence, and `public_api.md` until the helper lands",
      "parsing textarea content into mention tokens",
      "authorization and scoping for suggestion endpoints",
      "persistence of mention links or hidden metadata"
    )

    %w[
      rfk_autocomplete
      rfk_token_search
      rfk_tags
      rfk_text_area
    ].each do |helper_name|
      expect(boundary_doc).to include("`#{helper_name}`")
    end
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
