# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "Tom Select clearable visual reference inventory" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:visual_references) { read_repo_file("doc/visual_references.md") }
  let(:clearable_review) { read_repo_file("doc/tom_select_plugin_clearable_review.html") }
  let(:public_api) { read_repo_file("doc/public_api.md") }

  it "keeps the map-only clearable review artifact packaged and scoped" do
    expect(specification.files).to include("doc/tom_select_plugin_clearable_review.html")
    expect(visual_references).to include(
      "[`tom_select_plugin_clearable_review.html`](tom_select_plugin_clearable_review.html)",
      "Map-only companion lane for `allow_clear: true`, whole-field clear affordance, per-item remove contrast, and host-owned plugin boundaries",
      "plugin assets, styling, event payloads, selection mutation, and Tom Select lifecycle behavior outside Rails Fields Kit"
    )
    expect(clearable_review).to include(
      "Rails Fields Kit Tom Select Plugin Clearable Review",
      "Whole-field clear affordance",
      "Tag remove buttons are not whole-field clear",
      "Rails Fields Kit does not ship Tom Select plugin assets, theme CSS, selection mutation logic, or lifecycle events"
    )
    expect(public_api).to include("allow_clear: true")
  end

  def read_repo_file(path)
    File.read(File.join(root, path))
  end
end
