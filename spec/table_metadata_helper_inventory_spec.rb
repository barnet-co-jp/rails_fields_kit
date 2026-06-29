# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table metadata helper inventory" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:public_api_path) { File.join(repo_root, "doc/public_api.md") }
  let(:table_file_field_metadata_path) { File.join(repo_root, "doc/table_file_field_metadata.md") }
  let(:checkbox_doc_path) { File.join(repo_root, "doc/table_check_box_metadata.md") }
  let(:radio_doc_path) { File.join(repo_root, "doc/table_radio_button_metadata.md") }
  let(:public_api) { File.read(public_api_path) }

  def documented_class_methods(class_name)
    public_api.scan(/- `#{Regexp.escape(class_name)}\.([a-z0-9_!?]+)`/).flatten.map(&:to_sym)
  end

  def documented_factory_methods(class_name)
    documented_class_methods(class_name) - %i[known_types known_type? from_type]
  end

  def table_cell_factory_options(field_type)
    return { tag_value: "published" } if field_type == :radio_button

    {}
  end

  it "keeps TableFilterInput.known_types aligned with the documented helper family" do
    documented_factories = documented_factory_methods("RailsFieldsKit::TableFilterInput")

    expect(File.read(checkbox_doc_path)).to include("TableFilterInput.check_box")
    expect(RailsFieldsKit::TableFilterInput.known_types).to eq(documented_factories - [:ransack_filter])
  end

  it "keeps TableCellInput.known_types aligned with the documented helper family" do
    documented_factories = documented_factory_methods("RailsFieldsKit::TableCellInput")

    expect(File.read(table_file_field_metadata_path)).to include("TableCellInput.file_field")
    expect(File.read(checkbox_doc_path)).to include("TableCellInput.check_box")
    expect(File.read(radio_doc_path)).to include("TableCellInput.radio_button")
    expect(RailsFieldsKit::TableCellInput.known_types).to eq(documented_factories)
  end

  it "keeps TableFilterInput factory methods wired to their documented field types" do
    RailsFieldsKit::TableFilterInput.known_types.each do |field_type|
      expect(RailsFieldsKit::TableFilterInput).to respond_to(field_type)

      input = RailsFieldsKit::TableFilterInput.public_send(field_type, :status)

      expect(input.field_type).to eq(field_type)
      expect(input.to_h.fetch(:field_type)).to eq(field_type.to_s)
    end
  end

  it "keeps TableCellInput factory methods wired to their documented field types" do
    RailsFieldsKit::TableCellInput.known_types.each do |field_type|
      expect(RailsFieldsKit::TableCellInput).to respond_to(field_type)

      input = RailsFieldsKit::TableCellInput.public_send(
        field_type,
        :status,
        **table_cell_factory_options(field_type)
      )

      expect(input.field_type).to eq(field_type)
      expect(input.to_h.fetch(:field_type)).to eq(field_type.to_s)
    end
  end

  it "keeps ransack_filter as the token-search-specific adapter lane" do
    input = RailsFieldsKit::TableFilterInput.ransack_filter(
      :query,
      fields: {
        name: :name_cont,
        status: :status_eq
      },
      param_name: :q
    )

    expect(input.field_type).to eq(:token_search)
    expect(input.options).to include(
      adapter: :ransack,
      param_name: :q,
      fields: {
        name: :name_cont,
        status: :status_eq
      }
    )
  end
end
