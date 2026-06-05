# frozen_string_literal: true

require "spec_helper"

RSpec.describe "suggestion payload documentation drift" do
  let(:token_suggestions_doc) { File.read(File.expand_path("../../doc/token_suggestions.md", __dir__)) }
  let(:ransack_suggestions_doc) { File.read(File.expand_path("../../doc/ransack_suggestions.md", __dir__)) }

  it "keeps TokenSuggestions output fields documented without freezing the full prose" do
    default_suggestion = RailsFieldsKit::TokenSuggestions.build(fields: [:status]).first
    custom_suggestion = RailsFieldsKit::TokenSuggestions.build(
      fields: [:status],
      value_field: "token",
      label_field: "label",
      description_field: "help",
      badge_field: "kind"
    ).first

    expect(default_suggestion.keys).to contain_exactly("value", "text", "description", "badge")
    expect(custom_suggestion.keys).to contain_exactly("token", "label", "help", "kind")

    expect(token_suggestions_doc).to include(
      "value field:",
      "label field:",
      "description field:",
      "badge field:",
      'value_field: "token"',
      'label_field: "label"',
      'description_field: "help"',
      'badge_field: "kind"'
    )
  end

  it "keeps RansackSuggestions metadata keys documented without requiring Ransack" do
    suggestions = RailsFieldsKit::RansackSuggestions.build(
      fields: {
        status: {
          predicate: :status_eq,
          values: ["open"]
        }
      },
      operators: []
    )
    field_suggestion = suggestions.detect { |suggestion| suggestion["value"] == "status:" }
    value_suggestion = suggestions.detect { |suggestion| suggestion["value"] == "status:open" }

    expect(field_suggestion).to include(
      "ransack_predicate" => "status_eq",
      "ransack_field" => "status"
    )
    expect(value_suggestion).to include(
      "ransack_predicate" => "status_eq",
      "ransack_field" => "status",
      "ransack_value" => "open"
    )

    expect(ransack_suggestions_doc).to include(
      "does not require the `ransack` gem",
      "ransack_predicate",
      "ransack_field",
      "ransack_value",
      "predicate",
      "ransack",
      "param"
    )
  end
end
