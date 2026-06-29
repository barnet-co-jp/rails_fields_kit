# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "public integration docs guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:events_doc) { read_doc("doc/events.md") }
  let(:turbo_lifecycle_doc) { read_doc("doc/tom_select_turbo_lifecycle.md") }
  let(:shared_metadata_guide) { read_doc("doc/shared_metadata_runnable_guide.md") }

  it "keeps events and Turbo lifecycle docs packaged and routed as public integration guides" do
    expect(specification.files).to include("doc/events.md", "doc/tom_select_turbo_lifecycle.md")
    expect(readme).to include(
      "[`doc/events.md`](doc/events.md)",
      "[`doc/tom_select_turbo_lifecycle.md`](doc/tom_select_turbo_lifecycle.md)"
    )
    expect(public_api).to include(
      "[`events.md`](events.md)",
      "## Stimulus lifecycle contract",
      "## Stimulus events"
    )
    expect(events_doc).to include(
      "Rails Fields Kit does not render visible success or error messages by itself",
      "detail.surface",
      "Rails Fields Kit only dispatches success or failure events for the latest still-current request",
      "does not dispatch a separate request-start event or render built-in loading, retry, or fallback UI"
    )
    expect(turbo_lifecycle_doc).to include(
      "normal Stimulus lifecycle",
      "should not add a separate `turbo:load` reinitializer",
      "does not currently install a global `turbo:before-cache` listener",
      "single Tom Select wrapper"
    )
  end

  it "keeps shared metadata runnable guide packaged and scoped to host-owned derived views" do
    expect(specification.files).to include("doc/shared_metadata_runnable_guide.md")
    expect(public_api).to include(
      "[`shared_metadata_navigation.md`](shared_metadata_navigation.md)",
      "RailsFieldsKit::TokenSuggestions.build",
      "RailsFieldsKit::RansackSuggestions.build",
      "RailsFieldsKit::TableFilterInput.ransack_filter"
    )
    expect(shared_metadata_guide).to include(
      "one host-app-owned metadata source",
      "Rails Fields Kit receives only the derived hashes shown below",
      "RailsFieldsKit::TokenSuggestions.build",
      "RailsFieldsKit::RansackSuggestions.build",
      "RailsFieldsKit::TableFilterInput.ransack_filter",
      "The helper only builds suggestion option JSON; it does not call Ransack",
      "Do not treat this guide as a registry API",
      "Rails Fields Kit-owned field/operator registry",
      "authorization policy",
      "table preference persistence contract"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
