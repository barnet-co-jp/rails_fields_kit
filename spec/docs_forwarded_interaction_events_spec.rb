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
      "Detail: `{ value, values }`",
      "`rails-fields-kit--tom-select:item-add`",
      "`rails-fields-kit--tom-select:item-remove`",
      "Detail: `{ value, item, values }`",
      "`rails-fields-kit--tom-select:clear`",
      "Detail: `{ values }`"
    )
  end

  it "keeps single-value and multiple-value clear boundaries aligned with the smoke docs" do
    expect(interaction_section).to include(
      "For single-value fields",
      "values: [\"\"]",
      "For multiple-value fields",
      "values: []"
    )

    expect(javascript_section).to include(
      "Tom Select forwarded interaction event payloads",
      "`change` forwards the scalar value plus the normalized `values` array",
      "single-value `clear` wraps Tom Select's scalar cleared value as `values: [\"\"]`",
      "multiple-value `clear` keeps the empty array shape"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
