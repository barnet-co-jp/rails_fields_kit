# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "native wrapper docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }

  def read_doc(path)
    File.read(File.join(root, path))
  end

  let(:readme) { read_doc("README.md") }
  let(:field_helpers) { read_doc("doc/field_helpers.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:native_contact_fields) { read_doc("doc/native_contact_fields.md") }
  let(:native_numeric_fields) { read_doc("doc/native_numeric_fields.md") }

  it "keeps native contact wrapper docs packaged and scoped" do
    expect(specification.files).to include("doc/native_contact_fields.md")
    expect(readme).to include("doc/native_contact_fields.md")
    expect(field_helpers).to include("native_contact_fields.md")
    expect(public_api).to include("native_contact_fields.md")

    expect(native_contact_fields).to include("rfk_email_field")
    expect(native_contact_fields).to include("rfk_url_field")
    expect(native_contact_fields).to include("rfk_phone_field")
    expect(native_contact_fields).to include("rfk_search_field")
    expect(native_contact_fields).to include("delegates to Rails' native `email_field` helper")
    expect(native_contact_fields).to include("delegates to Rails' native `url_field` helper")
    expect(native_contact_fields).to include("delegates to Rails' native `telephone_field` helper")
    expect(native_contact_fields).to include("defaults `autocomplete` to `tel`")
    expect(native_contact_fields).to include("delegates to Rails' native `search_field` helper")
    expect(native_contact_fields).to include("email deliverability checks")
    expect(native_contact_fields).to include("URL normalization")
    expect(native_contact_fields).to include("phone-number formatting")
    expect(native_contact_fields).to include("search execution")
    expect(native_contact_fields).to include("does not normalize contact values")
    expect(native_contact_fields).to include("run searches")
    expect(native_contact_fields).to include("remote suggestion endpoints")
  end

  it "keeps native numeric wrapper docs packaged and scoped" do
    expect(specification.files).to include("doc/native_numeric_fields.md")
    expect(readme).to include("doc/native_numeric_fields.md")
    expect(field_helpers).to include("native_numeric_fields.md")
    expect(public_api).to include("native_numeric_fields.md")

    expect(native_numeric_fields).to include("rfk_number_field")
    expect(native_numeric_fields).to include("rfk_money_field")
    expect(native_numeric_fields).to include("rfk_percent_field")
    expect(native_numeric_fields).to include("delegates to Rails' native `number_field` helper")
    expect(native_numeric_fields).to include("delegates to Rails' native `text_field` helper")
    expect(native_numeric_fields).to include("defaults `inputmode` to `decimal`")
    expect(native_numeric_fields).to include("uses `currency:` as the prefix")
    expect(native_numeric_fields).to include("defaults the suffix to `%`")
    expect(native_numeric_fields).to include("number formatting")
    expect(native_numeric_fields).to include("rounding")
    expect(native_numeric_fields).to include("currency conversion")
    expect(native_numeric_fields).to include("locale-specific separators")
    expect(native_numeric_fields).to include("does not normalize numeric strings")
    expect(native_numeric_fields).to include("add masking JavaScript")
  end
end
