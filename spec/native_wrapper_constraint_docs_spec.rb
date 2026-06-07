# frozen_string_literal: true

require "spec_helper"

RSpec.describe "native wrapper constraint docs" do
  let(:public_api) { File.read(File.expand_path("../doc/public_api.md", __dir__)) }
  let(:field_helpers) { File.read(File.expand_path("../doc/field_helpers.md", __dir__)) }
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }

  it "keeps native browser attribute pass-through and ownership boundaries visible" do
    form_builder_section = markdown_section(public_api, "## FormBuilder helpers")
    quick_chooser = markdown_section(field_helpers, "## Quick chooser")

    expect(form_builder_section).to include(
      "Native wrapper helpers pass ordinary Rails/native input attributes",
      "`maxlength`",
      "`minlength`",
      "`pattern`",
      "`required`",
      "`autocomplete`",
      "`inputmode`",
      "top-level field options or `html:`",
      "host-app responsibility"
    )

    expect(quick_chooser).to include(
      "native browser input with shared wrapper, hint, error, affix, and accessibility behavior",
      "Stays in the ordinary HTML input flow while reusing Rails Fields Kit wrapper conventions"
    )

    expect(readme).to include(
      "Use the native wrapper helpers",
      "when a native browser input is enough",
      "consistent labels, hints, validation errors, prefixes, suffixes, and accessibility wiring"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
