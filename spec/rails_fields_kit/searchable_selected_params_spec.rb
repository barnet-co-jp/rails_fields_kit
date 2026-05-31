# frozen_string_literal: true

RSpec.describe "RailsFieldsKit::Searchable selected preload params" do
  SelectedParamRecord = Struct.new(:id, :name)

  class SelectedParamRelation
    def initialize(records)
      @records = records
    end

    def where(*args)
      return self unless args.first.is_a?(Hash)

      key, values = args.first.first
      selected_values = Array(values).map(&:to_s)
      self.class.new(@records.select { |record| selected_values.include?(record.public_send(key).to_s) })
    end

    def limit(value)
      @records.first(value)
    end
  end

  class SelectedParamModel
    def self.all
      SelectedParamRelation.new([
        SelectedParamRecord.new(1, "Acme Corp"),
        SelectedParamRecord.new(2, "Beta LLC"),
        SelectedParamRecord.new(3, "Gamma Inc")
      ])
    end
  end

  class SelectedParamController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_find_with(
      model: SelectedParamModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name"
    )

    def render(json:, status: :ok)
      @rendered_json = json
    end
  end

  class CustomSelectedParamController
    include RailsFieldsKit::Searchable

    attr_accessor :params
    attr_reader :rendered_json

    rfk_find_with(
      model: SelectedParamModel,
      value: :id,
      label: :name,
      value_field: "id",
      label_field: "name",
      ids_param: :selected_ids
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

  it "keeps comma-separated ids as the default multiple selected preload contract" do
    controller = SelectedParamController.new
    controller.params = { "ids" => "1,2" }

    controller.show

    expect(controller.rendered_json).to eq([
      { "id" => 1, "name" => "Acme Corp" },
      { "id" => 2, "name" => "Beta LLC" }
    ])
  end

  it "accepts Rails array params for multiple selected preload ids" do
    controller = SelectedParamController.new
    controller.params = { "ids" => ["1", "3"] }

    controller.show

    expect(controller.rendered_json).to eq([
      { "id" => 1, "name" => "Acme Corp" },
      { "id" => 3, "name" => "Gamma Inc" }
    ])
  end

  it "applies the same string and array boundary to custom ids params" do
    string_controller = CustomSelectedParamController.new
    string_controller.params = { "selected_ids" => "1,2" }

    array_controller = CustomSelectedParamController.new
    array_controller.params = { "selected_ids" => ["1", "2"] }

    string_controller.show
    array_controller.show

    expect(string_controller.rendered_json).to eq([
      { "id" => 1, "name" => "Acme Corp" },
      { "id" => 2, "name" => "Beta LLC" }
    ])
    expect(array_controller.rendered_json).to eq(string_controller.rendered_json)
  end
end
