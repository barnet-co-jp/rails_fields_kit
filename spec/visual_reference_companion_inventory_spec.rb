# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "visual reference companion inventory" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:visual_references_path) { File.expand_path("../doc/visual_references.md", __dir__) }
  let(:visual_references) { File.read(visual_references_path) }

  it "keeps rich option companion review packaged and mapped" do
    expect(specification.files).to include("doc/tom_select_rich_option_review.html")

    expect(visual_references).to include(
      "[`tom_select_rich_option_review.html`](tom_select_rich_option_review.html)",
      "Tom Select rich option review",
      "label, description, and badge readability",
      "endpoint payload shape, option mapping behavior, search execution, production CSS, and authorization outside the static artifact"
    )
  end

  it "keeps allow_clear companion review map-only and packaged" do
    expect(specification.files).to include("doc/tom_select_plugin_clearable_review.html")

    expect(visual_references).to include(
      "[`tom_select_plugin_clearable_review.html`](tom_select_plugin_clearable_review.html)",
      "map-only companion lane",
      "single-select whole-field clear affordance",
      "plugin assets, styling, event payloads, selection mutation, and Tom Select lifecycle behavior outside Rails Fields Kit"
    )
  end
end
