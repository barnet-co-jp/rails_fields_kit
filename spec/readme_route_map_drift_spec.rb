# frozen_string_literal: true

require "spec_helper"

RSpec.describe "README route map drift guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:readme) { read_doc("README.md") }
  let(:public_api) { read_doc("doc/public_api.md") }

  it "keeps the first field quickstart as an endpoint-free rfk_select setup route" do
    quickstart = markdown_section(readme, "## First field quickstart")

    expect(quickstart).to include(
      "try the first field with a server-rendered collection before adding remote endpoints",
      "f.rfk_select :customer_id",
      "collection: @customers",
      "ordinary Rails select",
      "Move to `rfk_combobox` only when the host app needs remote search, selected preload, or create-on-the-fly behavior",
      "the host app still owns those endpoints, authorization, scoping, and any result execution"
    )
  end

  it "keeps the helper chooser as a route map instead of the exact helper inventory" do
    chooser = markdown_section(readme, "## Choosing a helper")

    expect(chooser).to include(
      "keep the exact helper inventory in [`doc/public_api.md`](doc/public_api.md#formbuilder-helpers)",
      "host app still parses and executes the query",
      "keep query execution, persistence, authorization, and renderer policy in the host app or table integration",
      "Rails Fields Kit does not currently provide collection group helpers",
      "does not currently provide `rfk_masked_field`, `rfk_slug_field`, or `rfk_datalist_field`",
      "do not treat `rfk_mention_field` as part of the current public API"
    )

    expect(public_api).to include(
      "Use the sections below for the exact public names",
      "this file is the compact public API index",
      "Proposal or open-PR helper names are not current public API until they are merged and listed in the table above"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##\s)/, 2).first
  end
end
