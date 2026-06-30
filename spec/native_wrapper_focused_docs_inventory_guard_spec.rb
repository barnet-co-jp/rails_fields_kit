# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "native wrapper focused docs inventory guard" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(repo_root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_native_wrapper_doc("README.md") }
  let(:field_helpers) { read_native_wrapper_doc("doc/field_helpers.md") }
  let(:public_api) { read_native_wrapper_doc("doc/public_api.md") }
  let(:native_contact_fields) { read_native_wrapper_doc("doc/native_contact_fields.md") }
  let(:native_numeric_fields) { read_native_wrapper_doc("doc/native_numeric_fields.md") }

  it "keeps contact native wrapper docs packaged, routed, and scoped" do
    native_wrapper_readme_section = markdown_section(readme, "## Choosing a helper")
    field_helpers_chooser = markdown_section(field_helpers, "## Quick chooser")
    public_api_form_builder_helpers = markdown_section(public_api, "## FormBuilder helpers")

    expect(specification.files).to include("doc/native_contact_fields.md")
    expect(native_wrapper_readme_section).to include(
      "[`doc/native_contact_fields.md`](doc/native_contact_fields.md)",
      "`rfk_phone_field`",
      "`rfk_search_field`"
    )
    expect(field_helpers_chooser).to include(
      "[`native_contact_fields.md`](native_contact_fields.md)",
      "`rfk_email_field`",
      "`rfk_url_field`",
      "`rfk_phone_field`"
    )
    expect(public_api_form_builder_helpers).to include(
      "`rfk_email_field`",
      "`rfk_url_field`",
      "`rfk_phone_field`",
      "`rfk_search_field`",
      "[`native_contact_fields.md`](native_contact_fields.md)"
    )
    expect(native_contact_fields).to include(
      "`rfk_email_field`, `rfk_url_field`, `rfk_phone_field`, and `rfk_search_field`",
      "delegates to Rails' native `email_field` helper",
      "delegates to Rails' native `url_field` helper",
      "delegates to Rails' native `telephone_field` helper",
      "delegates to Rails' native `search_field` helper",
      "Rails Fields Kit owns the shared native wrapper contract",
      "email deliverability checks",
      "URL normalization",
      "phone-number formatting",
      "search execution",
      "remote suggestion endpoints to `rfk_search_field`"
    )
  end

  it "keeps numeric native wrapper docs packaged, routed, and scoped" do
    native_wrapper_readme_section = markdown_section(readme, "## Choosing a helper")
    field_helpers_chooser = markdown_section(field_helpers, "## Quick chooser")
    public_api_form_builder_helpers = markdown_section(public_api, "## FormBuilder helpers")

    expect(specification.files).to include("doc/native_numeric_fields.md")
    expect(native_wrapper_readme_section).to include(
      "[`doc/native_numeric_fields.md`](doc/native_numeric_fields.md)",
      "`rfk_money_field`",
      "`rfk_search_field`"
    )
    expect(field_helpers_chooser).to include(
      "[`native_numeric_fields.md`](native_numeric_fields.md)",
      "`rfk_number_field`",
      "`rfk_money_field`",
      "`rfk_percent_field`"
    )
    expect(public_api_form_builder_helpers).to include(
      "`rfk_number_field`",
      "`rfk_money_field`",
      "`rfk_percent_field`",
      "[`native_numeric_fields.md`](native_numeric_fields.md)"
    )
    expect(native_numeric_fields).to include(
      "`rfk_number_field`, `rfk_money_field`, and `rfk_percent_field`",
      "delegates to Rails' native `number_field` helper",
      "delegates to Rails' native `text_field` helper",
      "defaults the suffix to `%`",
      "Rails Fields Kit owns the shared native wrapper contract",
      "number formatting",
      "locale-specific separators",
      "rounding",
      "currency conversion",
      "decimal precision",
      "masking JavaScript"
    )
  end

  def read_native_wrapper_doc(relative_path)
    File.read(File.join(repo_root, relative_path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
