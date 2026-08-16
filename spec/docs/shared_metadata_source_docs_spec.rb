# frozen_string_literal: true

require "spec_helper"
require "pathname"

RSpec.describe "shared metadata source documentation" do
  repository_root = Pathname.new(File.expand_path("../..", __dir__))
  documentation_paths = {
    token: repository_root.join("doc/token_suggestions.md"),
    ransack: repository_root.join("doc/ransack_suggestions.md"),
    table: repository_root.join("doc/table_adapters.md")
  }

  def shared_metadata_section(path)
    path.read.match(/^## Shared metadata source pattern\n(?<section>.*?)(?=\n## |\z)/m).then do |match|
      expect(match).not_to be_nil, "#{path} is missing the shared metadata source section"

      match[:section]
    end
  end

  it "keeps the representative field source aligned across token, Ransack, and table docs" do
    sections = documentation_paths.transform_values { |path| shared_metadata_section(path) }

    shared_signals = [
      "ORDER_SEARCH_FIELDS",
      "status",
      "assignee",
      "ransack_predicate",
      ":status_eq",
      ":assignee_name_cont",
      "%w[open closed]"
    ]

    sections.each do |name, section|
      missing_signals = shared_signals.reject { |signal| section.include?(signal) }

      expect(missing_signals).to be_empty,
        "#{name} shared metadata docs are missing: #{missing_signals.join(", ")}"
    end
  end

  it "keeps each current public surface tied to the shared host-app source" do
    token_section = shared_metadata_section(documentation_paths.fetch(:token))
    ransack_section = shared_metadata_section(documentation_paths.fetch(:ransack))
    table_section = shared_metadata_section(documentation_paths.fetch(:table))

    expect(token_section).to include("RailsFieldsKit::TokenSuggestions.build")
    expect(token_section).to include("config.slice(:label, :values)")

    expect(ransack_section).to include("ransack_fields = ORDER_SEARCH_FIELDS.transform_values")
    expect(ransack_section).to include("RailsFieldsKit::RansackSuggestions.build(fields: ransack_fields)")

    expect(table_section).to include("ransack_fields = ORDER_SEARCH_FIELDS.transform_values")
    expect(table_section).to include("RailsFieldsKit::TableFilterInput.ransack_filter")
    expect(table_section).to include("fields: ransack_fields")
  end

  it "keeps the current docs pattern separate from a Rails Fields Kit registry contract" do
    sections = documentation_paths.transform_values { |path| shared_metadata_section(path) }

    sections.each do |name, section|
      expect(section).to match(/host app/i), "#{name} section should keep ownership with the host app"
      expect(section).to match(/registry/i), "#{name} section should state the registry boundary"
    end
  end
end
