# frozen_string_literal: true

RSpec.describe "RailsFieldsKit::TableRenderer registry lifetime" do
  class RegistryLifetimeFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def custom_table_field(method, **options)
      calls << [:custom_table_field, method, options]
      "custom"
    end

    def scoped_table_field(method, **options)
      calls << [:scoped_table_field, method, options]
      "scoped"
    end
  end

  around do |example|
    RailsFieldsKit::TableRenderer.reset_field_helpers!
    example.run
    RailsFieldsKit::TableRenderer.reset_field_helpers!
  end

  it "keeps custom mappings global until reset_field_helpers restores the defaults" do
    RailsFieldsKit::TableRenderer.register_field_helper(:temporary_field, :custom_table_field)

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(true)
    expect(RailsFieldsKit::TableRenderer.filter_call(field_type: :temporary_field, method: :code)).to include(
      helper: :custom_table_field,
      method: :code
    )

    RailsFieldsKit::TableRenderer.reset_field_helpers!

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(false)
    expect {
      RailsFieldsKit::TableRenderer.filter_call(field_type: :temporary_field, method: :code)
    }.to raise_error(RailsFieldsKit::TableRenderer::UnknownFieldType)
  end

  it "lets a one-off registration render inside a scoped cleanup block" do
    form_builder = RegistryLifetimeFormBuilder.new

    begin
      RailsFieldsKit::TableRenderer.register_field_helper(:temporary_field, :custom_table_field)

      result = RailsFieldsKit::TableRenderer.render_filter(
        form_builder,
        field_type: :temporary_field,
        method: :code,
        options: {prefix: "#"}
      )
    ensure
      RailsFieldsKit::TableRenderer.reset_field_helpers!
    end

    expect(result).to eq("custom")
    expect(form_builder.calls).to eq([
      [:custom_table_field, :code, {prefix: "#"}]
    ])
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(false)
  end

  it "scopes custom-only mappings and returns the block value" do
    block_result = RailsFieldsKit::TableRenderer.with_field_helpers(temporary_field: :custom_table_field) do
      expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(true)
      expect(RailsFieldsKit::TableRenderer.filter_call(field_type: :temporary_field, method: :code)).to eq(
        helper: :custom_table_field,
        method: :code,
        options: {}
      )
      :returned_value
    end

    expect(block_result).to eq(:returned_value)
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(false)
    expect {
      RailsFieldsKit::TableRenderer.filter_call(field_type: :temporary_field, method: :code)
    }.to raise_error(RailsFieldsKit::TableRenderer::UnknownFieldType)
  end

  it "restores built-in mappings to the previous registry snapshot" do
    RailsFieldsKit::TableRenderer.register_field_helper(:combobox, :custom_table_field)

    RailsFieldsKit::TableRenderer.with_field_helpers(combobox: :scoped_table_field) do
      expect(RailsFieldsKit::TableRenderer.helper_for(:combobox)).to eq(:scoped_table_field)
      expect(RailsFieldsKit::TableRenderer.cell_editor_call(field_type: :combobox, method: :customer_id)).to eq(
        helper: :scoped_table_field,
        method: :customer_id,
        options: {}
      )
    end

    expect(RailsFieldsKit::TableRenderer.helper_for(:combobox)).to eq(:custom_table_field)
  end

  it "restores the previous registry when a scoped block raises" do
    expect {
      RailsFieldsKit::TableRenderer.with_field_helpers(temporary_field: :custom_table_field) do
        expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(true)
        raise "boom"
      end
    }.to raise_error(RuntimeError, "boom")

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(false)
  end

  it "accepts hash-style scoped mappings without exposing mutable registry state" do
    overrides = {"temporary_field" => "custom_table_field"}
    overrides_snapshot = overrides.dup

    RailsFieldsKit::TableRenderer.with_field_helpers(overrides) do
      overrides["other_field"] = "scoped_table_field"

      expect(RailsFieldsKit::TableRenderer.helper_for(:temporary_field)).to eq(:custom_table_field)
      expect(RailsFieldsKit::TableRenderer.registered_field_type?(:other_field)).to be(false)
    end

    expect(overrides_snapshot).to eq("temporary_field" => "custom_table_field")
    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(false)
  end

  it "requires a block for scoped helper overrides" do
    expect {
      RailsFieldsKit::TableRenderer.with_field_helpers(temporary_field: :custom_table_field)
    }.to raise_error(ArgumentError, "field helper block is required")
  end

  it "returns duplicated helper maps so callers cannot mutate the registry directly" do
    helpers = RailsFieldsKit::TableRenderer.field_helpers
    helpers["temporary_field"] = :custom_table_field

    expect(RailsFieldsKit::TableRenderer.registered_field_type?(:temporary_field)).to be(false)
    expect(RailsFieldsKit::TableRenderer.helper_for(:temporary_field)).to be_nil
  end
end
