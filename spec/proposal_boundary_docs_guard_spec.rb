# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "proposal boundary docs guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:masked_input_boundary) { read_doc("doc/masked_input_boundary.md") }
  let(:slug_helper_boundary) { read_doc("doc/slug_helper_boundary.md") }
  let(:datalist_boundary) { read_doc("doc/datalist_boundary.md") }

  it "keeps proposal-only boundary docs packaged and routed from README without promoting helper names" do
    expect(specification.files).to include(
      "doc/masked_input_boundary.md",
      "doc/slug_helper_boundary.md",
      "doc/datalist_boundary.md"
    )

    expect(readme).to include(
      "For masked input, title-to-slug, or native datalist directions",
      "Rails Fields Kit does not currently provide `rfk_masked_field`, `rfk_slug_field`, or `rfk_datalist_field`",
      "[`doc/masked_input_boundary.md`](doc/masked_input_boundary.md)",
      "[`doc/slug_helper_boundary.md`](doc/slug_helper_boundary.md)",
      "[`doc/datalist_boundary.md`](doc/datalist_boundary.md)",
      "only when comparing the current native wrapper and Tom Select-backed lanes with those future proposals"
    )

    expect(public_api).not_to include("rfk_masked_field")
    expect(public_api).not_to include("rfk_slug_field")
    expect(public_api).not_to include("rfk_datalist_field")
  end

  it "keeps each proposal boundary doc explicit about host-app ownership and non-current API status" do
    expect(masked_input_boundary).to include(
      "Masked inputs are a future proposal, not current public API.",
      "host app own the masking layer",
      "Do not add helper names such as `rfk_masked_field` to the current public API"
    )

    expect(slug_helper_boundary).to include(
      "Rails Fields Kit does not currently provide a dedicated title-to-slug helper such as `rfk_slug_field`",
      "the host app owns the workflow that turns a title into a persisted slug",
      "no current `rfk_slug_field` public helper"
    )

    expect(datalist_boundary).to include(
      "It does not add `rfk_datalist_field` to the current public API.",
      "`rfk_text_field list:` plus host-owned `<datalist>` markup",
      "Do not add `rfk_datalist_field` to `doc/public_api.md` unless a later implementation PR actually adds and tests the helper"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
