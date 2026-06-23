# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "token/table sample app evidence release route" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:release_doc) { File.read(File.expand_path("../doc/release.md", __dir__)) }
  let(:evidence_doc) { File.read(File.expand_path("../doc/token_table_sample_app_evidence.md", __dir__)) }

  it "keeps the guide packaged and reachable without making it a new release gate" do
    expect(specification.files).to include("doc/token_table_sample_app_evidence.md")

    expect(release_doc).to include(
      "doc/token_table_sample_app_evidence.md",
      "sample-app evidence",
      "companion lane selector"
    )
    expect(release_doc).to include("token search")
    expect(release_doc).to include("Ransack")
    expect(release_doc).to include("table metadata")

    expect(evidence_doc).to include(
      "Use this guide when a release or focused PR needs sample app evidence for token search",
      "It does not define new runtime behavior, new release gates, or a broader sample app matrix",
      "token parsing, query execution, authorization",
      "table persistence"
    )
  end
end
