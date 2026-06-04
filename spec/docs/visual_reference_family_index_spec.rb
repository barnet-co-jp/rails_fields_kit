# frozen_string_literal: true

require "spec_helper"

RSpec.describe "visual reference family index" do
  let(:repo_root) { File.expand_path("../..", __dir__) }
  let(:doc_dir) { File.join(repo_root, "doc") }
  let(:visual_references_path) { File.join(doc_dir, "visual_references.md") }
  let(:visual_references) { File.read(visual_references_path) }

  it "links every maintained visual reference HTML artifact from the Markdown map" do
    visual_reference_files = Dir.glob(File.join(doc_dir, "*visual_reference*.html")).map { |path| File.basename(path) }.sort
    linked_files = visual_reference_links_from(visual_references).sort

    expect(visual_reference_files).not_to be_empty
    expect(linked_files).to include(*visual_reference_files)
  end

  it "does not link missing visual reference HTML artifacts from the Markdown map" do
    linked_files = visual_reference_links_from(visual_references)

    linked_files.each do |file_name|
      expect(File.exist?(File.join(doc_dir, file_name))).to be(true), "expected doc/#{file_name} to exist"
    end
  end

  def visual_reference_links_from(markdown)
    markdown
      .scan(/\]\(([^)#?]*visual_reference[^)#?]*\.html)\)/)
      .flatten
      .map { |link| File.basename(link) }
      .uniq
  end
end
