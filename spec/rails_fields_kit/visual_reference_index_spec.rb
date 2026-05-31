# frozen_string_literal: true

require "spec_helper"

RSpec.describe "visual reference documentation index" do
  it "keeps the markdown map and HTML index aligned" do
    markdown_links = visual_reference_links(markdown_map)
    index_links = visual_reference_links(html_index)

    expect(index_links).to eq(markdown_links)
  end

  it "keeps the HTML summary count aligned with the individual references" do
    reference_count = visual_reference_links(markdown_map).size
    summary_count = html_index.match(%r{<strong>(?<count>\d+)</strong>\s*<span>individual references</span>}m)[:count].to_i

    expect(summary_count).to eq(reference_count)
  end

  private

  def visual_reference_links(source)
    source.scan(/href="([^"]+_visual_reference\.html)"|\[.*?\]\(([^)]+_visual_reference\.html)\)/)
      .flatten
      .compact
      .uniq
      .sort
  end

  def markdown_map
    File.read(repository_root.join("doc/visual_references.md"))
  end

  def html_index
    File.read(repository_root.join("doc/visual_reference_index.html"))
  end

  def repository_root
    Pathname.new(File.expand_path("../..", __dir__))
  end
end
