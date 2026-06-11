# frozen_string_literal: true

require "spec_helper"

RSpec.describe "textarea autosize release evidence docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }
  let(:boundary_doc) { File.read(File.expand_path("../doc/textarea_autosize.md", __dir__)) }
  let(:evidence_doc_path) { File.expand_path("../doc/textarea_autosize_release_evidence.md", __dir__) }
  let(:evidence_doc) { File.read(evidence_doc_path) }

  it "keeps the release evidence guide packaged and reachable from the autosize boundary docs" do
    expect(specification.files).to include("doc/textarea_autosize_release_evidence.md")
    expect(readme).to include("doc/textarea_autosize_release_evidence.md")
    expect(boundary_doc).to include("[`textarea_autosize_release_evidence.md`](textarea_autosize_release_evidence.md)")
  end

  it "keeps the guide focused on representative rfk_text_area evidence, not built-in autosize behavior" do
    expect(evidence_doc).to include(
      "representative evidence for the current `rfk_text_area` autosize boundary",
      "Rails Fields Kit renders the native textarea wrapper and accessibility wiring",
      "autosize remains host-app owned",
      "first render",
      "edit-form redisplay",
      "validation rerender",
      "optional host-owned autosize enhancement",
      "no built-in `autosize:` option"
    )
  end
end
