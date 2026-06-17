# frozen_string_literal: true

require "spec_helper"

RSpec.describe "native constraint attribute evidence docs" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:sample_app_results) { read_doc("doc/sample_app_results.md") }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:public_api) { read_doc("doc/public_api.md") }

  def read_doc(path)
    File.read(File.join(repo_root, path))
  end

  it "keeps the sample app evidence lane focused on native constraint pass-through" do
    expect(sample_app_results).to include(
      "## Native constraint attribute checks",
      "native helper constraint pass-through",
      "records input attributes reaching the rendered input, not a new validation UI or masking contract"
    )

    ["maxlength", "minlength", "pattern", "autocomplete", "inputmode"].each do |attribute|
      expect(sample_app_results).to include("`#{attribute}`")
    end

    expect(sample_app_results).to include(
      "any checked `required`, `disabled`, or `readonly` state stayed limited to ordinary native input state",
      "validation copy, browser validation-message behavior, masking, character counters, and server-side validation remained host-app responsibilities"
    )
  end

  it "keeps the visual route aligned with the public API boundary" do
    expect(visual_references).to include(
      "For native constraint attribute review, use the native helper reference's constraint boundary lane.",
      "It keeps `maxlength`, `pattern`, `inputmode`, and `autocomplete` visible as ordinary native attributes",
      "browser validation copy, masking, formatting, normalization, and autocomplete policy with the host app"
    )

    expect(public_api).to include(
      "Native wrapper helpers pass ordinary Rails/native input attributes such as `maxlength`, `minlength`, `pattern`, `required`, `autocomplete`, and `inputmode`",
      "Rails Fields Kit owns the wrapper, hint, error, affix, and accessibility wiring around that input",
      "browser validation-message policy, browser validation behavior, server-side validation rules",
      "remain host-app responsibility"
    )
  end
end
