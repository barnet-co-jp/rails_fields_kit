# frozen_string_literal: true

RSpec.describe RailsFieldsKit::Searchable do
  FakeErrors = Struct.new(:messages) do
    def to_hash(_full_messages = false)
      messages
    end
  end

  class FakeRecord
    attr_reader :id, :name, :email, :status, :errors

    def initialize(attributes = {})
      @id = attributes[:id] || 1
      @name = attributes[:name]
      @email = attributes[:email]
      @status = attributes[:status] || "active"
      @errors = FakeErrors.new({ name: ["can't be blank"] })
    end

    def save
      name.to_s.strip != ""
    end
  end

  class FakeRelation
    attr_reader :where_args, :limit_value

    def initialize(records)
      @records = records
      @where_args = []
    end

    def where(*args)
      @where_args << args
      self
    end

    def limit(value)
      @limit_value = value
      @records.first(value)
    end
  end

  class FakeArelPredicate
    attr_reader :parts

    def initialize(*parts)
      @parts = parts
    end

    def or(other)
      FakeArelPredicate.new(:or, self, other)
    end
  end

  class FakeArelColumn
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def matches(value)
      FakeArelPredicate.new(:matches, name, value)
    end
  end

  class FakeArelTable
    def [](name)
      FakeArelColumn.new(name)
    end
  end

  class FakeModel
    def self.new(attributes)
      FakeRecord.new(attributes.merge(id: 123, email: "new@example.test", status: "new"))
    end

    def self.all
      FakeRelation.new([
        FakeRecord.new(id: 1, name: "Acme Corp", email: "hello@acme.example", status: "active"),
        FakeRecord.new(id: 2, name: "Beta LLC", email: "hello@beta.example", status: "archived")
      ])
    end

    def self.arel_table
      FakeArelTable.new
    end

    def self.sanitize_sql_like(value)
      value.to_s.gsub("%", "\\%")
    end
  end

  class FakeController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json, :rendered_status

    rfk_search_with(
      model: FakeModel,
      value: :id,
      label: :name,
      search: [:name, :email],
      value_field: "id",
      label_field: "name",
      limit: 1
    )

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

  class FakeCustomQueryController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_search_with(
      model: FakeModel,
      value: :id,
      label: :name,
      search: :name,
      query_param: "term",
      value_field: "id",
      label_field: "name"
    )

    def render(json:, status: :ok)
      @rendered_json = json
      @rendered_status = status
    end
  end

  class FakeWrappedController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json, :rendered_status

    rfk_search_with(
      model: FakeModel,
      value: :id,
      label: :name,
      search: :name,
      value_field: "id",
      label_field: "name",
      wrap: "options"
    )

    rfk_create_with(
      model: FakeModel,
      value: :id,
      label: :name,
      create_attribute: :name,
      create_param: "name",
      value_field: "id",
      label_field: "name",
      wrap: "option"
    )

    def render(json:, status: :ok)
      @rendered_json = json
      @rendered_status = status
    end
  end

  class FakeRichController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json, :rendered_status

    rfk_search_with(
      model: FakeModel,
      value: :id,
      label: :name,
      search: :name,
      value_field: "id",
      label_field: "name",
      description: :email,
      badge: :status,
      description_field: "email",
      badge_field: "status",
      limit: 1
    )

    rfk_create_with(
      model: FakeModel,
      value: :id,
      label: :name,
      create_attribute: :name,
      create_param: "name",
      value_field: "id",
      label_field: "name",
      description: :email,
      badge: ->(record) { record.status.upcase },
      description_field: "email",
      badge_field: "status"
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

  it "renders search results as option JSON" do
    controller = FakeController.new
    controller.params = { "q" => "Acme" }

    controller.index

    expect(controller.rendered_status).to eq(:ok)
    expect(controller.rendered_json).to eq([{ "id" => 1, "name" => "Acme Corp" }])
  end

  it "supports custom query params" do
    controller = FakeCustomQueryController.new
    controller.params = { "term" => "Beta" }

    controller.index

    expect(controller.rendered_json.first).to eq({ "id" => 1, "name" => "Acme Corp" })
  end

  it "renders wrapped search results" do
    controller = FakeWrappedController.new
    controller.params = { "q" => "Acme" }

    controller.index

    expect(controller.rendered_json).to eq({ "options" => [{ "id" => 1, "name" => "Acme Corp" }, { "id" => 2, "name" => "Beta LLC" }] })
  end

  it "renders rich search results" do
    controller = FakeRichController.new
    controller.params = { "q" => "Acme" }

    controller.index

    expect(controller.rendered_json).to eq([
      { "id" => 1, "name" => "Acme Corp", "email" => "hello@acme.example", "status" => "active" }
    ])
  end

  it "renders created options as JSON" do
    controller = FakeController.new
    controller.params = { "name" => "Acme Corp" }

    controller.create

    expect(controller.rendered_status).to eq(:created)
    expect(controller.rendered_json).to eq({ "id" => 123, "name" => "Acme Corp" })
  end

  it "renders wrapped created options" do
    controller = FakeWrappedController.new
    controller.params = { "name" => "Acme Corp" }

    controller.create

    expect(controller.rendered_status).to eq(:created)
    expect(controller.rendered_json).to eq({ "option" => { "id" => 123, "name" => "Acme Corp" } })
  end

  it "renders rich created options" do
    controller = FakeRichController.new
    controller.params = { "name" => "Acme Corp" }

    controller.create

    expect(controller.rendered_status).to eq(:created)
    expect(controller.rendered_json).to eq({ "id" => 123, "name" => "Acme Corp", "email" => "new@example.test", "status" => "NEW" })
  end

  it "renders validation errors" do
    controller = FakeController.new
    controller.params = { "name" => "" }

    controller.create

    expect(controller.rendered_status).to eq(:unprocessable_entity)
    expect(controller.rendered_json).to eq({ errors: { name: ["can't be blank"] } })
  end
end
