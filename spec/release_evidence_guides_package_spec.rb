# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "release evidence guide package docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }

  let(:check_box_release_evidence) { read_doc("doc/check_box_release_evidence.md") }
  let(:search_controller_release_evidence) { read_doc("doc/search_controller_release_evidence.md") }

  it "keeps checkbox release evidence packaged without expanding helper ownership" do
    expect(specification.files).to include("doc/check_box_release_evidence.md")

    expect(check_box_release_evidence).to include(
      "sample-app evidence for `rfk_check_box`",
      "single native checkbox wrapper",
      "Rails' standard checkbox contract",
      "hidden unchecked input",
      "custom `checked_value:` and `unchecked_value:`",
      "accessibility: false",
      "radio buttons, collection groups, validation UI, production CSS, and final copy remain out of scope"
    )
  end

  it "keeps search controller release evidence packaged without taking over endpoint policy" do
    expect(specification.files).to include("doc/search_controller_release_evidence.md")

    expect(search_controller_release_evidence).to include(
      "`rfk_search_with` endpoint-side policy",
      "`minimum_query_length:` or `match:`",
      "FormBuilder `min_length:` remains a browser-side loading hint",
      "match: :contains",
      "match: :prefix",
      "match: :exact",
      "authentication, authorization, tenant scoping, adapter-specific SQL, case sensitivity, ranking, pagination, and final query execution policy"
    )
  end

  def read_doc(relative_path)
    File.read(File.expand_path("../#{relative_path}", __dir__))
  end
end
