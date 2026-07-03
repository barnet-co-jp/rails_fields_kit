# frozen_string_literal: true

require "spec_helper"

SELECTED_PRELOAD_LOOKUP_IDS = []

class SelectedPreloadRelation
  def initialize(records)
    @records = records
  end

  def where(conditions)
    values = conditions.fetch(:id)
    lookup_ids = Array(values).map(&:to_s)
    SELECTED_PRELOAD_LOOKUP_IDS.replace(lookup_ids)
    SelectedPreloadRelation.new(@records.select { |record| lookup_ids.include?(record.id.to_s) })
  end

  def order(_value)
    self
  end

  def limit(value)
    @records.first(value)
  end
end

class SelectedPreloadModel
  Record = Struct.new(:id, :label, keyword_init: true) do
    def display_label
      label
    end
  end

  def self.all
    SELECTED_PRELOAD_LOOKUP_IDS.clear
    SelectedPreloadRelation.new([
      Record.new(id: 1, label: "One"),
      Record.new(id: 2, label: "Two"),
      Record.new(id: 3, label: "Three")
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
    label: :display_label,
    value_field: "id",
    label_field: "text"
  )

  def render(json:, status: :ok)
    @rendered_json = json
    @rendered_status = status
  end
end

class CustomSelectedPreloadController
  include RailsFieldsKit::Searchable

  attr_accessor :params
  attr_reader :rendered_json

  rfk_find_with(
    action: :selected,
    model: SelectedPreloadModel,
    value: :id,
    label: :display_label,
    ids_param: :customer_ids,
    value_field: "id",
    label_field: "text"
  )

  def render(json:, status: :ok)
    @rendered_json = json
    @rendered_status = status
  end
end

RSpec.describe "selected preload request params" do
  let(:controller) { SelectedPreloadController.new }

  it "keeps comma-separated selected preload ids as the outgoing JS request shape" do
    controller.params = { ids: "1, 2, ,3" }

    controller.selected

    expect(SELECTED_PRELOAD_LOOKUP_IDS).to eq(["1", "2", "3"])
    expect(controller.rendered_json).to eq([
      { "id" => 1, "text" => "One" },
      { "id" => 2, "text" => "Two" },
      { "id" => 3, "text" => "Three" }
    ])
  end

  it "accepts Rails-parsed Array params for selected preload ids" do
    controller.params = { ids: ["2", " ", "1"] }

    controller.selected

    expect(SELECTED_PRELOAD_LOOKUP_IDS).to eq(["2", "1"])
    expect(controller.rendered_json).to eq([
      { "id" => 2, "text" => "Two" },
      { "id" => 1, "text" => "One" }
    ])
  end

  it "accepts Rails-parsed Array params for custom selected preload ids_param" do
    custom_controller = CustomSelectedPreloadController.new
    custom_controller.params = { customer_ids: ["3", "", "1"] }

    custom_controller.selected

    expect(SELECTED_PRELOAD_LOOKUP_IDS).to eq(["3", "1"])
    expect(custom_controller.rendered_json).to eq([
      { "id" => 3, "text" => "Three" },
      { "id" => 1, "text" => "One" }
    ])
  end
end
