# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "focused docs inventory and release guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:release_doc) { read_doc("doc/release.md") }
  let(:native_numeric_fields) { read_doc("doc/native_numeric_fields.md") }
  let(:native_contact_fields) { read_doc("doc/native_contact_fields.md") }
  let(:final_release_checklist) { read_doc("doc/final_release_checklist.md") }

  it "keeps native numeric and contact focused docs packaged and routed from public docs" do
    expect(specification.files).to include(
      "doc/native_numeric_fields.md",
      "doc/native_contact_fields.md"
    )

    expect(readme).to include(
      "[`doc/native_numeric_fields.md`](doc/native_numeric_fields.md)",
      "[`doc/native_contact_fields.md`](doc/native_contact_fields.md)",
      "numeric, contact, phone, URL, email, or native search inputs"
    )

    expect(public_api).to include(
      "[`native_numeric_fields.md`](native_numeric_fields.md)",
      "[`native_contact_fields.md`](native_contact_fields.md)",
      "`rfk_number_field`",
      "`rfk_money_field`",
      "`rfk_percent_field`",
      "`rfk_email_field`",
      "`rfk_url_field`",
      "`rfk_phone_field`",
      "`rfk_search_field`"
    )
  end

  it "keeps native wrapper focused docs scoped to thin helper responsibility" do
    expect(native_numeric_fields).to include(
      "thin native wrapper helpers for numeric-looking inputs",
      "shared wrapper, label, hint, error, affix, and accessibility wiring",
      "number formatting, locale-specific separators, rounding, currency conversion",
      "Rails Fields Kit does not normalize numeric strings, parse currency values, format submitted params, or add masking JavaScript"
    )

    expect(native_contact_fields).to include(
      "thin native wrapper helpers for browser-native contact and search inputs",
      "shared wrapper, label, hint, error, affix, and accessibility wiring",
      "email deliverability checks, URL normalization, phone-number formatting, country-specific phone policy, search execution",
      "Rails Fields Kit does not normalize contact values, validate deliverability, parse phone numbers, run searches, or attach remote suggestion endpoints"
    )
  end

  it "keeps the final release checklist packaged and routed as release-prep evidence" do
    expect(specification.files).to include("doc/final_release_checklist.md")
    expect(release_doc).to include(
      "`doc/final_release_checklist.md`",
      "reviewer-facing and GitHub-release-facing summary",
      "sample app evidence log or a scoped PR comment"
    )

    expect(final_release_checklist).to include(
      "Use this checklist immediately before publishing a gem release",
      "GitHub Actions CI run passed for the release commit",
      "Compare the release note draft with `CHANGELOG.md` before publishing",
      "browser-capable visual evidence",
      "sample app verification",
      "package-root helper evidence guide",
      "Do not use `PASS` for GitHub Actions success, source review, static diff review, or a successful package build"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
