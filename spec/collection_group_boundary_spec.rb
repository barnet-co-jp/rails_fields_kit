# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "collection group boundary docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:boundary_doc) { File.read(File.expand_path("../doc/collection_group_helpers.md", __dir__)) }
  let(:public_api) { File.read(File.expand_path("../doc/public_api.md", __dir__)) }

  it "ships the collection group boundary doc as maintained package documentation" do
    expect(specification.files).to include("doc/collection_group_helpers.md")
  end

  it "keeps collection group helpers out of the current FormBuilder public API" do
    form_builder_section = markdown_section(public_api, "## FormBuilder helpers")

    expect(form_builder_section).to include(
      "See [`collection_group_helpers.md`](collection_group_helpers.md)",
      "Collection checkbox / radio group helpers are also not current public APIs",
      "Host apps should keep using ordinary Rails collection helpers or host-app markup for group semantics"
    )
    expect(form_builder_section).not_to include("rfk_collection_check_boxes")
    expect(form_builder_section).not_to include("rfk_collection_radio_buttons")
  end

  it "keeps the boundary doc explicit about Rails-owned collection semantics" do
    expect(boundary_doc).to include(
      "does not currently provide first-class collection checkbox or collection radio group helpers",
      "collection_check_boxes",
      "collection_radio_buttons",
      "host app owns `fieldset`, `legend`, group-level hint copy, group-level validation errors, and any `aria-describedby` wiring",
      "Do not treat proposal branches, open PR helper names, or local wrapper experiments as public API",
      "Single checkbox or radio wrappers can be reviewed as individual field helpers after they are merged and listed in `public_api.md`",
      "A future helper should be planned as a separate collection group surface instead of being inferred from `rfk_check_box`"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
