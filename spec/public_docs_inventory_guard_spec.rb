# frozen_string_literal: true

require "rubygems"
require "spec_helper"
require "rails_fields_kit/table_cell_input"
require "rails_fields_kit/table_filter_input"

RSpec.describe "public docs inventory guards" do
  let(:repository_root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(repository_root, "rails_fields_kit.gemspec")) }
  let(:public_api) { read_repo_file("doc/public_api.md") }
  let(:product_profile) { read_repo_file("Product Profile.md") }
  let(:radio_metadata) { read_repo_file("doc/table_radio_button_metadata.md") }

  it "keeps native date/time/color helper docs aligned with packaged helper source" do
    helper_names = %w[
      rfk_date_field
      rfk_time_field
      rfk_datetime_local_field
      rfk_color_field
    ]
    native_source = read_repo_file("lib/rails_fields_kit/form_builder_native_date_time_fields.rb")
    engine_source = read_repo_file("lib/rails_fields_kit/engine.rb")
    native_guide = read_repo_file("doc/native_date_time_color_fields.md")

    expect(specification.files).to include(
      "doc/native_date_time_color_fields.md",
      "lib/rails_fields_kit/form_builder_native_date_time_fields.rb"
    )
    expect(engine_source).to include("rails_fields_kit/form_builder_native_date_time_fields")
    expect(public_api).to include("[`native_date_time_color_fields.md`](native_date_time_color_fields.md)")

    helper_names.each do |helper_name|
      expect(native_source).to include("def #{helper_name}(")
      expect(public_api).to include("`#{helper_name}`")
      expect(native_guide).to include("`#{helper_name}`")
    end

    expect(native_guide).to include(
      "browser-native picker behavior",
      "custom date picker, time picker, or color picker integrations",
      "server-side validation rules and validation copy",
      "timezone conversion and storage semantics"
    )
  end

  it "keeps token and table sample evidence guide packaged as an evidence companion" do
    token_table_evidence = read_repo_file("doc/token_table_sample_app_evidence.md")

    expect(specification.files).to include("doc/token_table_sample_app_evidence.md")
    expect(product_profile).to include(
      "`doc/token_table_sample_app_evidence.md`: focused release and PR evidence companion"
    )

    expect(token_table_evidence).to include(
      "release or focused PR needs sample app evidence for token search",
      "narrow companion to `doc/sample_app_checklist.md`",
      "does not define new runtime behavior, new release gates, or a broader sample app matrix",
      "not as a source of new behavior"
    )
    expect(token_table_evidence).to include(
      "token parsing, query execution, authorization, saved-search policy, result filtering",
      "Ransack suggestion metadata",
      "query execution, preference persistence, authorization, pagination"
    )
  end

  it "keeps table metadata known types aligned with the public API method list" do
    filter_methods = documented_class_methods("TableFilterInput")
    cell_methods = documented_class_methods("TableCellInput")
    table_metadata_intro = markdown_section(public_api, "## Table metadata adapters")
    focused_filter_methods = with_focused_table_filter_methods(filter_methods)

    expect(focused_filter_methods).to eq(
      %w[known_types known_type? from_type] +
        RailsFieldsKit::TableFilterInput.known_types.map(&:to_s) +
        %w[ransack_filter]
    )
    expect(cell_methods).to eq(
      %w[known_types known_type? from_type] +
        RailsFieldsKit::TableCellInput.known_types.map(&:to_s)
    )

    expect(focused_filter_methods).to include("ransack_filter")
    expect(cell_methods).not_to include("ransack_filter")
    expect(table_metadata_intro).to include(
      "Ransack-compatible token-search metadata",
      "without the Ransack-specific filter entrypoint"
    )
    expect(public_api).to include(
      "`TableRenderer.registered_field_types`",
      "`TableFilterInput.known_types` and `TableCellInput.known_types` remain limited to the built-in factory family"
    )
  end

  def read_repo_file(path)
    File.read(File.join(repository_root, path))
  end

  def documented_class_methods(class_name)
    markdown_section(public_api, "### #{class_name} methods")
      .scan(/`RailsFieldsKit::#{Regexp.escape(class_name)}\.([^`]+)`/)
      .flatten
  end

  def focused_table_filter_methods
    radio_metadata.include?("TableFilterInput.radio_button") ? ["radio_button"] : []
  end

  def with_focused_table_filter_methods(methods)
    return methods unless focused_table_filter_methods.include?("radio_button")

    insertion_index = methods.index("token_search") || methods.index("ransack_filter") || methods.length
    methods.dup.insert(insertion_index, "radio_button")
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=\#{1,3}\s)/, 2).first
  end
end
