# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "setup doctor output review inventory" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:readme_path) { File.expand_path("../README.md", __dir__) }
  let(:readme) { File.read(readme_path) }
  let(:review_artifact_path) { File.expand_path("../doc/setup_doctor_output_review.md", __dir__) }
  let(:review_artifact) { File.read(review_artifact_path) }

  it "ships the setup doctor output review artifact named by the README docs map" do
    expect(specification.files).to include("doc/setup_doctor_output_review.md")

    expect(readme).to include(
      "Check setup visibility after install",
      "[`doc/setup.md`](doc/setup.md) for `rails rails_fields_kit:doctor`",
      "[`doc/setup_doctor_output_review.md`](doc/setup_doctor_output_review.md) for CLI diagnostic evidence review"
    )
  end

  it "keeps the artifact scoped to review evidence instead of setup doctor behavior" do
    expect(review_artifact).to include(
      "# Setup Doctor Output Review",
      "This artifact is not production UI and does not define setup doctor runtime behavior.",
      "[OK]",
      "[MISSING]",
      "[MANUAL]",
      "importmap pin rails_fields_kit expected target rails_fields_kit/index.js",
      "Do not change setup doctor runtime behavior or output wording here."
    )
  end
end
