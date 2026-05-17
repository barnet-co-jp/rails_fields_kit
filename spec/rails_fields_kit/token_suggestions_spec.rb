# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TokenSuggestions do
  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "builds operator suggestions" do
    suggestions = described_class.build(operators: ["OR", "not()"])

    expect(suggestions).to eq([
      { "value" => "OR", "text" => "OR", "description" => "Search operator", "badge" => "operator" },
      { "value" => "not()", "text" => "Not", "description" => "Search operator", "badge" => "operator" }
    ])
  end

  it "builds field and field value suggestions" do
    suggestions = described_class.build(
      fields: {
        status: {
          label: "Status",
          values: ["open", "closed"]
        },
        assignee: "Assignee"
      }
    )

    expect(suggestions).to include(
      { "value" => "status:", "text" => "Status", "description" => "Search by Status", "badge" => "field" },
      { "value" => "status:open", "text" => "Status Open", "description" => "Status value", "badge" => "value" },
      { "value" => "status:closed", "text" => "Status Closed", "description" => "Status value", "badge" => "value" },
      { "value" => "assignee:", "text" => "Assignee", "description" => "Search by Assignee", "badge" => "field" }
    )
  end

  it "builds predicate and saved search suggestions" do
    suggestions = described_class.build(
      predicates: {
        created: ["today", { value: "this_week", label: "This week" }]
      },
      saved_searches: [
        { token: "saved:mine", label: "Mine", description: "My saved search" }
      ]
    )

    expect(suggestions).to include(
      { "value" => "created:today", "text" => "Today", "description" => "Created value", "badge" => "value" },
      { "value" => "created:this_week", "text" => "This week", "badge" => "value", "label" => "This week" },
      { "value" => "saved:mine", "text" => "Mine", "description" => "My saved search", "badge" => "saved", "label" => "Mine" }
    )
  end

  it "uses custom field names" do
    suggestions = described_class.build(
      fields: [:status],
      value_field: "token",
      label_field: "label",
      description_field: "help",
      badge_field: "kind"
    )

    expect(suggestions).to eq([
      { "token" => "status:", "label" => "Status", "help" => "Search by Status", "kind" => "field" }
    ])
  end
end