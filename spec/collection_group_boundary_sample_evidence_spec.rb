# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "collection group boundary sample evidence" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:boundary_doc) { File.read(File.expand_path("../doc/collection_group_helpers.md", __dir__)) }
  let(:public_api) { File.read(File.expand_path("../doc/public_api.md", __dir__)) }
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }
  let(:visual_reference_index) { File.read(File.expand_path("../doc/visual_reference_index.html", __dir__)) }

  it "packages the proposal-only artifact without promoting it to current API or visual inventory" do
    artifact_path = "doc/collection_group_boundary_sample_evidence.html"

    expect(specification.files).to include(artifact_path)
    expect(boundary_doc).to include(
      "[`collection_group_boundary_sample_evidence.html`](collection_group_boundary_sample_evidence.html)",
      "not a current visual reference family member",
      "release evidence lane",
      "public API inventory item"
    )

    expect(public_api).not_to include(artifact_path)
    expect(readme).not_to include(artifact_path)
    expect(visual_reference_index).not_to include(artifact_path)
  end
end
