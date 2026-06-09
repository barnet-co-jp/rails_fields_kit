# frozen_string_literal: true

require "spec_helper"

RSpec.describe "README import troubleshooting guidance" do
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }
  let(:setup_doc) { File.read(File.expand_path("../doc/setup.md", __dir__)) }

  it "keeps README direct import troubleshooting pointed at the setup guide" do
    expect(readme).to include(
      "If either documented import path cannot be resolved",
      "[`doc/setup.md#troubleshoot-unresolved-imports`](doc/setup.md#troubleshoot-unresolved-imports)",
      "package-root import or direct controller import is failing"
    )

    expect(setup_doc).to include(
      "## Troubleshoot unresolved imports",
      "package-root import",
      "direct controller import"
    )
  end
end
