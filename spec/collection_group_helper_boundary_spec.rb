# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "collection group helper boundary docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:boundary_doc_path) { File.expand_path("../doc/collection_group_helpers.md", __dir__) }
  let(:boundary_doc) { File.read(boundary_doc_path) }
  let(:public_api_doc) { File.read("doc/public_api.md") }

  it "ships the collection group boundary document" do
    expect(specification.files).to include("doc/collection_group_helpers.md")
  end

  it "keeps collection checkbox and radio groups outside the current helper API" do
    expect(boundary_doc).to include(
      "does not currently provide first-class collection checkbox or collection radio group helpers",
      "This slice keeps collection checkbox and radio groups outside the current FormBuilder helper API",
      "Do not treat proposal branches, open PR helper names, or local wrapper experiments as public API"
    )

    expect(public_api_doc).to include(
      "Collection checkbox / radio group helpers are also not current public APIs",
      "Future proposal names, open PR helper names, and single-control wrapper helpers must not be read as current collection group API"
    )
  end

  it "keeps future collection group helper requirements explicit" do
    expect(boundary_doc).to include(
      "preserve Rails collection parameter names and selected-value semantics",
      "preserve per-option checked-state behavior",
      "render or accept a semantic `fieldset` and `legend` boundary",
      "support group-level hint and validation feedback",
      "wire group-level feedback through `aria-describedby`",
      "keep per-option label, hint, and disabled-state customization separate from group-level feedback",
      "keep option querying, authorization, persistence, and custom filtering in the host app"
    )
  end

  it "separates collection group scope from single-control wrappers" do
    expect(boundary_doc).to include(
      "single checkbox or radio wrappers can delegate to one Rails input helper",
      "collection helpers must preserve a set of inputs with shared naming",
      "A future helper should be planned as a separate collection group surface instead of being inferred from `rfk_check_box`, a future `rfk_radio_button`, or table metadata helpers"
    )
  end
end
