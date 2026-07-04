# frozen_string_literal: true

require "spec_helper"

RSpec.describe "controller helper docs guard" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:controller_helpers) { File.read(File.join(repo_root, "doc/controller_helpers.md")) }
  let(:field_helpers) { File.read(File.join(repo_root, "doc/field_helpers.md")) }

  it "keeps selected preload ordering policy documented without moving host-app responsibilities" do
    selected_preload_reference = markdown_section(controller_helpers, "## `rfk_find_with`")
    remote_field_helper_reference = markdown_section(field_helpers, "## Remote option options")

    expect(selected_preload_reference).to include(
      "preserve_order: true",
      "incoming selected IDs",
      "skips missing IDs",
      "does not change authorization, scoping, query execution, or Tom Select runtime behavior",
      "Use one of those policies per endpoint when possible"
    )
    expect(remote_field_helper_reference).to include(
      "selected_url:",
      "selected:",
      "selected-option preload URL",
      "selected preload workflow"
    )
  end

  it "keeps fixed query params and create body params in separate request lanes" do
    fixed_params_reference = markdown_section(controller_helpers, "## Fixed request params and scoping")
    create_request_reference = markdown_section(controller_helpers, "### Create request contract")
    remote_field_helper_reference = markdown_section(field_helpers, "## Remote option options")

    expect(fixed_params_reference).to include(
      "query_params:",
      "selected_query_params:",
      "create_params:",
      "URL query lane",
      "fixed JSON fields",
      "not a substitute for server-side tenant scoping or authorization"
    )
    expect(create_request_reference).to include(
      "The JSON body merges fixed `create_params:` values first",
      "`permitted_attributes:` is a strong-params allowlist",
      "separate from `assign:`"
    )
    expect(remote_field_helper_reference).to include(
      "For remote search and selected-option preload, fixed params are URL query params",
      "`create_params:` is separate",
      "create-on-the-fly JSON body"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
