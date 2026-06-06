# frozen_string_literal: true

require "spec_helper"

RSpec.describe "generated setup note diagnostics" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:setup_doc) { File.read(File.join(repo_root, "doc/setup.md")) }
  let(:generated_setup_note) do
    File.read(File.join(repo_root, "lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md"))
  end

  it "keeps importmap target drift diagnostics visible without turning them into auto-fix policy" do
    expect(setup_doc).to include(
      "point at the documented entrypoints",
      "Missing pins, unexpected targets, and pins without explicit targets are reported as read-only diagnostics",
      "does not rewrite `config/importmap.rb`",
      "validate bundler aliases",
      "host app's non-importmap policy"
    )

    expect(generated_setup_note).to include(
      "importmap pin target diagnostics",
      "Use the doctor output as a read-only prompt",
      "missing importmap pins",
      "unexpected Rails Fields Kit pin targets",
      "target-omitted pins",
      "bundler aliases remain host-app setup responsibilities"
    )
  end
end
