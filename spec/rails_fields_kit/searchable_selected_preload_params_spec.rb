# frozen_string_literal: true

require "spec_helper"

class SelectedPreloadRelation
  def initialize(records)
    @records = records
  end

  def where(conditions)
    values = conditions.fetch(:id)
    lookup_ids = Array(values).map(&:to_s)
    SelectedPreloadModel.record_lookup_ids(lookup_ids)
    SelectedPreloadRelation.new(@records.select { |record| lookup_ids.include?(record.id.to_s) })
  end

  def to_a
    @records
  end
end

class SelectedPreloadModel
  extend RailsFieldsKit::Searchable

  Record = Struct.new(:id, :label, keyword_init: true) do
    def display_label
      label
    end
  end

  def self.record_lookup_ids(ids)
    @last_lookup_ids = ids
  end

  def self.last_lookup_ids
    @last_lookup_ids
  end

  def self.all
    record_lookup_ids(nil)
    SelectedPreloadRelation.new([
      Record.new(id: 1, label: "One"),
      Record.new(id: 2, label: "Two"),
      Record.new(id: 3, label: "Three")
    ])
  end
end

RSpec.describe "selected preload request params" do
  let(:controller_class) do
    Class.new do
      include RailsFieldsKit::Searchable::ControllerMethods

      attr_accessor :params
    end
  end

  let(:controller) { controller_class.new }

  before do
    RailsFieldsKit.configure do |config|
      config.searchable_models = {
        "selected_preload_records" => {
          class_name: "SelectedPreloadModel",
          search_columns: [:label],
          display_method: :display_label
        }
      }
    end
  end

  it "keeps comma-separated selected preload ids as the outgoing JS request shape" do
    controller.params = {
      model: "selected_preload_records",
      ids: "1, 2, ,3"
    }

    result = controller.rfk_search_options

    expect(SelectedPreloadModel.last_lookup_ids).to eq(["1", "2", "3"])
    expect(result).to eq([
      { id: "1", text: "One" },
      { id: "2", text: "Two" },
      { id: "3", text: "Three" }
    ])
  end

  it "accepts Rails-parsed Array params for selected preload ids" do
    controller.params = {
      model: "selected_preload_records",
      ids: ["2", " ", "1"]
    }

    result = controller.rfk_search_options

    expect(SelectedPreloadModel.last_lookup_ids).to eq(["2", "1"])
    expect(result).to eq([
      { id: "2", text: "Two" },
      { id: "1", text: "One" }
    ])
  end

  it "accepts Rails-parsed Array params for custom selected preload ids_param" do
    controller.params = {
      model: "selected_preload_records",
      customer_ids: ["3", "", "1"],
      ids_param: "customer_ids"
    }

    result = controller.rfk_search_options

    expect(SelectedPreloadModel.last_lookup_ids).to eq(["3", "1"])
    expect(result).to eq([
      { id: "3", text: "Three" },
      { id: "1", text: "One" }
    ])
  end
end
