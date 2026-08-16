# frozen_string_literal: true

require "spec_helper"

RSpec.describe "forwarded interaction event docs" do
  let(:events_path) { File.expand_path("../doc/events.md", __dir__) }
  let(:events) { File.read(events_path) }
  let(:development_path) { File.expand_path("../doc/development.md", __dir__) }
  let(:development) { File.read(development_path) }
  let(:interaction_section) { markdown_section(events, "## Interaction forwarding") }
  let(:javascript_section) { markdown_section(development, "## Check JavaScript locally") }

  it "keeps the public forwarded interaction event detail shape documented" do
    expect(interaction_section).to include(
      "`rails-fields-kit--tom-select:change`",
      "Detail: `{ value, values, option, options }`",
      "`rails-fields-kit--tom-select:item-add`",
      "`rails-fields-kit--tom-select:item-remove`",
      "Detail: `{ value, item, values, option, options }`",
      "`rails-fields-kit--tom-select:clear`",
      "Detail: `{ values, options }`"
    )
  end

  it "keeps option metadata and clear boundaries aligned with the smoke docs" do
    expect(interaction_section).to include(
      "The `option` field is the Tom Select option payload for the event value",
      "free text",
      "preserving additional fields returned by remote search, selected preload, create-on-the-fly, or collection-backed select setup",
      "Reflecting business metadata such as price, unit, account, category, or secondary display fields into other controls remains host-app responsibility."
    )

    expect(interaction_section).to include(
      "For single-value fields",
      "values: [\"\"]",
      "options: [null]",
      "For multiple-value fields",
      "values: []",
      "options: []"
    )

    expect(javascript_section).to include(
      "Tom Select forwarded interaction event payloads",
      "`change` forwards the event value plus the normalized `values` array and selected `option` / `options` payload metadata",
      "single-value `clear` wraps Tom Select's scalar cleared value as `values: [\"\"]` and `options: [null]`",
      "multiple-value `clear` keeps the empty array shape for both `values` and `options`"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
