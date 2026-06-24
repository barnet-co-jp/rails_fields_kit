# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table group HTML docs" do
  let(:table_group_html) { File.read(File.expand_path("../../doc/table_group_html.md", __dir__)) }
  let(:public_api) { File.read(File.expand_path("../../doc/public_api.md", __dir__)) }

  it "keeps group_html separate from semantic fieldset ownership" do
    expect(table_group_html).to include(
      "`group_html:` is intentionally separate from field-level `wrapper_html:`",
      "Rails Fields Kit-owned `<div>` attribute pass-through",
      "not a `fieldset`, `legend`, table layout component, or accessibility policy object",
      "Group-level hint text, group-level error copy, and any `aria-describedby` relationship for a semantic group also belong to the host app today"
    )
  end

  it "keeps future semantic wrapper work out of the current public API" do
    future_boundary = table_group_html.split("## Future semantic wrapper proposal boundary", 2).last

    expect(future_boundary).to include(
      "separate public surface from `group_html:`",
      "Do not reinterpret the current `group_html:` option as a `fieldset` builder",
      "Until that separate surface lands and is listed in `doc/public_api.md`, host apps should keep semantic grouping markup around the Rails Fields Kit output"
    )

    expect(public_api).not_to include("legend:")
    expect(public_api).not_to include("group_hint:")
    expect(public_api).not_to include("group_error:")
  end
end
