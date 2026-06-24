# frozen_string_literal: true

RSpec.describe RailsFieldsKit::Configuration, "documentation" do
  CONFIGURATION_DOC_PATH = File.expand_path("../../doc/configuration.md", __dir__)

  def configuration_markdown
    File.read(CONFIGURATION_DOC_PATH)
  end

  def configuration_keys
    described_class.new.instance_variables.map { |name| name.to_s.delete_prefix("@") }.sort
  end

  def quick_reference_rows
    configuration_markdown.each_line.each_with_object({}) do |line, rows|
      next unless line.start_with?("| `")

      cells = line.strip.split("|").map(&:strip)
      key = cells[1].match(/`([^`]+)`/)&.[](1)
      next unless key

      rows[key] = {
        default: cells[2],
        field_override: cells[3],
        applies_to: cells[4],
        notes: cells[5]
      }
    end
  end

  def detailed_section_keys
    configuration_markdown.scan(/^### `([^`]+)`$/).flatten.sort
  end

  it "lists every public configuration key in the quick reference" do
    expect(quick_reference_rows.keys.sort).to eq(configuration_keys)
  end

  it "keeps a detailed section for every public configuration key" do
    expect(detailed_section_keys).to eq(configuration_keys)
  end

  it "documents field-level override boundaries for every configuration key" do
    expect(quick_reference_rows.transform_values { |row| row[:field_override] }).to eq(
      "controller_name" => "none",
      "default_query_param" => "`query_param:`",
      "default_selected_param" => "`selected_param:`",
      "default_selected_multiple_param" => "`selected_multiple_param:`",
      "default_create_param" => "`create_param:`",
      "default_value_field" => "`value_field:`",
      "default_label_field" => "`label_field:`",
      "default_search_field" => "`search_field:`",
      "default_option_description_field" => "`option_description_field:`",
      "default_option_badge_field" => "`option_badge_field:`",
      "default_plugins" => "`plugins:`",
      "default_min_length" => "`min_length:`",
      "default_max_options" => "`max_options:`",
      "default_load_throttle" => "`load_throttle:`",
      "default_preload" => "`preload:`",
      "default_open_on_focus" => "`open_on_focus:`",
      "default_close_after_select" => "`close_after_select:`",
      "default_hide_selected" => "`hide_selected:`",
      "default_persist" => "`persist:`",
      "default_no_results_text" => "`no_results_text:`",
      "default_loading_text" => "`loading_text:`",
      "default_create_text" => "`create_text:`",
      "wrapper_class" => "`wrapper_html:`",
      "label_class" => "`label_html:`",
      "hint_class" => "`hint_html:`",
      "error_class" => "`error_html:`",
      "field_error_class" => "none",
      "control_class" => "`control_html:`",
      "prefix_class" => "`prefix_html:`",
      "suffix_class" => "`suffix_html:`"
    )
  end

  it "keeps sentinel and nil default boundaries documented without comparing localized copy" do
    expect(quick_reference_rows.values_at(
      "default_no_results_text",
      "default_loading_text",
      "default_create_text"
    ).map { |row| row[:default] }).to all(eq("bundled locale-aware copy"))

    expect(quick_reference_rows.values_at(
      "default_max_options",
      "default_load_throttle",
      "default_preload",
      "default_open_on_focus",
      "default_close_after_select",
      "default_hide_selected",
      "default_persist",
      "default_option_description_field",
      "default_option_badge_field"
    ).map { |row| row[:default] }).to all(eq("`nil`"))
  end
end
