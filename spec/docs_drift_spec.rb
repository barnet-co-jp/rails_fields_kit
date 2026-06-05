# frozen_string_literal: true

require "spec_helper"

RSpec.describe "docs drift guards" do
  def read_doc(path)
    File.read(File.expand_path("../#{path}", __dir__))
  end

  def expect_all_tokens(document, tokens)
    tokens.each do |token|
      expect(document).to include(token)
    end
  end

  it "keeps native wrapper affix evidence aligned between checklist and results" do
    docs = {
      "sample app checklist" => read_doc("doc/sample_app_checklist.md"),
      "sample app results" => read_doc("doc/sample_app_results.md")
    }

    docs.each do |name, document|
      aggregate_failures(name) do
        expect_all_tokens(document, [
          "control_html:",
          "prefix_html:",
          "suffix_html:",
          "without changing the input value or submitted param shape",
          "accessibility: false",
          "automatic aria wiring"
        ])
      end
    end
  end

  it "keeps TableRenderer custom registry docs aligned with public method names and boundaries" do
    public_api = read_doc("doc/public_api.md")
    table_adapters = read_doc("doc/table_adapters.md")

    expect_all_tokens(public_api, [
      "RailsFieldsKit::TableRenderer.field_helpers",
      "RailsFieldsKit::TableRenderer.helper_for",
      "RailsFieldsKit::TableRenderer.registered_field_type?",
      "RailsFieldsKit::TableRenderer.register_field_helper",
      "RailsFieldsKit::TableRenderer.reset_field_helpers!"
    ])

    expect_all_tokens(table_adapters, [
      "TableRenderer.register_field_helper",
      "TableRenderer.reset_field_helpers!",
      "TableRenderer.registered_field_type?",
      "`known_types` is intentionally limited to the built-in factory family",
      "does not include custom mappings added with `TableRenderer.register_field_helper`",
      "For validation, keep the two surfaces separate",
      "renderer registry can render it, including custom registrations"
    ])
  end
end
