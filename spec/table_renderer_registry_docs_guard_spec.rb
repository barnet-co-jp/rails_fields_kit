# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TableRenderer registry docs guard" do
  let(:public_api_path) { File.expand_path("../doc/public_api.md", __dir__) }
  let(:public_api) { File.read(public_api_path) }
  let(:table_adapters_path) { File.expand_path("../doc/table_adapters.md", __dir__) }
  let(:table_adapters) { File.read(table_adapters_path) }
  let(:release_evidence_path) { File.expand_path("../doc/table_metadata_release_evidence.md", __dir__) }
  let(:release_evidence) { File.read(release_evidence_path) }

  it "keeps the custom registry separate from built-in factory known types" do
    table_metadata_surface = markdown_section(public_api, "## Table metadata adapters")
    filter_metadata = markdown_section(table_adapters, "## Filter input metadata")
    evidence_checklist = markdown_section(release_evidence, "## Checklist items")

    expect(table_metadata_surface).to include(
      "`RailsFieldsKit::TableRenderer`",
      "Owns the field type registry and custom helper mapping for table integrations",
      "Use [`table_adapters.md`](table_adapters.md) as the source of truth"
    )

    expect(filter_metadata).to include(
      "`known_types` is intentionally limited to the built-in factory family",
      "It does not include custom mappings added with `TableRenderer.register_field_helper`",
      "use `TableRenderer.registered_field_type?` when validation needs to include those custom renderable types"
    )

    expect(evidence_checklist).to include(
      "`RailsFieldsKit::TableFilterInput.known_types` and `RailsFieldsKit::TableCellInput.known_types` remain limited to the built-in factory family",
      "`RailsFieldsKit::TableRenderer.unregister_field_helper` removes a custom-only mapping from the current registry",
      "Unregistering a custom override for a built-in field type restores the built-in default helper"
    )
  end

  it "keeps registry evidence representative instead of redefining table execution ownership" do
    registry_route = markdown_section(release_evidence, "## TableRenderer registry evidence route")

    expect(registry_route).to include(
      "`RailsFieldsKit::TableRenderer.register_field_helper`",
      "`registered_field_types`",
      "`unregister_field_helper`",
      "`reset_field_helpers!`",
      "Exercise one representative custom field type through the documented call-spec path",
      "Do not require every built-in type, every helper method name, or every table integration"
    )

    expect(release_evidence).to include(
      "Query execution, preference persistence, authorization, pagination, visible save/error copy, validation policy, normalization, and final table layout remain host-app or table integration responsibilities"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
