# frozen_string_literal: true

RSpec.describe RailsFieldsKit::Searchable, "selected preload params" do
  class SelectedPreloadRecord
    attr_reader :id, :name

    def initialize(id:, name:)
      @id = id
      @name = name
    end
  end

  class SelectedPreloadRelation
    def initialize(records)
      @records = records
    end

    def where(*args)
      _key, values = args.first.first
      SelectedPreloadModel.last_lookup_ids = Array(values).map(&:to_s)
      SelectedPreloadRelation.new(@records.select { |record| SelectedPreloadModel.last_lookup_ids.include?(record.id.to_s) })
    end

    def limit(value)
      @records.first(value)
    end
  end

  class SelectedPreloadModel
    class << self
      attr_accessor :last_lookup_ids
    end

    def self.all
      self.last_lookup_ids = nil
      SelectedPreloadRelation.new([
        SelectedPreloadRecord.new(id: 1, name: "Acme"),
        SelectedPreloadRecord.new(id: 2, name: "Beta"),
        SelectedPreloadRecord.new(id: 3, name: "Cyan")
      ])
    end
  end

  class SelectedPreloadController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_find_with(
      action: :selected,
      model: SelectedPreloadModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name",
      preserve_order: true
    )

    rfk_find_with(
      action: :selected_customers,
      model: SelectedPreloadModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name",
      ids_param: :customer_ids,
      preserve_order: true
    )

    def render(json:, status: :ok)
      @rendered_json = json
      @rendered_status = status
    end
  end

  it "keeps comma-separated selected preload ids as the default endpoint input" do
    controller = SelectedPreloadController.new
    controller.params = { "ids" => "1, 2, ,3 " }

    controller.selected

    expect(SelectedPreloadModel.last_lookup_ids).to eq(["1", "2", "3"])
    expect(controller.rendered_json).to eq([
      { "id" => 1, "name" => "Acme" },
      { "id" => 2, "name" => "Beta" },
      { "id" => 3, "name" => "Cyan" }
    ])
  end

  it "accepts Rails-parsed array params for multiple selected preload ids" do
    controller = SelectedPreloadController.new
    controller.params = { ids: ["2", " ", "1"] }

    controller.selected

    expect(SelectedPreloadModel.last_lookup_ids).to eq(["2", "1"])
    expect(controller.rendered_json).to eq([
      { "id" => 2, "name" => "Beta" },
      { "id" => 1, "name" => "Acme" }
    ])
  end

  it "accepts Rails-parsed array params for a custom selected preload ids_param" do
    controller = SelectedPreloadController.new
    controller.params = { "customer_ids" => ["3", "1"] }

    controller.selected_customers

    expect(SelectedPreloadModel.last_lookup_ids).to eq(["3", "1"])
    expect(controller.rendered_json).to eq([
      { "id" => 3, "name" => "Cyan" },
      { "id" => 1, "name" => "Acme" }
    ])
  end
end
