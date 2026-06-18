# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "datalist boundary docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:boundary_doc) { File.read(File.expand_path("../doc/datalist_boundary.md", __dir__)) }
  let(:public_api) { File.read(File.expand_path("../doc/public_api.md", __dir__)) }
  let(:roadmap) { File.read(File.expand_path("../ROADMAP.md", __dir__)) }

  it "ships the datalist boundary doc as maintained package documentation" do
    expect(specification.files).to include("doc/datalist_boundary.md")
  end

  it "keeps the datalist proposal routed from the roadmap without promoting it to public API" do
    form_builder_section = markdown_section(public_api, "## FormBuilder helpers")

    expect(roadmap).to include(
      "`doc/datalist_boundary.md` is the current proposal boundary for HTML datalist support",
      "keeps `rfk_datalist_field` out of the current public API",
      "- datalist helpers for browser-native suggestions",
      "[`doc/datalist_boundary.md`](doc/datalist_boundary.md)",
      "Current support stays in `rfk_text_field list:` plus host-owned `<datalist>` markup"
    )
    expect(form_builder_section).not_to include("rfk_datalist_field")
  end

  it "keeps the boundary doc explicit about current lanes and host-owned responsibilities" do
    expect(boundary_doc).to include(
      "does not add `rfk_datalist_field` to the current public API",
      "ordinary text input",
      "host app own the `<datalist>` markup",
      "submitted field as an ordinary text input",
      "Rails Fields Kit owns only the native text wrapper, hint, error, affix, and accessibility wiring around the input",
      "Do not list `rfk_datalist_field` in `doc/public_api.md` unless a later implementation PR actually adds and tests the helper."
    )

    %w[
      rfk_text_field
      rfk_autocomplete
      rfk_combobox
      rfk_tags
      rfk_token_search
    ].each do |helper_name|
      expect(boundary_doc).to include("`#{helper_name}`")
    end
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
