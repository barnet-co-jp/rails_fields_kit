# frozen_string_literal: true

RSpec.describe RailsFieldsKit::Searchable do
  FakeErrors = Struct.new(:messages) do
    def to_hash(_full_messages = false)
      messages
    end
  end

  class FakeRecord
    attr_reader :id, :name, :errors

    def initialize(attributes = {})
      @id = attributes[:id] || 1
      @name = attributes[:name]
      @errors = FakeErrors.new({ name: ["can't be blank"] })
    end

    def save
      name.to_s.strip != ""
    end
  end

  class FakeModel
    def self.new(attributes)
      FakeRecord.new(attributes.merge(id: 123))
    end
  end

  class FakeController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json, :rendered_status

    rfk_create_with(
      model: FakeModel,
      value: :id,
      label: :name,
      create_attribute: :name,
      create_param: "name",
      value_field: "id",
      label_field: "name"
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

  it "renders created options as JSON" do
    controller = FakeController.new
    controller.params = { "name" => "Acme Corp" }

    controller.create

    expect(controller.rendered_status).to eq(:created)
    expect(controller.rendered_json).to eq({ "id" => 123, "name" => "Acme Corp" })
  end

  it "renders validation errors" do
    controller = FakeController.new
    controller.params = { "name" => "" }

    controller.create

    expect(controller.rendered_status).to eq(:unprocessable_entity)
    expect(controller.rendered_json).to eq({ errors: { name: ["can't be blank"] } })
  end
end
