# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "release evidence route guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:public_api) { read_repo_file("doc/public_api.md") }
  let(:sample_app_results) { read_repo_file("doc/sample_app_results.md") }
  let(:final_release_checklist) { read_repo_file("doc/final_release_checklist.md") }
  let(:package_root_helper_release_evidence) { read_repo_file("doc/package_root_helper_release_evidence.md") }
  let(:typescript_declaration_release_evidence) { read_repo_file("doc/typescript_declaration_release_evidence.md") }

  it "keeps package-root request/config reader evidence routed without becoming a full helper inventory" do
    expect(specification.files).to include(
      "doc/package_root_helper_release_evidence.md",
      "doc/sample_app_results.md",
      "doc/final_release_checklist.md"
    )

    expect(public_api).to include(
      "tomSelectRequestContract(element)",
      "readRenderedSelectedPreloadConfig(element)",
      "readRenderedTomSelectInteractionConfig(element)",
      "readRenderedOptionPayloadMapping(element)",
      "readRenderedTableFilterMetadata(element)",
      "Keep the package-root table in this document as the helper inventory source of truth"
    )

    expect(package_root_helper_release_evidence).to include(
      "Use `doc/public_api.md#javascript-exports` as the source of truth for the current package-root helper list",
      "For each release or narrow PR, choose only the package-root helper lanes that are in scope for that change",
      "request execution, visible copy, locale policy, mutation, validation, and retry behavior remain outside the helper evidence lane",
      "## Selected preload config reader",
      "## Tom Select interaction config reader",
      "## Option payload mapping reader",
      "## Table filter metadata reader"
    )

    expect(sample_app_results).to include(
      "Package-root helper lanes checked:",
      "Choose helper names from `doc/public_api.md#javascript-exports`",
      "use `doc/package_root_helper_release_evidence.md` for the representative lane guidance",
      "Do not mirror the full helper family here when a helper is unrelated to the change under review"
    )

    expect(final_release_checklist).to include(
      "readRenderedSelectedPreloadConfig(element)` resolves from `rails_fields_kit` as one representative request/config reader lane",
      "with related current helpers such as `tomSelectRequestContract(element)` or `readRenderedTomSelectInteractionConfig(element)` checked through their documented return shapes when release-scoped",
      "readRenderedTableFilterMetadata(element)` checked through their documented return shapes when release-scoped",
      "without moving request execution, endpoint authorization, selected-preload fallback UI, selector validation, modal / portal layout, or production CSS into the package"
    )
  end

  it "keeps TypeScript declaration evidence discoverable as package metadata, not runtime API" do
    expect(specification.files).to include("doc/typescript_declaration_release_evidence.md")

    expect(public_api).to include(
      "`package.json` also publishes TypeScript declaration metadata",
      "Use [`typescript_declaration_release_evidence.md`](typescript_declaration_release_evidence.md) when declaration visibility is in release or PR evidence scope",
      "they do not add a separate runtime API, expose Tom Select internals, or define a host-app `tsconfig` policy"
    )

    expect(typescript_declaration_release_evidence).to include(
      "package metadata and editor-assistance lane",
      "does not define a new runtime API",
      "require a host app to use TypeScript",
      "set a host-app `tsconfig` policy",
      "Runtime JavaScript exports: [`public_api.md#javascript-exports`](public_api.md#javascript-exports)",
      "Declaration files: `app/javascript/rails_fields_kit/*.d.ts`",
      "Evidence notes distinguish declaration metadata from runtime import behavior and host-app TypeScript configuration",
      "Declaration visibility evidence does not replace JavaScript runtime import checks"
    )
  end

  def read_repo_file(path)
    File.read(File.join(root, path))
  end
end
