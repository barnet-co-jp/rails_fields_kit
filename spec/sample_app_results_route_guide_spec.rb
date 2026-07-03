# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "sample app results route guide" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:development_doc) { read_doc("doc/development.md") }
  let(:route_guide) { read_doc("doc/sample_app_results_route_guide.md") }
  let(:sample_app_results) { read_doc("doc/sample_app_results.md") }

  it "keeps the route guide packaged as a narrow PR evidence companion" do
    expect(specification.files).to include("doc/sample_app_results_route_guide.md")

    expect(development_doc).to include(
      "doc/sample_app_results_route_guide.md",
      "narrow PR evidence route guide",
      "not a release gate, sample app execution requirement, CI job, or browser visual approval substitute"
    )

    expect(route_guide).to include(
      "Use this companion note when a release or PR needs manual evidence",
      "it does not add a release gate, change runtime behavior, or replace the full checklist",
      "Record in PR comment",
      "CI success as visual approval",
      "SOURCE REVIEW ONLY",
      "DEFERRED",
      "Do not use `PASS` for GitHub Actions success, source review, static diff review, or a successful package build"
    )

    expect(sample_app_results).to include(
      "`doc/sample_app_results_route_guide.md`",
      "when to update this evidence log",
      "without treating CI success or source review as browser approval"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
