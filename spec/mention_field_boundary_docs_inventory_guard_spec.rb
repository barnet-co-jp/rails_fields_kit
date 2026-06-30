# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "mention field boundary docs inventory" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(repo_root, "rails_fields_kit.gemspec")) }
  let(:readme) { File.read(File.join(repo_root, "README.md")) }
  let(:roadmap) { File.read(File.join(repo_root, "ROADMAP.md")) }
  let(:public_api) { File.read(File.join(repo_root, "doc/public_api.md")) }
  let(:visual_references) { File.read(File.join(repo_root, "doc/visual_references.md")) }
  let(:mention_boundary) { File.read(File.join(repo_root, "doc/mention_field_boundary.md")) }

  it "keeps the mention proposal boundary packaged without promoting it to current API" do
    expect(specification.files).to include("doc/mention_field_boundary.md")

    expect(readme).to include(
      "[`doc/mention_field_boundary.md`](doc/mention_field_boundary.md)",
      "Rails Fields Kit does not currently provide a public mention helper",
      "do not treat `rfk_mention_field` as part of the current public API"
    )

    expect(roadmap).to include(
      "mention fields for `@user` or `#tag` style textarea interactions",
      "[`doc/mention_field_boundary.md`](doc/mention_field_boundary.md)",
      "Current support stays in `rfk_autocomplete` for plain text suggestions, `rfk_token_search` for structured search text, `rfk_tags` for tag-entry fields, or `rfk_text_area` for ordinary textarea content"
    )

    expect(mention_boundary).to include(
      "proposal boundary, not an implemented API contract",
      "Do not add `rfk_mention_field`, mention overlay screenshots, or mention-specific cards to the visual reference family as current Rails Fields Kit evidence",
      "Use [`mention_field_boundary_sample_evidence.html`](mention_field_boundary_sample_evidence.html) only as proposal-only review evidence",
      "The host app still parses and executes submitted search text",
      "The textarea remains native",
      "Autosize, parsing, mention overlay UI, and persisted mention metadata stay with the host app",
      "authorization and scoping for suggestion endpoints",
      "persistence of mention links or hidden metadata"
    )

    expect(public_api).not_to include("rfk_mention_field")
    expect(visual_references).not_to include("mention_field_boundary_sample_evidence.html")
  end
end
