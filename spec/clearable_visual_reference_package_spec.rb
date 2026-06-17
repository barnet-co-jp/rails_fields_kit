# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "clearable visual reference package guard" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:visual_references_path) { File.expand_path("../doc/visual_references.md", __dir__) }
  let(:visual_references) { File.read(visual_references_path) }

  it "keeps the clearable plugin companion artifact packaged and map-only" do
    expect(specification.files).to include("doc/tom_select_plugin_clearable_review.html")
    expect(visual_references).to include(
      "[`tom_select_plugin_clearable_review.html`](tom_select_plugin_clearable_review.html)",
      "map-only companion lane",
      "single-select whole-field clear affordance",
      "without treating plugin assets, styling, event payloads, selection mutation, or Tom Select lifecycle as Rails Fields Kit behavior"
    )
  end
end
