# frozen_string_literal: true

require "spec_helper"

RSpec.describe "shared metadata navigation docs" do
  let(:navigation_path) { File.expand_path("../doc/shared_metadata_navigation.md", __dir__) }
  let(:navigation) { File.read(navigation_path) }

  it "keeps the host-app metadata example pointed at current public builders" do
    current_api_line = navigation.lines.find { |line| line.start_with?("- Current public API:") }
    host_pattern_line = navigation.lines.find { |line| line.start_with?("- Host-app pattern:") }
    future_proposal_line = navigation.lines.find { |line| line.start_with?("- Future proposal:") }
    non_goals = markdown_section(navigation, "## Non-goals")

    expect(current_api_line).to include(
      "TokenSuggestions.build",
      "RansackSuggestions.build",
      "TableFilterInput.ransack_filter"
    )
    expect(current_api_line).not_to include("registry API", "adapter DSL", "query execution")

    expect(host_pattern_line).to include(
      "app-owned metadata source",
      "passing derived hashes into the current builders",
      "Rails Fields Kit receives ordinary arguments; it does not own the source registry."
    )

    expect(future_proposal_line).to include(
      "helper-level adapter DSLs",
      "Rails Fields Kit-owned field/operator registry",
      "public API docs"
    )

    expect(non_goals).to include(
      "does not add a registry API",
      "token parser",
      "Ransack execution path"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
