# frozen_string_literal: true

require "spec_helper"

RSpec.describe "shared metadata navigation docs" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:readme) { File.read(File.join(repo_root, "README.md")) }
  let(:public_api) { File.read(File.join(repo_root, "doc/public_api.md")) }
  let(:navigation) { File.read(File.join(repo_root, "doc/shared_metadata_navigation.md")) }

  it "keeps README and public API docs pointed at the shared metadata boundary map" do
    expect(readme).to include(
      "[`doc/shared_metadata_navigation.md`](doc/shared_metadata_navigation.md)",
      "Understand shared token, Ransack, and table metadata boundaries"
    )

    expect(public_api).to include(
      "[`shared_metadata_navigation.md`](shared_metadata_navigation.md)",
      "token suggestions, Ransack-oriented suggestions, table metadata, and roadmap registry proposals"
    )
  end

  it "keeps the recommended reading order tied to current docs" do
    expect(navigation).to include(
      "[`token_suggestions.md`](token_suggestions.md#shared-metadata-source-pattern)",
      "[`ransack_suggestions.md`](ransack_suggestions.md#shared-metadata-source-pattern)",
      "[`table_adapters.md`](table_adapters.md#token-search-filter-metadata)",
      "[`public_api.md`](public_api.md)",
      "[`../ROADMAP.md`](../ROADMAP.md)"
    )
  end

  it "keeps current public API, host-app-owned source, and future proposal boundaries visible" do
    roadmap = File.read(File.join(repo_root, "ROADMAP.md"))

    expect(navigation).to include(
      "Current public API: `TokenSuggestions.build`, `RansackSuggestions.build`, `TableFilterInput.ransack_filter`",
      "Host-app pattern: keeping one app-owned metadata source",
      "Rails Fields Kit receives ordinary arguments; it does not own the source registry",
      "Future proposal: helper-level adapter DSLs or a Rails Fields Kit-owned field/operator registry",
      "There is no Rails Fields Kit-owned field/operator registry, helper-level Ransack adapter DSL, or query execution path in the current 0.1.x public API"
    )

    expect(roadmap).to include(
      "[`doc/shared_metadata_navigation.md`](doc/shared_metadata_navigation.md)",
      "separate current public API, host-app metadata patterns, and future registry or adapter proposals",
      "The smallest useful slice is a docs/proposal pattern for a host app owned metadata source",
      "This is not a current public registry API",
      "A future Ruby registry object should be split into its own feature issue"
    )
  end

  it "keeps execution and authorization responsibilities outside Rails Fields Kit" do
    expect(navigation).to include(
      "The host application still owns current-user filtering, submitted token parsing, `params[:q]` construction, authorization, Active Record relation construction, Ransack execution, pagination, and user-visible feedback",
      "query parsing, `params[:q]` construction, Ransack execution, authorization, relation construction, pagination, and user-visible feedback in the host app boundary"
    )
  end
end
