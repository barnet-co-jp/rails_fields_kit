# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "focused visual docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:setup_doctor_output_review) { read_doc("doc/setup_doctor_output_review.md") }
  let(:tom_select_rich_option_review) { read_doc("doc/tom_select_rich_option_review.html") }
  let(:tom_select_source_fallback_review) { read_doc("doc/tom_select_source_fallback_review.html") }

  it "keeps setup doctor output review packaged as diagnostic evidence rather than field UI review" do
    expect(specification.files).to include("doc/setup_doctor_output_review.md")
    expect(readme).to include(
      "[`doc/setup_doctor_output_review.md`](doc/setup_doctor_output_review.md)",
      "CLI diagnostic evidence review"
    )
    expect(visual_references).to include(
      "[`setup_doctor_output_review.md`](setup_doctor_output_review.md)",
      "release-evidence lane for CLI diagnostic readability",
      "Keep it separate from the field UI visual references",
      "without changing setup doctor runtime behavior or output wording"
    )
    expect(setup_doctor_output_review).to include(
      "Setup Doctor Output Review",
      "This artifact is not production UI and does not define setup doctor runtime behavior",
      "Keep command behavior, wording source, host app setup policy, and auto-fix decisions outside this artifact"
    )
  end

  it "keeps rich option companion review packaged without promoting endpoint or CSS ownership" do
    expect(specification.files).to include("doc/tom_select_rich_option_review.html")
    expect(visual_references).to include(
      "[`tom_select_rich_option_review.html`](tom_select_rich_option_review.html)",
      "label, description, and badge readability",
      "endpoint payload shape, option mapping behavior, search execution, production CSS, and authorization outside the static artifact"
    )
    expect(tom_select_rich_option_review).to include(
      "Rails Fields Kit Tom Select Rich Option Review"
    )
  end

  it "keeps source fallback companion review packaged without changing enum or endpoint behavior" do
    expect(specification.files).to include("doc/tom_select_source_fallback_review.html")
    expect(visual_references).to include(
      "[`tom_select_source_fallback_review.html`](tom_select_source_fallback_review.html)",
      "explicit enum source / remote label fallback review lane",
      "not a new API or endpoint behavior spec"
    )
    expect(tom_select_source_fallback_review).to include(
      "Tom Select Source and Fallback Review",
      "Enum select boundary",
      "Controller helper fallback"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
