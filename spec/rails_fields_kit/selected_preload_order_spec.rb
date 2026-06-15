# frozen_string_literal: true

RSpec.describe "selected preload order" do
  FakeSelectedOrderRecord = Struct.new(:id, :name, keyword_init: true)

  class FakeSelectedOrderRelation
    attr_reader :order_value

    def initialize(records)
      @records = records
    end

    def where(*args)
      return self unless args.first.is_a?(Hash)

      key, values = args.first.first
      wanted = Array(values).map(&:to_s)
      self.class.new(@records.select { |record| wanted.include?(record.public_send(key).to_s) })
    end

    def order(value)
      @order_value = value
      self.class.new(@records.sort_by { |record| record.public_send(value.keys.first) })
    end

    def limit(value)
      @records.first(value)
    end
  end

  class FakeSelectedOrderModel
    def self.all
      FakeSelectedOrderRelation.new([
        FakeSelectedOrderRecord.new(id: 1, name: "Alpha"),
        FakeSelectedOrderRecord.new(id: 2, name: "Beta"),
        FakeSelectedOrderRecord.new(id: 3, name: "Gamma")
      ])
    end
  end

  class FakeSelectedOrderController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_find_with(
      model: FakeSelectedOrderModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name"
    )

    rfk_find_with(
      action: :ordered,
      model: FakeSelectedOrderModel,
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

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "preserves requested id order for multiple selected preload without explicit order" do
    controller = FakeSelectedOrderController.new
    controller.params = { "ids" => "2,1" }

    controller.show

    expect(controller.rendered_json).to eq([
      { "id" => 2, "name" => "Beta" },
      { "id" => 1, "name" => "Alpha" }
    ])
  end

  it "lets explicit order define the multiple selected preload response order" do
    controller = FakeSelectedOrderController.new
    controller.params = { "ids" => "2,1" }

    controller.ordered

    expect(controller.rendered_json).to eq([
      { "id" => 1, "name" => "Alpha" },
      { "id" => 2, "name" => "Beta" }
    ])
  end

  it "omits missing ids and does not duplicate repeated requested ids" do
    controller = FakeSelectedOrderController.new
    controller.params = { "ids" => "2,999,2,1" }

    controller.show

    expect(controller.rendered_json).to eq([
      { "id" => 2, "name" => "Beta" },
      { "id" => 1, "name" => "Alpha" }
    ])
  end

  it "keeps single selected preload as an object payload" do
    controller = FakeSelectedOrderController.new
    controller.params = { "id" => "2" }

    controller.show

    expect(controller.rendered_json).to eq({ "id" => 2, "name" => "Beta" })
  end
end
