# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "TypeScript declaration release evidence docs guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:declaration_evidence) { read_doc("doc/typescript_declaration_release_evidence.md") }

  it "keeps the declaration evidence guide packaged and routed from JavaScript exports" do
    javascript_exports = markdown_section(public_api, "## JavaScript exports")

    expect(specification.files).to include("doc/typescript_declaration_release_evidence.md")
    expect(javascript_exports).to include(
      "TypeScript declaration metadata",
      "[`typescript_declaration_release_evidence.md`](typescript_declaration_release_evidence.md)",
      "package metadata and editor assistance",
      "do not add a separate runtime API"
    )
  end

  it "keeps declaration evidence scoped away from runtime and host-app TypeScript policy" do
    expect(declaration_evidence).to include(
      "package metadata and editor-assistance lane",
      "does not define a new runtime API",
      "require a host app to use TypeScript",
      "set a host-app `tsconfig` policy",
      "Keep `public_api.md#javascript-exports` as the helper and controller inventory",
      "Do not duplicate the full export table here",
      "Runtime import behavior checked separately",
      "Host-app `tsconfig` policy changed: no",
      "Declaration visibility evidence does not replace JavaScript runtime import checks"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
