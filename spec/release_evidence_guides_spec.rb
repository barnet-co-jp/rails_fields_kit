# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "release evidence guides" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:sample_app_checklist) { File.read(File.expand_path("../doc/sample_app_checklist.md", __dir__)) }
  let(:sample_app_results) { File.read(File.expand_path("../doc/sample_app_results.md", __dir__)) }
  let(:release_guide) { File.read(File.expand_path("../doc/release.md", __dir__)) }
  let(:setup_doctor_machine_readable) { File.read(File.expand_path("../doc/setup_doctor_machine_readable.md", __dir__)) }
  let(:table_metadata_collection_evidence) { File.read(File.expand_path("../doc/table_metadata_collection_evidence.md", __dir__)) }

  it "keeps TableMetadata collection evidence packaged and routed without owning table behavior" do
    expect(specification.files).to include("doc/table_metadata_collection_evidence.md")

    expect(sample_app_checklist).to include(
      "table_metadata_collection_evidence.md",
      "TableMetadata collection source shapes",
      "hash-like, table-like, and explicit false checks"
    )

    expect(sample_app_results).to include(
      "Token and table metadata",
      "Table metadata checks",
      "query execution or persistence stayed in the host app / table integration"
    )

    expect(table_metadata_collection_evidence).to include(
      "evidence guide only",
      "Hash column",
      "Hash-like column",
      "Table-like source",
      "Explicit `false`",
      "query execution, authorization, persistence, pagination, and user-facing result copy"
    )
  end

  it "keeps SetupDoctor JSON evidence packaged and bounded to representative release checks" do
    expect(specification.files).to include("doc/setup_doctor_machine_readable.md")

    expect(release_guide).to include(
      "doc/setup_doctor_machine_readable.md",
      "format: :json",
      "representative JSON output usage",
      "CLI `--json` contract",
      "universal host-app CI pass/fail policy"
    )

    expect(setup_doctor_machine_readable).to include(
      "read-only setup checks as JSON",
      "summary[\"missing\"]",
      "manual checks were reviewed as host-app advisory items",
      "sample_app_results.md",
      "PR comment for narrow docs or setup-doctor evidence",
      "formal schema publication",
      "universal host-app CI pass/fail policy"
    )
  end
end
