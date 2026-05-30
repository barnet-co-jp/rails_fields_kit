# frozen_string_literal: true

RSpec.describe "token suggestion falsy normalization" do
  class FalsyTokenSuggestionsController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_token_suggestions_with(
      suggestions: [
        { value: 0, text: "Zero", description: false, badge: 0 },
        { value: false, text: "No", description: nil, badge: false },
        { value: nil, id: "fallback-id", text: "" }
      ]
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  class CustomFalsyTokenSuggestionsController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_token_suggestions_with(
      suggestions: [
        {
          token: false,
          value: "fallback-token",
          label: false,
          text: "Fallback label",
          summary: false,
          description: "Fallback description",
          kind: 0,
          badge: "Fallback badge"
        }
      ],
      value_field: "token",
      label_field: "label",
      description_field: "summary",
      badge_field: "kind"
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

  it "keeps explicit falsy values separate from missing keys" do
    controller = FalsyTokenSuggestionsController.new
    controller.params = { "q" => "" }

    controller.index

    expect(controller.rendered_json).to eq([
      { "value" => 0, "text" => "Zero", "description" => false, "badge" => 0 },
      { "value" => false, "text" => "No", "description" => nil, "badge" => false },
      { "value" => "fallback-id", "text" => "", "id" => "fallback-id" }
    ])
  end

  it "does not fall back from explicit falsy custom fields" do
    controller = CustomFalsyTokenSuggestionsController.new
    controller.params = { "q" => "" }

    controller.index

    expect(controller.rendered_json).to eq([
      {
        "token" => false,
        "label" => false,
        "summary" => false,
        "kind" => 0,
        "value" => "fallback-token",
        "text" => "Fallback label",
        "description" => "Fallback description",
        "badge" => "Fallback badge"
      }
    ])
  end
end
