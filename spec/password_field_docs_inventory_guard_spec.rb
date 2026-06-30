# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "password field docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:password_field) { read_doc("doc/password_field.md") }

  it "keeps password field focused docs packaged and routed from public API" do
    form_builder_helpers = markdown_section(public_api, "## FormBuilder helpers")

    expect(specification.files).to include("doc/password_field.md")
    expect(form_builder_helpers).to include(
      "`rfk_password_field`",
      "[`password_field.md`](password_field.md)",
      "password-specific non-goals"
    )
    expect(password_field).to include(
      "`rfk_password_field`",
      "native `type=\"password\"` input",
      "wrapper, label, hint, error, affix, and accessibility wiring",
      "It does not add a password visibility toggle.",
      "It does not add a password strength meter.",
      "It does not decide credential policy, password validation rules, or autocomplete policy.",
      "It does not change authentication workflow or credential storage."
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
