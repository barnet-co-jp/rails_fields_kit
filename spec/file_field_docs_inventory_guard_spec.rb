# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "file field docs inventory guard" do
  let(:rfk_file_field_docs_repo_root) { File.expand_path("..", __dir__) }
  let(:rfk_file_field_docs_specification) do
    Gem::Specification.load(File.join(rfk_file_field_docs_repo_root, "rails_fields_kit.gemspec"))
  end
  let(:rfk_file_field_docs_readme) { rfk_file_field_docs_read("README.md") }
  let(:rfk_file_field_docs_public_api) { rfk_file_field_docs_read("doc/public_api.md") }
  let(:rfk_file_field_docs_product_profile) { rfk_file_field_docs_read("Product Profile.md") }
  let(:rfk_file_field_docs_guide) { rfk_file_field_docs_read("doc/file_field.md") }

  it "keeps file field focused docs packaged and routed from native wrapper docs" do
    form_builder_helpers = rfk_file_field_docs_markdown_section(rfk_file_field_docs_public_api, "## FormBuilder helpers")
    readme_helper_route = rfk_file_field_docs_markdown_section(rfk_file_field_docs_readme, "## Choosing a helper")
    helper_boundary_docs = rfk_file_field_docs_markdown_section(rfk_file_field_docs_product_profile, "### Helper boundary docs")

    expect(rfk_file_field_docs_specification.files).to include("doc/file_field.md")
    expect(form_builder_helpers).to include(
      "`rfk_file_field`",
      "[`file_field.md`](file_field.md)",
      "file-upload ownership non-goals"
    )
    expect(readme_helper_route).to include(
      "password, checkbox, file, or range controls",
      "[`doc/file_field.md`](doc/file_field.md)"
    )
    expect(helper_boundary_docs).to include(
      "`doc/file_field.md`",
      "focused `rfk_file_field` native wrapper boundary",
      "file-upload ownership non-goals"
    )
    expect(rfk_file_field_docs_guide).to include(
      "`rfk_file_field` renders Rails' native `file_field` helper",
      "accept:",
      "multiple:",
      "direct_upload:",
      "multipart form setup",
      "Active Storage direct upload behavior",
      "file preview UI",
      "upload progress UI",
      "file size and MIME validation",
      "storage configuration",
      "virus scanning",
      "Rails Fields Kit does not add upload JavaScript or replace Rails' file upload workflow"
    )
  end

  def rfk_file_field_docs_read(relative_path)
    File.read(File.join(rfk_file_field_docs_repo_root, relative_path))
  end

  def rfk_file_field_docs_markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
