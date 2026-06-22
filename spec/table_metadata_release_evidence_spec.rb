# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table metadata release evidence docs" do
  let(:guide_path) { File.expand_path("../doc/table_metadata_release_evidence.md", __dir__) }
  let(:guide) { File.read(guide_path) }

  it "keeps TableRenderer registry evidence scoped to representative release checks" do
    expect(guide).to include(
      "For TableRenderer registry work, this guide is the release evidence route",
      "one representative registration, introspection, and cleanup check",
      "without turning the public API docs into an exhaustive manual test checklist"
    )

    expect(guide).to include(
      "## TableRenderer registry evidence route",
      "`RailsFieldsKit::TableRenderer.register_field_helper`",
      "`registered_field_types`",
      "`unregister_field_helper`",
      "`reset_field_helpers!`"
    )

    expect(guide).to include(
      "Exercise one representative custom field type through the documented call-spec path",
      "Record whether `registered_field_types` exposes the custom type after registration without exposing helper method names as the evidence contract",
      "Do not require every built-in type, every helper method name, or every table integration to be rechecked"
    )

    expect(guide).to include(
      "Query execution, preference persistence, authorization, pagination, visible save/error copy, validation policy, normalization, and final table layout remain host-app or table integration responsibilities"
    )
  end
end
