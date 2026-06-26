# frozen_string_literal: true

require "json"
require "rubygems"
require "spec_helper"

RSpec.describe "docs package inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:package_json) { JSON.parse(File.read(File.join(root, "package.json"))) }
  let(:readme) { read_doc("README.md") }
  let(:setup_doc) { read_doc("doc/setup.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:native_select_boundary) { read_doc("doc/native_select_boundary_sample_evidence.html") }
  let(:tom_select_no_event_boundary) { read_doc("doc/tom_select_no_event_boundary_review.html") }
  let(:dropdown_parent_release_evidence) { read_doc("doc/dropdown_parent_release_evidence.md") }

  it "keeps documented direct subpath examples aligned with package exports" do
    direct_exports = package_json.fetch("exports").keys.grep_v(".").map { |path| path.delete_prefix("./") }

    expect(direct_exports).to eq(%w[
      tom_select_controller
      tom_select_text_override_contract
      native_field_accessibility_contract
    ])

    direct_exports.each do |entrypoint|
      expect(readme).to include("rails_fields_kit/#{entrypoint}")
      expect(setup_doc).to include("rails_fields_kit/#{entrypoint}")
    end

    expect(readme).to include(
      "Do not treat the representative helper-family table below as the full package-root export inventory",
      "Check [`doc/public_api.md#javascript-exports`](doc/public_api.md#javascript-exports) for the complete current package-root surface"
    )
    expect(setup_doc).to include(
      "direct helper subpath examples in this setup guide are intentionally limited",
      "Do not extend the alias or importmap examples by copying every package-root helper name from the public API table"
    )
    expect(public_api).to include("## JavaScript exports")
  end

  it "keeps map-only native select boundary evidence packaged and scoped" do
    expect(specification.files).to include("doc/native_select_boundary_sample_evidence.html")
    expect(visual_references).to include(
      "[`native_select_boundary_sample_evidence.html`](native_select_boundary_sample_evidence.html)",
      "Map-only companion lane for plain native select, grouped optgroup select, and Tom Select-backed collection boundary comparison"
    )
    expect(native_select_boundary).to include(
      "Plain select stays browser-native",
      "Grouped select preserves optgroup meaning",
      "Searchable choices use Tom Select lanes",
      "Native browser selection semantics, Tom Select rendering, search execution, authorization, persistence, endpoint payloads, and production CSS remain outside this artifact.",
      "remote grouped options, authorization, and query execution are not Rails Fields Kit-owned"
    )
    expect(public_api).not_to include("rfk_native_select")
  end

  it "keeps Tom Select no-event boundary evidence packaged and scoped" do
    expect(specification.files).to include("doc/tom_select_no_event_boundary_review.html")
    expect(visual_references).to include(
      "[`tom_select_no_event_boundary_review.html`](tom_select_no_event_boundary_review.html)",
      "Map-only companion lane for stale / aborted request no-event states beside current request failure"
    )
    expect(tom_select_no_event_boundary).to include(
      "Stale or aborted request is ignored",
      "Suppressed, not failed",
      "No success or failure event is dispatched",
      "No request-start or request-finish event proposal",
      "No built-in retry, cancellation banner, toast, or fallback UI"
    )
  end

  it "keeps dropdown parent release evidence packaged and scoped" do
    expect(specification.files).to include("doc/dropdown_parent_release_evidence.md")
    expect(dropdown_parent_release_evidence).to include(
      "Selector pass-through",
      "No-config boundary",
      "dropdown_parent: \"body\"",
      "data-rails-fields-kit--tom-select-dropdown-parent-value",
      "dropdownParent: \"body\"",
      "Do not use this lane as proof of browser positioning, modal layout, portal implementation, z-index policy, or production CSS"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
