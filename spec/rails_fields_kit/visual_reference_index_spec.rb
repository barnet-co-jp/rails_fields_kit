# frozen_string_literal: true

require "spec_helper"

RSpec.describe "visual reference documentation index" do
  it "keeps the markdown map and HTML index aligned" do
    markdown_links = visual_reference_links(markdown_map)
    index_links = visual_reference_links(html_index)

    expect(index_links).to eq(markdown_links)
  end

  it "keeps each mapped reference available from the quick links or review cards" do
    markdown_reference_links.each do |reference|
      next if reference == "visual_reference_index.html"

      expect(index_link_occurrences(reference)).to be_positive, "expected #{reference} to be linked from the HTML index"
    end
  end

  it "keeps every review card tied to a mapped visual reference" do
    expect(review_card_links).to match_array(markdown_reference_links - ["visual_reference_index.html"])
  end

  it "keeps the HTML summary focused on the maintained map, helper families, and landed references" do
    expect(html_index).to include("Use visual_references.md as the maintained artifact list.")
    expect(html_index).to include("Choose by helper family before opening a focused lane.")
    expect(html_index).to include("List only references that have landed on main.")
  end

  it "keeps the README docs map pointed at the maintained visual reference family" do
    expect(readme_visual_reference_row).to include("[`doc/visual_references.md`](doc/visual_references.md)")
    expect(readme_visual_reference_row).not_to match(%r{doc/[^\s|]*_visual_reference\.html})

    [
      "visual reference family",
      "Tom Select",
      "text override",
      "native helper",
      "table metadata",
      "saved-search token"
    ].each do |representative_term|
      expect(readme_visual_reference_row).to include(representative_term),
        "expected README visual reference row to mention #{representative_term.inspect}"
    end
  end

  private

  def visual_reference_links(source)
    source.scan(/href="([^"]+_visual_reference\.html)"|\[.*?\]\(([^)]+_visual_reference\.html)\)/)
      .flatten
      .compact
      .uniq
      .sort
  end

  def markdown_reference_links
    visual_reference_links(markdown_map)
  end

  def review_card_links
    html_index.scan(/<a class="reference-link" href="([^"]+_visual_reference\.html)">/)
      .flatten
      .sort
  end

  def index_link_occurrences(reference)
    html_index.scan(/href="#{Regexp.escape(reference)}"/).size
  end

  def readme_visual_reference_row
    readme.lines.find { |line| line.include?("doc/visual_references.md") } || ""
  end

  def markdown_map
    File.read(repository_root.join("doc/visual_references.md"))
  end

  def html_index
    File.read(repository_root.join("doc/visual_reference_index.html"))
  end

  def readme
    File.read(repository_root.join("README.md"))
  end

  def repository_root
    Pathname.new(File.expand_path("../..", __dir__))
  end
end
