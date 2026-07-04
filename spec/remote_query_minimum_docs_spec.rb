# frozen_string_literal: true

require "spec_helper"

RSpec.describe "remote query minimum documentation" do
  let(:root_path) { File.expand_path("..", __dir__) }
  let(:controller_helpers) { File.read(File.join(root_path, "doc/controller_helpers.md")) }
  let(:field_helpers) { File.read(File.join(root_path, "doc/field_helpers.md")) }

  it "keeps endpoint and client query minimum boundaries aligned" do
    blank_query_policy = markdown_section(controller_helpers, "### Blank query policy")
    combobox_section = markdown_section(field_helpers, "### `rfk_combobox`")

    expect(blank_query_policy).to include(
      "`minimum_query_length:`",
      "endpoint itself should return no options until the incoming query is long enough",
      "empty options payload",
      "preserves the configured `wrap:` shape",
      "It does not change authorization, tenant scoping, query parsing, Ransack integration, or Tom Select request lifecycle behavior",
      "FormBuilder's field-level `min_length:` is a browser-side loading hint",
      "`minimum_query_length:` is the server endpoint policy for direct requests, custom Tom Select configs",
      "Use both when the UI and endpoint should enforce the same minimum"
    )

    expect(combobox_section).to include(
      "`min_length:` is a client-side load gate before the request is made",
      "it does not decide what the server should return for an allowed blank query",
      "Use [`controller_helpers.md#blank-query-policy`](controller_helpers.md#blank-query-policy)",
      "endpoint-side `minimum_query_length:` policy"
    )
  end

  it "keeps open-on-focus preload examples tied to host-owned blank query policy" do
    blank_query_policy = markdown_section(controller_helpers, "### Blank query policy")

    expect(blank_query_policy).to include(
      "Choose the blank-query behavior deliberately",
      "Allow a scoped initial option list",
      "Block empty or too-short server requests",
      "open_on_focus: true",
      "preload: true",
      "keep both sides permissive and rely on the host app's trusted scope and limit",
      "scope: -> { current_account.customers.active }",
      "limit: 10",
      "min_length: 2",
      "minimum_query_length: 2",
      "The host app remains responsible for authorization, tenant scoping, query parsing, search execution, and deciding whether blank queries should be allowed for each endpoint."
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?#?\s)/, 2).first
  end
end
