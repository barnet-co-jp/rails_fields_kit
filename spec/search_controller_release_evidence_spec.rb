# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "search controller release evidence docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:guide_path) { File.expand_path("../doc/search_controller_release_evidence.md", __dir__) }
  let(:guide) { File.read(guide_path) }
  let(:controller_helpers_path) { File.expand_path("../doc/controller_helpers.md", __dir__) }
  let(:controller_helpers) { File.read(controller_helpers_path) }

  it "ships the focused search controller evidence guide" do
    expect(specification.files).to include("doc/search_controller_release_evidence.md")
    expect(guide).to include(
      "Use this guide when a release or narrow PR needs representative evidence for `rfk_search_with` endpoint-side policy",
      "record the checked route and result in `doc/sample_app_results.md`",
      "For a narrow docs/spec PR, a PR comment can be enough"
    )
  end

  it "keeps minimum query length evidence scoped to endpoint policy" do
    expect(guide).to include(
      "For `minimum_query_length:`, record one route where the query is shorter than the endpoint minimum",
      "empty options payload that preserves the configured wrapper",
      "FormBuilder `min_length:` remains a browser-side loading hint",
      "Do not treat a browser-side loading hint as evidence that direct endpoint requests are blocked"
    )

    expect(controller_helpers).to include(
      "`minimum_query_length:` endpoint-side minimum query length",
      "FormBuilder's field-level `min_length:` is a browser-side loading hint",
      "`minimum_query_length:` is the server endpoint policy"
    )
  end

  it "keeps match strategy evidence representative instead of turning it into query execution ownership" do
    expect(guide).to include(
      "For `match:`, record the configured strategy and one representative query result",
      "`match: :contains` keeps the default substring search policy",
      "`match: :prefix` confirms prefix-only suggestions",
      "`match: :exact` confirms an exact query boundary",
      "A release does not need to execute all three strategies unless the change under review touches the strategy family itself",
      "should not standardize adapter-specific SQL, case sensitivity, token parsing, search ranking, pagination, authorization, or query execution"
    )
  end
end
