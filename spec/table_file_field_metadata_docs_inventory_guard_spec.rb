# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "table file field metadata docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:table_adapters) { read_doc("doc/table_adapters.md") }
  let(:table_file_field_metadata) { read_doc("doc/table_file_field_metadata.md") }

  it "keeps table file field metadata docs packaged and scoped" do
    expect(specification.files).to include("doc/table_file_field_metadata.md")
    expect(table_adapters).to include(
      "[`table_file_field_metadata.md`](table_file_field_metadata.md)",
      "`TableCellInput.file_field` cell-editor-only",
      "does not add `TableFilterInput.file_field`",
      "upload execution, query semantics, table persistence, or production styling"
    )
    expect(table_file_field_metadata).to include(
      "`RailsFieldsKit::TableCellInput.file_field` describes a cell-editor file input",
      "`TableRenderer` maps `file_field` metadata to `rfk_file_field`",
      "File field metadata is intentionally cell-editor-only in this slice",
      "`TableFilterInput.file_field` is not a built-in factory",
      "multipart form setup",
      "Active Storage direct upload JavaScript",
      "preview UI",
      "table persistence, query execution, authorization, and production CSS"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
