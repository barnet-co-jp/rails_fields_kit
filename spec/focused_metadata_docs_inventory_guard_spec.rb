# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "focused metadata docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:ransack_suggestions) { read_doc("doc/ransack_suggestions.md") }
  let(:table_group_html) { read_doc("doc/table_group_html.md") }
  let(:sample_app_results_route_guide) { read_doc("doc/sample_app_results_route_guide.md") }

  it "keeps Ransack suggestion docs packaged and routed without taking over query execution" do
    expect(specification.files).to include("doc/ransack_suggestions.md")
    expect(readme).to include(
      "[`doc/ransack_suggestions.md`](doc/ransack_suggestions.md)",
      "token suggestion payloads"
    )
    expect(public_api).to include(
      "[`ransack_suggestions.md`](ransack_suggestions.md)",
      "RailsFieldsKit::RansackSuggestions.build"
    )
    expect(ransack_suggestions).to include(
      "RailsFieldsKit::RansackSuggestions.build",
      "This helper does not require the `ransack` gem and does not call `Model.ransack`",
      "authorization, scoping, and result pagination",
      "Rails Fields Kit intentionally stops at suggestion metadata",
      "This keeps Ransack optional and avoids making Rails Fields Kit a query engine"
    )
  end

  it "keeps table group HTML docs packaged and routed without promoting semantic group ownership" do
    expect(specification.files).to include("doc/table_group_html.md")
    expect(readme).to include(
      "[`doc/table_group_html.md`](doc/table_group_html.md)",
      "optional group-level wrapper attributes"
    )
    expect(public_api).to include(
      "[`table_group_html.md`](table_group_html.md)",
      "group_html:",
      "does not make Rails Fields Kit own table layout, query execution, persistence, or semantic `fieldset` / `legend` generation"
    )
    expect(table_group_html).to include(
      "`group_html:` is intentionally separate from field-level `wrapper_html:`",
      "It adds attributes to one outer `<div>` around the joined batch output",
      "Semantic wrappers such as `fieldset` and `legend` belong to the host app",
      "Rails Fields Kit still does not own table layout, query execution, persistence, authorization, pagination, semantic group naming"
    )
  end

  it "keeps sample app results routing docs packaged without turning scoped evidence into a release gate" do
    expect(specification.files).to include("doc/sample_app_results_route_guide.md")
    expect(readme).to include(
      "[`doc/sample_app_results_route_guide.md`](doc/sample_app_results_route_guide.md)",
      "choosing whether narrow PR evidence belongs in the full sample-app evidence log or a scoped PR comment"
    )
    expect(sample_app_results_route_guide).to include(
      "It is a scanability aid for choosing the right recording lane; it does not add a release gate, change runtime behavior, or replace the full checklist",
      "Release candidate or release PR",
      "Narrow static visual reference PR",
      "Source-only or connector-only visual review",
      "SOURCE REVIEW ONLY",
      "DEFERRED",
      "Do not use `PASS` for GitHub Actions success, source review, static diff review, or a successful package build"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
