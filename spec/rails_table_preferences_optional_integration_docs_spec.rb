# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Rails Table Preferences optional integration docs" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:table_adapters_doc) { read_repo_file("doc/table_adapters.md") }
  let(:shared_metadata_navigation_doc) { read_repo_file("doc/shared_metadata_navigation.md") }
  let(:roadmap) { read_repo_file("ROADMAP.md") }

  it "keeps the optional integration boundary away from hard dependencies and execution ownership" do
    integration_section = markdown_section(table_adapters_doc, "## Intended integration with Rails Table Preferences")

    expect(integration_section).to include(
      "Rails Table Preferences owns table column state such as visibility, order, width, presets, saved filter state, sort state, and export metadata",
      "Rails Fields Kit owns field metadata and rendering assistance for the controls attached to those columns",
      "The host application owns query execution, params construction, authorization, scoping, pagination, persistence, and user-visible success or error copy",
      "optional metadata bridge",
      "should not require a hard dependency on Rails Table Preferences",
      "should not turn `rfk_table_filters` into a helper-level Ransack DSL"
    )
  end

  it "keeps filter and cell-editor conversion examples as metadata-first candidates" do
    integration_section = markdown_section(table_adapters_doc, "## Intended integration with Rails Table Preferences")

    expect(integration_section).to include(
      "filter: RailsFieldsKit::TableFilterInput.combobox",
      "filter_input: RailsFieldsKit::TableFilterInput.ransack_filter",
      "cell_editor: RailsFieldsKit::TableCellInput.enum_select",
      "cell_editor: RailsFieldsKit::TableCellInput.token_search",
      "RailsFieldsKit::TableMetadata.filters",
      "RailsFieldsKit::TableMetadata.cell_editors",
      "RailsFieldsKit::TableRenderer.filter_call",
      "RailsFieldsKit::TableRenderer.cell_editor_call"
    )
  end

  it "keeps roadmap proposals separate from current public API and follow-up implementation slices" do
    roadmap_section = markdown_section(roadmap, "## Phase 5: Rails Table Preferences integration")

    expect(roadmap_section).to include(
      "This integration should be implemented as an optional layer, not as a hard dependency from the core gem",
      "avoid owning the table preference persistence layer",
      "avoid owning the search execution layer",
      "Future proposal, not current public API",
      "adapter: :ransack"
    )

    expect(shared_metadata_navigation_doc).to include(
      "`rfk_table_filters ..., adapter: :ransack` would be a table rendering convenience surface",
      "It would need to derive from existing table metadata without replacing `TableFilterInput.ransack_filter`",
      "making table preference persistence, query execution, or result navigation Rails Fields Kit responsibilities",
      "Do not land both helper-level shapes in the same first slice"
    )
  end

  def read_repo_file(path)
    File.read(File.join(root, path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##\s)/, 2).first
  end
end
