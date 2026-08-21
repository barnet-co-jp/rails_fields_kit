# frozen_string_literal: true

RSpec.describe "token suggestion blank query policy" do
  class FakeTokenSuggestionPolicyController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json, :rendered_status

    rfk_token_suggestions_with(
      suggestions: [
        "status:open",
        ["Assigned to me", "assignee:me"],
        { token: "priority:high", label: "High priority", description: "Urgent items", badge: "priority" }
      ],
      limit: 2
    )

    rfk_token_suggestions_with(
      action: :strict_tokens,
      suggestions: [
        "status:open",
        "status:closed",
        { token: "assignee:me", label: "Assigned to me", badge: "people" }
      ],
      minimum_query_length: 1,
      wrap: "options"
    )

    rfk_token_suggestions_with(
      action: :custom_tokens,
      query_param: "term",
      suggestions: ->(query) {
        [
          { token: "status:#{query}", label: "Status #{query}", badge: "operator" },
          { token: "assignee:me", label: "Assigned to me", badge: "people" }
        ]
      },
      value_field: "token",
      label_field: "label",
      badge_field: "kind",
      match_fields: %w[token label],
      minimum_query_length: 2,
      wrap: "results"
    )

    def render(json:, status: :ok)
      @rendered_json = json
      @rendered_status = status
    end
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "keeps blank query initial token suggestions by default" do
    controller = FakeTokenSuggestionPolicyController.new
    controller.params = {}

    controller.index

    expect(controller.rendered_status).to eq(:ok)
    expect(controller.rendered_json).to eq([
      { "value" => "status:open", "text" => "status:open" },
      { "value" => "assignee:me", "text" => "Assigned to me" }
    ])
  end

  it "returns a wrapped empty payload when the query is shorter than the token suggestion minimum" do
    controller = FakeTokenSuggestionPolicyController.new
    controller.params = { "q" => "" }

    controller.strict_tokens

    expect(controller.rendered_status).to eq(:ok)
    expect(controller.rendered_json).to eq({ "options" => [] })
  end

  it "preserves existing filtering when the query meets the token suggestion minimum" do
    controller = FakeTokenSuggestionPolicyController.new
    controller.params = { "q" => "closed" }

    controller.strict_tokens

    expect(controller.rendered_json).to eq({
      "options" => [{ "value" => "status:closed", "text" => "status:closed" }]
    })
  end

  it "keeps custom query params, field names, match fields, and wrappers together" do
    controller = FakeTokenSuggestionPolicyController.new
    controller.params = { "term" => "st" }

    controller.custom_tokens

    expect(controller.rendered_json).to eq({
      "results" => [
        { "token" => "status:st", "label" => "Status st", "kind" => "operator", "badge" => "operator" }
      ]
    })
  end
end
