# frozen_string_literal: true

RSpec.describe "RailsFieldsKit::Searchable rfk_find_with ordering" do
  class FindOrderRecord
    attr_reader :id, :name

    def initialize(id:, name:)
      @id = id
      @name = name
    end
  end

  class FindOrderRelation
    def initialize(records)
      @records = records
    end

    def where(*args)
      key, values = args.first.first
      requested_values = Array(values).map(&:to_s)
      self.class.new(@records.select { |record| requested_values.include?(record.public_send(key).to_s) })
    end

    def order(_value)
      self
    end

    def limit(value)
      @records.first(value)
    end
  end

  class FindOrderModel
    def self.all
      FindOrderRelation.new([
        FindOrderRecord.new(id: 1, name: "One"),
        FindOrderRecord.new(id: 2, name: "Two"),
        FindOrderRecord.new(id: 3, name: "Three")
      ])
    end
  end

  class FindOrderDefaultController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_find_with(
      model: FindOrderModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name",
      order: { name: :asc }
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  class FindOrderPreservedController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_find_with(
      model: FindOrderModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name",
      order: { name: :asc },
      preserve_order: true
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  it "keeps relation ordering by default for multiple selected ids" do
    controller = FindOrderDefaultController.new
    controller.params = { "ids" => "3,1,2" }

    controller.show

    expect(controller.rendered_json).to eq([
      { "id" => 1, "name" => "One" },
      { "id" => 2, "name" => "Two" },
      { "id" => 3, "name" => "Three" }
    ])
  end

  it "can preserve comma-separated selected id order" do
    controller = FindOrderPreservedController.new
    controller.params = { "ids" => "3,1,2" }

    controller.show

    expect(controller.rendered_json).to eq([
      { "id" => 3, "name" => "Three" },
      { "id" => 1, "name" => "One" },
      { "id" => 2, "name" => "Two" }
    ])
  end

  it "can preserve Rails array selected id order and skip missing ids" do
    controller = FindOrderPreservedController.new
    controller.params = { "ids" => ["2", "999", "1"] }

    controller.show

    expect(controller.rendered_json).to eq([
      { "id" => 2, "name" => "Two" },
      { "id" => 1, "name" => "One" }
    ])
  end
end
