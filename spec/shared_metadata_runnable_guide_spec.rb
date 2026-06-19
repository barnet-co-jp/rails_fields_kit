# frozen_string_literal: true

require "spec_helper"

RSpec.describe "shared metadata runnable guide" do
  let(:guide_path) { File.expand_path("../doc/shared_metadata_runnable_guide.md", __dir__) }
  let(:guide) { File.read(guide_path) }
  let(:navigation_path) { File.expand_path("../doc/shared_metadata_navigation.md", __dir__) }
  let(:navigation) { File.read(navigation_path) }

  it "keeps the guide focused on current public surfaces" do
    expect(guide).to include(
      "RailsFieldsKit::TokenSuggestions.build",
      "RailsFieldsKit::RansackSuggestions.build",
      "RailsFieldsKit::TableFilterInput.ransack_filter"
    )

    expect(guide).to include(
      "Do not treat this guide as a registry API",
      "does not add a Rails Fields Kit-owned field/operator registry",
      "submitted token parsing",
      "Ransack execution",
      "authorization"
    )
  end

  it "keeps the navigation page pointing to the runnable guide" do
    expect(navigation).to include(
      "shared_metadata_runnable_guide.md",
      "copyable runnable guide"
    )
  end
end
