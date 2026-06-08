# frozen_string_literal: true

require "spec_helper"

RSpec.describe "native constraint attribute evidence docs" do
  def repo_path(relative_path)
    File.expand_path("../#{relative_path}", __dir__)
  end

  def read_doc(relative_path)
    File.read(repo_path(relative_path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end

  let(:public_api) { read_doc("doc/public_api.md") }
  let(:field_helpers) { read_doc("doc/field_helpers.md") }
  let(:final_release_checklist) { read_doc("doc/final_release_checklist.md") }
  let(:sample_app_results) { read_doc("doc/sample_app_results.md") }
  let(:native_constraint_lane) { markdown_section(sample_app_results, "## Native constraint attribute checks") }

  it "keeps native constraint evidence scoped to pass-through and host-app validation ownership" do
    expect(public_api).to include(
      "Native wrapper helpers pass ordinary Rails/native input attributes",
      "`maxlength`, `minlength`, `pattern`, `required`, `autocomplete`, and `inputmode`",
      "character counters, masking, browser validation-message policy, browser validation behavior, server-side validation rules"
    )

    expect(field_helpers).to include(
      "Native wrapper helpers also pass ordinary Rails field options to the rendered input",
      "`maxlength:`, `minlength:`, `pattern:`, `required:`, `autocomplete:`, `inputmode:`, `disabled:`, or `readonly:`",
      "Rails Fields Kit does not add character counters, input masks, browser validation-message policy, or server-side validation rules"
    )

    expect(native_constraint_lane).to include(
      "input attributes reaching the rendered input, not a new validation UI or masking contract",
      "`maxlength` or `minlength`",
      "`pattern`",
      "`autocomplete`",
      "`inputmode`",
      "`required`, `disabled`, or `readonly`",
      "ordinary native input state",
      "validation copy, browser validation-message behavior, masking, character counters, and server-side validation remained host-app responsibilities"
    )

    expect(final_release_checklist).to include(
      "Complete `doc/sample_app_results.md`",
      "Confirm one representative native helper lane",
      "Confirm one representative native helper customization lane"
    )
  end
end
