# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "focused docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:table_file_field_metadata) { read_doc("doc/table_file_field_metadata.md") }
  let(:visual_reference_browser_evidence) { read_doc("doc/visual_reference_browser_evidence.md") }
  let(:sample_app_results_route_guide) { read_doc("doc/sample_app_results_route_guide.md") }

  it "keeps table file field metadata packaged and routed without promoting upload ownership" do
    expect(specification.files).to include("doc/table_file_field_metadata.md")
    expect(public_api).to include(
      "[`table_file_field_metadata.md`](table_file_field_metadata.md)",
      "file cell-editor metadata",
      "file upload execution"
    )
    expect(table_file_field_metadata).to include(
      "RailsFieldsKit::TableCellInput.file_field",
      "TableRenderer` maps `file_field` metadata to `rfk_file_field`",
      "cell-editor-only",
      "`TableFilterInput.file_field` is not a built-in factory",
      "The host application owns multipart form setup, Active Storage direct upload JavaScript, preview UI, upload progress UI, file validation policy, storage configuration, virus scanning, table persistence, query execution, authorization, and production CSS"
    )
  end

  it "keeps browser evidence runbook packaged without turning source review or CI into visual approval" do
    expect(specification.files).to include("doc/visual_reference_browser_evidence.md")
    expect(readme).to include(
      "[`doc/visual_reference_browser_evidence.md`](doc/visual_reference_browser_evidence.md)",
      "manual desktop/narrow browser-capable evidence beyond CI or source review"
    )
    expect(sample_app_results_route_guide).to include(
      "Source-only or connector-only visual review",
      "source review / browser pass / CI / docs link review",
      "Do not use `PASS` for GitHub Actions success, source review, static diff review, or a successful package build"
    )
    expect(visual_reference_browser_evidence).to include(
      "manual reviewer aid, not CI automation, screenshot approval, or a merge bot",
      "Desktop: about `1280x900`",
      "Narrow: about `390x844`",
      "CI success and source review are useful context, but they are not browser visual approval",
      "Do not mark a visual reference as browser-approved unless the desktop and narrow browser review actually ran"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
