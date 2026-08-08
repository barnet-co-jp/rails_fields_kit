# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table metadata release evidence docs" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:guide) { read_repo_file("doc/table_metadata_release_evidence.md") }
  let(:release_doc) { read_repo_file("doc/release.md") }
  let(:final_release_checklist) { read_repo_file("doc/final_release_checklist.md") }

  it "keeps the evidence selector packaged and routed without replacing table behavior sources" do
    expect(specification.files).to include("doc/table_metadata_release_evidence.md")

    expect(release_doc).to include(
      "`doc/table_metadata_release_evidence.md` when table metadata rendering, group-level wrappers, or TableRenderer registry checks are part of the release evidence scope",
      "use [`table_metadata_release_evidence.md`](table_metadata_release_evidence.md) to choose representative helper checks",
      "Keep `doc/table_adapters.md` and `doc/table_group_html.md` as the source of truth for behavior and responsibility boundaries"
    )

    expect(final_release_checklist).to include(
      "Review `doc/table_metadata_release_evidence.md` as the representative sample-app or PR-comment selector",
      "keep `doc/table_adapters.md` as the table behavior source of truth and `doc/table_group_html.md` as the group-wrapper source of truth"
    )

    expect(guide).to include(
      "record the actual result in `doc/sample_app_results.md` or the PR comment for the scoped change",
      "Use `doc/table_adapters.md` for table metadata, call-spec, renderer registry, and host-app responsibility boundaries",
      "Use `doc/table_group_html.md` for the direct FormBuilder `group_html:` wrapper boundary",
      "This guide does not define new runtime behavior"
    )
  end

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

  def read_repo_file(path)
    File.read(File.join(root, path))
  end
end
