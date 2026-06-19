# frozen_string_literal: true

require "spec_helper"

RSpec.describe "mention field boundary docs" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { File.read(File.join(root, "README.md")) }
  let(:field_helpers) { File.read(File.join(root, "doc/field_helpers.md")) }
  let(:mention_boundary) { File.read(File.join(root, "doc/mention_field_boundary.md")) }
  let(:public_api) { File.read(File.join(root, "doc/public_api.md")) }

  it "keeps the mention field boundary packaged as proposal-only documentation" do
    expect(specification.files).to include("doc/mention_field_boundary.md")
    expect(readme).to include("doc/mention_field_boundary.md")
    expect(field_helpers).to include("mention_field_boundary.md")

    expect(mention_boundary).to include("does not currently provide a textarea mention helper")
    expect(mention_boundary).to include("proposal boundary, not an implemented API contract")
    expect(mention_boundary).to include("Do not add `rfk_mention_field`")
    expect(mention_boundary).to include("keep it out of `visual_references.md`, `visual_reference_index.html`, release evidence, and `public_api.md` until the helper lands")
    expect(mention_boundary).to include("host app owns any mention parsing")

    expect(public_api).not_to include("rfk_mention_field")
  end
end
