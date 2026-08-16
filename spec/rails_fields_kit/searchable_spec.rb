# frozen_string_literal: true

RSpec.describe RailsFieldsKit::Searchable do
  FakeErrors = Struct.new(:messages) do
    def to_hash(_full_messages = false)
      messages
    end
  end

  class FakeRecord
    attr_accessor :name, :email, :status, :account_id
    attr_reader :id, :errors

    def initialize(attributes = {})
      @id = attributes[:id] || 1
      @name = attributes[:name]
      @email = attributes[:email]
      @status = attributes[:status] || "active"
      @account_id = attributes[:account_id]
      @errors = FakeErrors.new({ name: ["can't be blank"] })
    end

    def save
      name.to_s.strip != ""
    end
  end

  class FakeRelation
    attr_reader :where_args, :limit_value, :order_value, :distinct_called

    def initialize(records)
      @records = records
      @where_args = []
      @distinct_called = false
    end

    def where(*args)
      @where_args << args
      if args.first.is_a?(Hash)
        key, values = args.first.first
        values = Array(values).map(&:to_s)
        filtered_records = @records.select { |record| values.include?(record.public_send(key).to_s) }
        return FakeRelation.new(filtered_records)
      end

      self
    end

    def order(value)
      @order_value = value
      self
    end

    def distinct
      @distinct_called = true
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
    class << self
      attr_accessor :last_relation, :last_record
    end

    def self.new(attributes)
      self.last_record = FakeRecord.new(attributes.merge(id: 123, email: "new@example.test", status: "new"))
    end

    def self.all
      self.last_relation = FakeRelation.new([
        FakeRecord.new(id: 1, name: "Acme Corp", email: "hello@acme.example", status: "active"),
        FakeRecord.new(id: 2, name: "Beta LLC", email: "hello@beta.example", status: "archived")
      ])
    end

    def self.active
      self.last_relation = FakeRelation.new([
        FakeRecord.new(id: 1, name: "Acme Corp", email: "hello@acme.example", status: "active")
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

  class FakeCustomActionController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json, :rendered_status

    rfk_search_with(
      action: :lookup,
      model: FakeModel,
      value: :id,
      label: :name,
      search: :name,
      value_field: "id",
      label_field: "name"
    )

    rfk_find_with(
      action: :selected,
      model: FakeModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name"
    )

    rfk_create_with(
      action: :build,
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

    rfk_find_with(
      model: FakeModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name",
      wrap: "option"
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

  class FakeMinimumQueryLengthController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_search_with(
      model: FakeModel,
      value: :id,
      label: :name,
      search: :name,
      value_field: "id",
      label_field: "name",
      minimum_query_length: 1,
      wrap: "options"
    )

    rfk_search_with(
      action: :strict,
      model: FakeModel,
      value: :id,
      label: :name,
      search: :name,
      value_field: "id",
      label_field: "name",
      minimum_query_length: 3,
      wrap: "options"
    )

    def render(json:, status: :ok)
      @rendered_json = json
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

    rfk_find_with(
      model: FakeModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name",
      description: :email,
      badge: :status,
      description_field: "email",
      badge_field: "status"
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

  class FakeScopedController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_search_with(
      model: FakeModel,
      value: :id,
      label: :name,
      search: :name,
      value_field: "id",
      label_field: "name",
      scope: :active,
      order: { name: :asc },
      distinct: true
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  class FakeLambdaScopedController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_search_with(
      model: FakeModel,
      value: :id,
      label: :name,
      search: :name,
      value_field: "id",
      label_field: "name",
      scope: -> { FakeRelation.new([FakeRecord.new(id: 9, name: "Scoped", email: "scoped@example.test")]) }
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  class FakeTokenSuggestionsController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json, :rendered_status

    rfk_token_suggestions_with(
      suggestions: [
        "status:open",
        ["Assigned to me", "assignee:me"],
        { token: "priority:high", label: "High priority", description: "Urgent items", badge: "priority" },
        { value: "status:closed", text: "Closed" }
      ],
      limit: 3
    )

    def render(json:, status: :ok)
      @rendered_json = json
      @rendered_status = status
    end
  end

  class FakeCallableTokenSuggestionsController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_token_suggestions_with(
      action: :tokens,
      query_param: "term",
      suggestions: ->(query) {
        [
          { token: "status:#{query}", label: "Status #{query}", badge: "operator" },
          { token: "assignee:me", label: "Assigned to me" }
        ]
      },
      value_field: "token",
      label_field: "label",
      badge_field: "kind",
      wrap: "options"
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  class FakeHookedCreateController
    include RailsFieldsKit::Searchable

    attr_accessor :params, :allow_create
    attr_reader :rendered_json, :rendered_status

    rfk_create_with(
      model: FakeModel,
      value: :id,
      label: :name,
      create_attribute: :name,
      create_param: "name",
      value_field: "id",
      label_field: "name",
      assign: ->(record) { { account_id: 42, status: "assigned" } },
      authorize: ->(_record) { allow_create },
      before_save: :normalize_record
    )

    def initialize
      @allow_create = true
    end

    def normalize_record(record)
      return false if record.name == "stop"

      record.name = record.name.upcase
      true
    end

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

  it "keeps blank query initial options by default" do
    controller = FakeController.new
    controller.params = {}

    controller.index

    expect(controller.rendered_status).to eq(:ok)
    expect(controller.rendered_json).to eq([{ "id" => 1, "name" => "Acme Corp" }])
    expect(FakeModel.last_relation.where_args).to eq([])
  end

  it "supports custom action names" do
    controller = FakeCustomActionController.new
    controller.params = { "q" => "Acme", "id" => "1", "name" => "Created" }

    controller.lookup
    expect(controller.rendered_json).to eq([{ "id" => 1, "name" => "Acme Corp" }, { "id" => 2, "name" => "Beta LLC" }])

    controller.selected
    expect(controller.rendered_json).to eq({ "id" => 1, "name" => "Acme Corp" })

    controller.build
    expect(controller.rendered_status).to eq(:created)
    expect(controller.rendered_json).to eq({ "id" => 123, "name" => "Created" })
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

  it "returns wrapped empty options when query is shorter than the endpoint minimum" do
    controller = FakeMinimumQueryLengthController.new
    FakeModel.last_relation = nil
    controller.params = { "q" => "" }

    controller.index

    expect(controller.rendered_json).to eq({ "options" => [] })
    expect(FakeModel.last_relation).to be_nil
  end

  it "searches when query meets the endpoint minimum" do
    controller = FakeMinimumQueryLengthController.new
    controller.params = { "q" => "Acm" }

    controller.strict

    expect(controller.rendered_json).to eq({ "options" => [{ "id" => 1, "name" => "Acme Corp" }, { "id" => 2, "name" => "Beta LLC" }] })
    expect(FakeModel.last_relation.where_args).not_to eq([])
  end

  it "renders selected option by id" do
    controller = FakeRichController.new
    controller.params = { "id" => "1" }

    controller.show

    expect(controller.rendered_json).to eq({ "id" => 1, "name" => "Acme Corp", "email" => "hello@acme.example", "status" => "active" })
  end

  it "renders selected options by comma separated ids" do
    controller = FakeRichController.new
    controller.params = { "ids" => "1,2" }

    controller.show

    expect(controller.rendered_json).to eq([
      { "id" => 1, "name" => "Acme Corp", "email" => "hello@acme.example", "status" => "active" },
      { "id" => 2, "name" => "Beta LLC", "email" => "hello@beta.example", "status" => "archived" }
    ])
  end

  it "renders wrapped selected option" do
    controller = FakeWrappedController.new
    controller.params = { "id" => "1" }

    controller.show

    expect(controller.rendered_json).to eq({ "option" => { "id" => 1, "name" => "Acme Corp" } })
  end

  it "supports scoped ordered distinct search results" do
    controller = FakeScopedController.new
    controller.params = { "q" => "Acme" }

    controller.index

    expect(controller.rendered_json).to eq([{ "id" => 1, "name" => "Acme Corp" }])
    expect(FakeModel.last_relation.distinct_called).to eq(true)
    expect(FakeModel.last_relation.order_value).to eq({ name: :asc })
  end

  it "supports lambda scopes" do
    controller = FakeLambdaScopedController.new
    controller.params = { "q" => "Scoped" }

    controller.index

    expect(controller.rendered_json).to eq([{ "id" => 9, "name" => "Scoped" }])
  end

  it "renders rich search results" do
    controller = FakeRichController.new
    controller.params = { "q" => "Acme" }

    controller.index

    expect(controller.rendered_json).to eq([
      { "id" => 1, "name" => "Acme Corp", "email" => "hello@acme.example", "status" => "active" }
    ])
  end

  it "renders token suggestions" do
    controller = FakeTokenSuggestionsController.new
    controller.params = { "q" => "status" }

    controller.index

    expect(controller.rendered_status).to eq(:ok)
    expect(controller.rendered_json).to eq([
      { "value" => "status:open", "text" => "status:open" },
      { "value" => "status:closed", "text" => "Closed" }
    ])
  end

  it "renders callable wrapped token suggestions with custom fields" do
    controller = FakeCallableTokenSuggestionsController.new
    controller.params = { "term" => "open" }

    controller.tokens

    expect(controller.rendered_json).to eq({
      "options" => [
        { "token" => "status:open", "label" => "Status open", "kind" => "operator", "badge" => "operator" }
      ]
    })
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

  it "supports create assignments and before save hooks" do
    controller = FakeHookedCreateController.new
    controller.params = { "name" => "acme" }

    controller.create

    expect(controller.rendered_status).to eq(:created)
    expect(controller.rendered_json).to eq({ "id" => 123, "name" => "ACME" })
    expect(FakeModel.last_record.account_id).to eq(42)
    expect(FakeModel.last_record.status).to eq("assigned")
  end

  it "renders forbidden when create authorization fails" do
    controller = FakeHookedCreateController.new
    controller.allow_create = false
    controller.params = { "name" => "acme" }

    controller.create

    expect(controller.rendered_status).to eq(:forbidden)
    expect(controller.rendered_json).to eq({ errors: { base: ["not authorized"] } })
  end

  it "renders errors when before save returns false" do
    controller = FakeHookedCreateController.new
    controller.params = { "name" => "stop" }

    controller.create

    expect(controller.rendered_status).to eq(:unprocessable_entity)
    expect(controller.rendered_json).to eq({ errors: { name: ["can't be blank"] } })
  end

  it "renders validation errors" do
    controller = FakeController.new
    controller.params = { "name" => "" }

    controller.create

    expect(controller.rendered_status).to eq(:unprocessable_entity)
    expect(controller.rendered_json).to eq({ errors: { name: ["can't be blank"] } })
  end
end
