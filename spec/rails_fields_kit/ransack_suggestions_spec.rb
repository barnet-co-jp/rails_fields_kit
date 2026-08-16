# frozen_string_literal: true

RSpec.describe RailsFieldsKit::RansackSuggestions do
  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "builds Ransack-compatible field suggestions" do
    suggestions = described_class.build(
      fields: {
        name: :name_cont,
        status: {
          label: "Status",
          predicate: :status_eq,
          values: %w[open closed]
        }
      },
      operators: []
    )

    expect(suggestions).to include(
      {
        "value" => "name:",
        "text" => "Name",
        "description" => "Ransack predicate name_cont",
        "badge" => "ransack",
        "ransack_predicate" => "name_cont",
        "ransack_field" => "name"
      },
      {
        "value" => "status:",
        "text" => "Status",
        "description" => "Ransack predicate status_eq",
        "badge" => "ransack",
        "ransack_predicate" => "status_eq",
        "ransack_field" => "status"
      },
      {
        "value" => "status:open",
        "text" => "Open",
        "description" => "Status value",
        "badge" => "value",
        "ransack_predicate" => "status_eq",
        "ransack_field" => "status",
        "ransack_value" => "open"
      }
    )
  end

  it "includes default operators and saved searches" do
    suggestions = described_class.build(
      fields: { name: :name_cont },
      saved_searches: [
        { token: "saved:mine", label: "Mine" }
      ]
    )

    expect(suggestions).to include(
      { "value" => "OR", "text" => "OR", "description" => "Search operator", "badge" => "operator" },
      { "value" => "not()", "text" => "Not", "description" => "Search operator", "badge" => "operator" },
      { "value" => "saved:mine", "text" => "Mine", "badge" => "saved", "label" => "Mine" }
    )
  end

  it "supports custom output field names" do
    suggestions = described_class.build(
      fields: { name: :name_cont },
      operators: [],
      value_field: "token",
      label_field: "label",
      description_field: "help",
      badge_field: "kind"
    )

    expect(suggestions).to eq([
      {
        "token" => "name:",
        "label" => "Name",
        "help" => "Ransack predicate name_cont",
        "kind" => "ransack",
        "ransack_predicate" => "name_cont",
        "ransack_field" => "name"
      }
    ])
  end

  it "preserves value metadata" do
    suggestions = described_class.build(
      fields: {
        created: {
          predicate: :created_at_gteq,
          values: [
            { value: "today", label: "Today", description: "Created today", range: "day" }
          ]
        }
      },
      operators: []
    )

    expect(suggestions.last).to eq(
      {
        "value" => "created:today",
        "text" => "Today",
        "description" => "Created today",
        "badge" => "value",
        "ransack_predicate" => "created_at_gteq",
        "ransack_field" => "created",
        "ransack_value" => "today",
        "label" => "Today",
        "range" => "day"
      }
    )
  end

  it "supports Ransack predicate aliases in field config" do
    suggestions = described_class.build(
      fields: {
        customer: { ransack_predicate: :customer_name_cont },
        email: { ransack: :email_cont },
        code: { param: :code_eq }
      },
      operators: []
    )

    expect(suggestions).to include(
      hash_including("value" => "customer:", "ransack_predicate" => "customer_name_cont"),
      hash_including("value" => "email:", "ransack_predicate" => "email_cont"),
      hash_including("value" => "code:", "ransack_predicate" => "code_eq")
    )
  end

  it "does not mutate field or value metadata inputs" do
    value = { value: "today", label: "Today", description: "Created today", range: "day" }
    field_config = {
      predicate: :created_at_gteq,
      values: [value]
    }
    fields = { created: field_config }

    suggestions = described_class.build(fields: fields, operators: [])
    suggestions.last["range"] = "mutated"
    suggestions.last["label"] = "Mutated"

    expect(fields).to eq(
      created: {
        predicate: :created_at_gteq,
        values: [
          { value: "today", label: "Today", description: "Created today", range: "day" }
        ]
      }
    )
  end

  it "isolates custom output field mutations from source metadata" do
    fields = {
      created: {
        predicate: :created_at_gteq,
        values: [
          {
            value: "today",
            label: "Today",
            description: "Created today",
            range: "day"
          }
        ]
      }
    }

    suggestions = described_class.build(
      fields: fields,
      operators: [],
      value_field: "token",
      label_field: "label",
      description_field: "help",
      badge_field: "kind"
    )

    suggestions.last["range"] = "mutated"
    suggestions.last["label"] = "Mutated"

    expect(fields).to eq(
      created: {
        predicate: :created_at_gteq,
        values: [
          {
            value: "today",
            label: "Today",
            description: "Created today",
            range: "day"
          }
        ]
      }
    )
  end
end
