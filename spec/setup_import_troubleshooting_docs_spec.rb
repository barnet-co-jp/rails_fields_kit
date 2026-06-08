# frozen_string_literal: true

require "spec_helper"

RSpec.describe "setup import troubleshooting docs" do
  let(:setup_doc_path) { File.expand_path("../doc/setup.md", __dir__) }
  let(:setup_doc) { File.read(setup_doc_path) }

  it "keeps unresolved import troubleshooting pointed at public entrypoints" do
    troubleshooting = markdown_section(setup_doc, "### Troubleshoot unresolved imports")

    expect(troubleshooting).to include(
      "import { TomSelectController } from \"rails_fields_kit\"",
      "package-root contract helper import",
      "rails_fields_kit/index.js",
      "import TomSelectController from \"rails_fields_kit/tom_select_controller\"",
      "rails_fields_kit/tom_select_controller.js",
      "rails-fields-kit--tom-select",
      "Tom Select is missing or unstyled",
      "Changing the Rails Fields Kit import path does not install Tom Select",
      "generated host-app setup note"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
