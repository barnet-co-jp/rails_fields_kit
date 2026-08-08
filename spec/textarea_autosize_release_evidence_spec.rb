# frozen_string_literal: true

require "spec_helper"

RSpec.describe "textarea autosize release evidence docs" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }
  let(:product_profile) { File.read(File.expand_path("../Product Profile.md", __dir__)) }
  let(:release_doc) { File.read(File.expand_path("../doc/release.md", __dir__)) }
  let(:boundary_doc) { File.read(File.expand_path("../doc/textarea_autosize.md", __dir__)) }
  let(:evidence_doc_path) { File.expand_path("../doc/textarea_autosize_release_evidence.md", __dir__) }
  let(:evidence_doc) { File.read(evidence_doc_path) }

  it "keeps the release evidence guide packaged and routed through the autosize docs inventory" do
    expect(specification.files).to include("doc/textarea_autosize_release_evidence.md")
    expect(boundary_doc).to include("[`textarea_autosize_release_evidence.md`](textarea_autosize_release_evidence.md)")
    expect(evidence_doc).to include(
      "`doc/textarea_autosize.md` is the source of truth",
      "autosize remains host-app owned",
      "no built-in `autosize:` option"
    )
    expect(readme).to include(
      "[`doc/release.md`](doc/release.md)",
      "[`doc/textarea_autosize_release_evidence.md`](doc/textarea_autosize_release_evidence.md)"
    )
    expect(product_profile).to include(
      "`doc/textarea_autosize.md`: focused `rfk_text_area` autosize boundary",
      "`doc/textarea_autosize_release_evidence.md`: release and sample-app evidence guide"
    )
    expect(release_doc).to include(
      "`doc/textarea_autosize.md`",
      "`doc/textarea_autosize_release_evidence.md`"
    )
  end

  it "keeps the guide focused on representative rfk_text_area evidence" do
    expect(evidence_doc).to include(
      "representative evidence for the current `rfk_text_area` autosize boundary",
      "Rails Fields Kit renders the native textarea wrapper and accessibility wiring",
      "first render",
      "edit-form redisplay",
      "validation rerender",
      "optional host-owned autosize enhancement"
    )
  end
end
