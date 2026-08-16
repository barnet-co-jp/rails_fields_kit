# frozen_string_literal: true

RSpec.describe "token suggestion query matching" do
  class TokenSuggestionMatchingController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_token_suggestions_with(
      suggestions: ->(_query) {
        RailsFieldsKit::TokenSuggestions.build(
          operators: ["OR"],
          fields: {
            status: { label: "Status", description: "Workflow state", values: ["open"] }
          },
          saved_searches: [
            { token: "saved:mine", label: "Mine", description: "Owned queue", badge: "saved", scope: "personal" }
          ]
        ) + [
          { value: "assignee:me", text: "Assigned to me", description: "People filter", badge: "field", source: "team-metadata" }
        ]
      },
      limit: nil
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  class MatchFieldTokenSuggestionMatchingController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_token_suggestions_with(
      suggestions: ->(_query) {
        RailsFieldsKit::TokenSuggestions.build(
          fields: {
            status: { label: "Status", description: "Workflow state", values: ["open"] }
          },
          saved_searches: [
            { token: "saved:mine", label: "Mine", description: "Owned queue", badge: "saved", scope: "personal" }
          ]
        ) + [
          { value: "assignee:me", text: "Assigned to me", description: "People filter", badge: "field", source: "team-metadata" }
        ]
      },
      match_fields: %w[value text],
      limit: nil
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  class CustomFieldTokenSuggestionMatchingController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_token_suggestions_with(
      action: :tokens,
      query_param: "term",
      suggestions: [
        { token: "AND", label: "And", help: "Boolean join", kind: "operator" },
        { token: "priority:high", label: "Priority High", help: "Urgency field", kind: "value" },
        { token: "saved:weekly", label: "Weekly", help: "Weekly saved queue", kind: "saved-search" },
        { token: "report:stale", label: "Stale report", help: "Analytics review", kind: "report", owner: "analytics" }
      ],
      value_field: "token",
      label_field: "label",
      description_field: "help",
      badge_field: "kind",
      limit: nil
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  class CustomMatchFieldTokenSuggestionMatchingController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_token_suggestions_with(
      action: :tokens,
      query_param: "term",
      suggestions: [
        { token: "AND", label: "And", help: "Boolean join", kind: "operator" },
        { token: "priority:high", label: "Priority High", help: "Urgency field", kind: "value" },
        { token: "saved:weekly", label: "Weekly", help: "Weekly saved queue", kind: "saved-search" },
        { token: "report:stale", label: "Stale report", help: "Analytics review", kind: "report", owner: "analytics" }
      ],
      value_field: "token",
      label_field: "label",
      description_field: "help",
      badge_field: "kind",
      match_fields: %w[token label missing],
      limit: nil
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  def default_matches_for(query)
    controller = TokenSuggestionMatchingController.new
    controller.params = { "q" => query }
    controller.index
    controller.rendered_json
  end

  def match_field_matches_for(query)
    controller = MatchFieldTokenSuggestionMatchingController.new
    controller.params = { "q" => query }
    controller.index
    controller.rendered_json
  end

  def custom_matches_for(query)
    controller = CustomFieldTokenSuggestionMatchingController.new
    controller.params = { "term" => query }
    controller.tokens
    controller.rendered_json
  end

  def custom_match_field_matches_for(query)
    controller = CustomMatchFieldTokenSuggestionMatchingController.new
    controller.params = { "term" => query }
    controller.tokens
    controller.rendered_json
  end

  it "matches default token suggestions against value and label values" do
    expect(default_matches_for("status:open")).to contain_exactly(
      { "value" => "status:open", "text" => "Status Open", "description" => "Status value", "badge" => "value" }
    )

    expect(default_matches_for("Assigned")).to contain_exactly(
      { "value" => "assignee:me", "text" => "Assigned to me", "description" => "People filter", "badge" => "field", "source" => "team-metadata" }
    )
  end

  it "matches default token suggestions against description, badge, and extra metadata values" do
    expect(default_matches_for("Owned")).to contain_exactly(
      { "value" => "saved:mine", "text" => "Mine", "description" => "Owned queue", "badge" => "saved", "label" => "Mine", "scope" => "personal" }
    )

    expect(default_matches_for("saved")).to contain_exactly(
      { "value" => "saved:mine", "text" => "Mine", "description" => "Owned queue", "badge" => "saved", "label" => "Mine", "scope" => "personal" }
    )

    expect(default_matches_for("team-metadata")).to contain_exactly(
      { "value" => "assignee:me", "text" => "Assigned to me", "description" => "People filter", "badge" => "field", "source" => "team-metadata" }
    )
  end

  it "limits matching to configured default rendered fields" do
    expect(match_field_matches_for("Owned")).to eq([])
    expect(match_field_matches_for("team-metadata")).to eq([])

    expect(match_field_matches_for("saved:mine")).to contain_exactly(
      { "value" => "saved:mine", "text" => "Mine", "description" => "Owned queue", "badge" => "saved", "label" => "Mine", "scope" => "personal" }
    )

    expect(match_field_matches_for("Mine")).to contain_exactly(
      { "value" => "saved:mine", "text" => "Mine", "description" => "Owned queue", "badge" => "saved", "label" => "Mine", "scope" => "personal" }
    )
  end

  it "keeps empty query matching all suggestions when match fields are configured" do
    expect(match_field_matches_for("").size).to eq(4)
  end

  it "matches custom token suggestions against rendered custom field values" do
    expect(custom_matches_for("saved-search")).to contain_exactly(
      { "token" => "saved:weekly", "label" => "Weekly", "help" => "Weekly saved queue", "kind" => "saved-search" }
    )

    expect(custom_matches_for("Analytics")).to contain_exactly(
      { "token" => "report:stale", "label" => "Stale report", "help" => "Analytics review", "kind" => "report", "owner" => "analytics" }
    )

    expect(custom_matches_for("Boolean")).to contain_exactly(
      { "token" => "AND", "label" => "And", "help" => "Boolean join", "kind" => "operator" }
    )
  end

  it "limits matching to configured custom rendered fields" do
    expect(custom_match_field_matches_for("saved-search")).to eq([])
    expect(custom_match_field_matches_for("Analytics")).to eq([])

    expect(custom_match_field_matches_for("saved:weekly")).to contain_exactly(
      { "token" => "saved:weekly", "label" => "Weekly", "help" => "Weekly saved queue", "kind" => "saved-search" }
    )

    expect(custom_match_field_matches_for("Weekly")).to contain_exactly(
      { "token" => "saved:weekly", "label" => "Weekly", "help" => "Weekly saved queue", "kind" => "saved-search" }
    )
  end
end
