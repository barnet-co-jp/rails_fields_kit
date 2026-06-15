# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "collection group helper boundary docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:boundary_doc_path) { File.expand_path("../doc/collection_group_helpers.md", __dir__) }
  let(:boundary_doc) { File.read(boundary_doc_path) }

  it "ships the collection group boundary document" do
    expect(specification.files).to include("doc/collection_group_helpers.md")
  end

  it "keeps collection checkbox and radio groups outside the current helper API" do
    expect(boundary_doc).to include(
      "does not currently provide first-class collection checkbox or collection radio group helpers",
      "Use Rails and host-app markup for collection groups today",
      "Do not treat proposal branches, open PR helper names, or local wrapper experiments as public API"
    )
  end

  it "keeps future collection group helper requirements explicit" do
    expect(boundary_doc).to include(
      "preserve Rails collection parameter names and selected-value semantics",
      "render or accept a semantic `fieldset` and `legend` boundary",
      "support group-level hint and validation feedback",
      "wire group-level feedback through `aria-describedby`",
      "keep option querying, authorization, persistence, and custom filtering in the host app"
    )
  end
end