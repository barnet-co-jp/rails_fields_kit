# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "enum_select focused docs inventory" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:public_api) { File.read(File.expand_path("../doc/public_api.md", __dir__)) }
  let(:enum_select_doc) { File.read(File.expand_path("../doc/enum_select.md", __dir__)) }

  it "keeps the focused enum_select guide packaged and discoverable from public API docs" do
    expect(specification.files).to include("doc/enum_select.md")
    expect(public_api).to include("[`enum_select.md`](enum_select.md)")
    expect(public_api).to include("`rfk_enum_select` explicit `enum:` hash boundary")
  end

  it "keeps the representative enum_select ownership boundary readable" do
    expect(enum_select_doc).to include(
      "explicit `enum:` hash",
      "The hash keys are the submitted option values",
      "Labels still come from the model class",
      "`option_html:`",
      "`data-rails-fields-kit--tom-select-kind-value=\"enum_select\"`",
      "read-only rendered contract signal"
    )

    expect(enum_select_doc).to include(
      "does not add an arbitrary label/value DSL",
      "remote enum lookup",
      "authorization",
      "query execution",
      "table metadata adapter behavior stay outside `rfk_enum_select`"
    )
  end
end
