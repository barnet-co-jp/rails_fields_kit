# frozen_string_literal: true

require "spec_helper"

RSpec.describe "sample app evidence boundary docs" do
  let(:sample_app_checklist) { read_repo_file("doc/sample_app_checklist.md") }
  let(:sample_app_results) { read_repo_file("doc/sample_app_results.md") }
  let(:native_numeric_docs) { read_repo_file("doc/native_numeric_fields.md") }
  let(:native_contact_docs) { read_repo_file("doc/native_contact_fields.md") }
  let(:native_date_time_color_docs) { read_repo_file("doc/native_date_time_color_fields.md") }
  let(:file_field_docs) { read_repo_file("doc/file_field.md") }
  let(:support_boundary) { read_repo_file("doc/support_boundary.md") }
  let(:setup_docs) { read_repo_file("doc/setup.md") }
  let(:readme) { read_repo_file("README.md") }

  it "keeps native numeric and contact evidence inside wrapper and native attribute responsibilities" do
    expect(sample_app_results).to include(
      "Native wrapper and accessibility",
      "native helpers such as `rfk_text_field` and `rfk_money_field`",
      "Native helper representative wrapper and accessibility lane checks",
      "Native browser semantics visual lane checks",
      "search, email, URL, telephone, money, and percent examples",
      "formatting, masking, browser validation-message policy, autocomplete policy, locale policy, and custom picker behavior remained host-app responsibilities"
    )

    expect(native_numeric_docs).to include(
      "Rails Fields Kit owns the shared native wrapper contract",
      "generated label, hint, validation error, prefix, and suffix output",
      "aria-describedby",
      "number formatting, locale-specific separators, rounding, currency conversion",
      "Rails Fields Kit does not normalize numeric strings, parse currency values, format submitted params, or add masking JavaScript"
    )

    expect(native_contact_docs).to include(
      "Rails Fields Kit owns the shared native wrapper contract",
      "browser-native validation-message wording",
      "phone-number formatting",
      "search execution",
      "Rails Fields Kit does not normalize contact values, validate deliverability, parse phone numbers, run searches, or attach remote suggestion endpoints to `rfk_search_field`"
    )
  end

  it "keeps release-scoped native date/time/color and file evidence representative" do
    expect(sample_app_checklist).to include(
      "Choose release-scoped native helper family evidence",
      "Pick the smallest representative field and do not reproduce the public helper inventory",
      "[`native_date_time_color_fields.md`](native_date_time_color_fields.md)",
      "[`file_field.md`](file_field.md)",
      "Source review alone must stay `SOURCE REVIEW ONLY` or `DEFERRED`, never `PASS`"
    )

    expect(sample_app_results).to include(
      "Release-scoped native family evidence",
      "Representative helper / field:",
      "Attributes or Rails options actually checked:",
      "doc/native_date_time_color_fields.md",
      "doc/file_field.md",
      "Do not mark this blank record `PASS` from source review or CI success"
    )

    expect(native_date_time_color_docs).to include(
      "Ordinary Rails options such as `min:`, `max:`, `step:`",
      "browser-native picker behavior and browser support differences",
      "locale-specific formatting or parsing policy",
      "timezone conversion and storage semantics"
    )

    expect(file_field_docs).to include(
      "Ordinary Rails `file_field` options such as `accept:`, `multiple:`, `direct_upload:`",
      "multipart form setup",
      "Active Storage direct upload behavior",
      "file preview UI",
      "upload progress UI",
      "storage configuration"
    )
  end

  it "keeps the Tom Select reproducibility memo tied to host-app support ownership" do
    expect(sample_app_results).to include(
      "Tom Select environment reproducibility memo:",
      "Record the sample app route used for this check",
      "not a Rails Fields Kit package-manager policy",
      "not a Rails Fields Kit-owned Tom Select version requirement",
      "not a Rails Fields Kit CSS bundle or plugin asset policy",
      "Use this memo only to make release evidence reproducible",
      "Tom Select package version, package manager, lockfile, CDN or pin source, plugin assets, and final CSS bundle choices remain host-app responsibilities as described in `doc/support_boundary.md`"
    )

    expect(support_boundary).to include(
      "That Node 22.x / 24.x boundary is not a Tom Select runtime support policy for host applications",
      "Rails Fields Kit does not publish a required Tom Select package version, pin source, CDN source, plugin list, plugin asset policy, or package-manager lockfile policy",
      "Host applications choose and review those Tom Select runtime dependencies through their own JavaScript toolchain"
    )

    expect(setup_docs).to include(
      "Rails Fields Kit provides Rails helpers and a Stimulus controller, but it does not install Tom Select or choose a JavaScript bundling strategy",
      "Rails Fields Kit intentionally does not publish or enforce a Tom Select package version range, pin source, CDN choice, or plugin asset policy"
    )

    expect(readme).to include(
      "Rails Fields Kit ships Rails helpers, a Rails engine, a Stimulus controller, and controller-side helpers. It does not install Tom Select or choose a JavaScript bundling strategy for your app."
    )
  end

  def read_repo_file(path)
    File.read(File.expand_path("../#{path}", __dir__))
  end
end
