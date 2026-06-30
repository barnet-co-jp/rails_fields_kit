# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "table custom renderer registry guard" do
  let(:table_registry_guard_root) { File.expand_path("..", __dir__) }
  let(:table_registry_guard_specification) do
    Gem::Specification.load(File.join(table_registry_guard_root, "rails_fields_kit.gemspec"))
  end
  let(:table_registry_guard_doc) { File.read(File.join(table_registry_guard_root, "doc/table_adapters.md")) }

  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
  ensure
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "keeps the custom renderer registry docs packaged and scoped" do
    expect(table_registry_guard_specification.files).to include("doc/table_adapters.md")
    expect(table_registry_guard_doc).to include(
      "`known_types` is intentionally limited to the built-in factory family",
      "Custom field types can still travel through the metadata objects",
      "Use `RailsFieldsKit::TableRenderer.field_helpers`, `RailsFieldsKit::TableRenderer.helper_for`, and `RailsFieldsKit::TableRenderer.registered_field_type?`",
      "Use `RailsFieldsKit::TableRenderer.reset_field_helpers!` to restore the defaults",
      "The host application owns query execution, params construction, authorization, scoping, pagination, persistence, and user-visible success or error copy."
    )
  end

  it "keeps custom mappings renderable without adding them to built-in metadata type lists" do
    custom_field_type = :currency_range

    expect(RailsFieldsKit::TableFilterInput.known_type?(custom_field_type)).to be(false)
    expect(RailsFieldsKit::TableCellInput.known_type?(custom_field_type)).to be(false)
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(custom_field_type)).to be(false)

    RailsFieldsKit::TableRenderer.register_field_helper(custom_field_type, :rfk_money_field)

    expect(RailsFieldsKit::TableFilterInput.known_type?(custom_field_type)).to be(false)
    expect(RailsFieldsKit::TableCellInput.known_type?(custom_field_type)).to be(false)
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(custom_field_type)).to be(true)
    expect(RailsFieldsKit::TableRenderer.helper_for(custom_field_type)).to eq(:rfk_money_field)

    filter = RailsFieldsKit::TableFilterInput.from_type(
      custom_field_type,
      :minimum_total,
      step: 0.01,
      placeholder: "Minimum total"
    )
    editor = RailsFieldsKit::TableCellInput.from_type(
      custom_field_type,
      :maximum_total,
      step: 0.01,
      placeholder: "Maximum total"
    )

    expect(RailsFieldsKit::TableRenderer.filter_call(filter)).to eq(
      helper: :rfk_money_field,
      method: :minimum_total,
      options: { step: 0.01, placeholder: "Minimum total" }
    )
    expect(RailsFieldsKit::TableRenderer.cell_editor_call(editor)).to eq(
      helper: :rfk_money_field,
      method: :maximum_total,
      options: { step: 0.01, placeholder: "Maximum total" }
    )
  end
end
