# frozen_string_literal: true

RSpec.describe "FormBuilder helper inventory docs" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:readme) { File.read(File.join(repo_root, "README.md")) }
  let(:public_api) { File.read(File.join(repo_root, "doc/public_api.md")) }
  let(:field_helpers) { File.read(File.join(repo_root, "doc/field_helpers.md")) }
  let(:range_field) { File.read(File.join(repo_root, "doc/range_field.md")) }
  let(:native_date_time_color_fields) { File.read(File.join(repo_root, "doc/native_date_time_color_fields.md")) }
  let(:password_field) { File.read(File.join(repo_root, "doc/password_field.md")) }
  let(:check_box) { File.read(File.join(repo_root, "doc/check_box.md")) }
  let(:radio_button) { File.read(File.join(repo_root, "doc/radio_button.md")) }
  let(:file_field) { File.read(File.join(repo_root, "doc/file_field.md")) }

  it "keeps the compact public API helper inventory represented in helper docs" do
    public_helpers = form_builder_helper_names_from(public_api)
    detailed_helper_sections = field_helpers.scan(/^### `(rfk_[a-z_]+)`/).flatten
    detailed_helper_sections += range_field.scan(/`(rfk_range_field)`/).flatten
    detailed_helper_sections += native_date_time_color_fields.scan(/`(rfk_(?:date|time|datetime_local|color)_field)`/).flatten
    detailed_helper_sections += password_field.scan(/`(rfk_password_field)`/).flatten
    detailed_helper_sections += check_box.scan(/`(rfk_check_box)`/).flatten
    detailed_helper_sections += radio_button.scan(/`(rfk_radio_button)`/).flatten
    detailed_helper_sections += file_field.scan(/`(rfk_file_field)`/).flatten

    expect(public_helpers).to eq(%w[
      rfk_select
      rfk_combobox
      rfk_autocomplete
      rfk_lookup
      rfk_tags
      rfk_multi_select
      rfk_grouped_select
      rfk_enum_select
      rfk_token_search
      rfk_table_filters
      rfk_table_cell_editors
      rfk_text_field
      rfk_text_area
      rfk_number_field
      rfk_range_field
      rfk_money_field
      rfk_percent_field
      rfk_email_field
      rfk_url_field
      rfk_phone_field
      rfk_search_field
      rfk_password_field
      rfk_check_box
      rfk_radio_button
      rfk_file_field
      rfk_date_field
      rfk_time_field
      rfk_datetime_local_field
      rfk_color_field
    ])
    expect(detailed_helper_sections).to include(*public_helpers)
  end

  it "keeps the README chooser representative without making it an exhaustive mirror" do
    readme_chooser = markdown_section(readme, "## Choosing a helper")

    expect(readme).to include("[`doc/field_helpers.md`](doc/field_helpers.md)")
    expect(readme_chooser).to include(
      "`rfk_select`",
      "`rfk_combobox`",
      "`rfk_autocomplete`",
      "`rfk_token_search`",
      "`rfk_multi_select`",
      "`rfk_tags`",
      "`rfk_grouped_select`",
      "`rfk_enum_select`",
      "`rfk_text_field`",
      "`rfk_money_field`",
      "`rfk_phone_field`",
      "`rfk_search_field`"
    )
  end

  def form_builder_helper_names_from(document)
    markdown_section(document, "## FormBuilder helpers").scan(/^- `(rfk_[a-z_]+)`/).flatten
  end

  def markdown_section(document, heading)
    _before, section = document.split(heading, 2)
    raise "Missing markdown heading: #{heading}" unless section

    section.split(/\n(?=##?\s)/, 2).first
  end
end
