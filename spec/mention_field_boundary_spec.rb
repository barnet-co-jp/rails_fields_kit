# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "mention field boundary docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:mention_boundary) { File.read(File.expand_path("../doc/mention_field_boundary.md", __dir__)) }
  let(:public_api) { File.read(File.expand_path("../doc/public_api.md", __dir__)) }
  let(:roadmap) { File.read(File.expand_path("../ROADMAP.md", __dir__)) }
  let(:visual_references) { File.read(File.expand_path("../doc/visual_references.md", __dir__)) }

  it "keeps mention fields packaged as proposal-only docs without promoting a helper" do
    form_builder_helpers = markdown_section(public_api, "## FormBuilder helpers")

    expect(specification.files).to include("doc/mention_field_boundary.md")
    expect(mention_boundary).to include(
      "proposal boundary, not an implemented API contract",
      "Do not add `rfk_mention_field`, mention overlay screenshots, or mention-specific cards",
      "keep it out of `visual_references.md`, `visual_reference_index.html`, release evidence, and `public_api.md` until the helper lands",
      "host apps own"
    )
    expect(roadmap).to include(
      "`doc/mention_field_boundary.md` is the current proposal boundary for textarea mention workflows",
      "mention parsing, overlay behavior, hidden metadata, authorization, and persistence as host-app responsibilities",
      "mention fields for `@user` or `#tag` style textarea interactions"
    )
    expect(form_builder_helpers).not_to include("rfk_mention_field")
    expect(visual_references).not_to include("rfk_mention_field")
    expect(visual_references).not_to include("mention overlay")
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
