# frozen_string_literal: true

require "cgi"
require "spec_helper"

RSpec.describe "repository-local HTML anchor documentation links" do
  let(:root) { File.expand_path("..", __dir__) }

  it "keeps cross-file HTML fragment links pointed at shipped static element ids" do
    broken_links = []

    docs_sources.each do |source_path|
      source = File.read(source_path)
      source_dir = File.dirname(source_path)
      relative_source = source_path.delete_prefix("#{root}/")

      cross_file_html_fragment_links(source).each do |link_target|
        target_path, fragment = link_target.split("#", 2)
        next if fragment.nil? || fragment.empty?

        resolved_path = File.expand_path(target_path, source_dir)
        relative_target = resolved_path.delete_prefix("#{root}/")

        unless resolved_path.start_with?("#{root}/doc/") && File.file?(resolved_path)
          broken_links << "#{relative_source} -> #{link_target} (missing repository-local target)"
          next
        end

        ids = html_ids(File.read(resolved_path))
        decoded_fragment = CGI.unescape(fragment)

        next if ids.include?(decoded_fragment)

        broken_links << "#{relative_source} -> #{relative_target}##{fragment} (missing id #{decoded_fragment.inspect})"
      end
    end

    expect(broken_links).to eq([])
  end

  def docs_sources
    [File.join(root, "README.md")] + Dir.glob(File.join(root, "doc/**/*.{md,html}"))
  end

  def cross_file_html_fragment_links(source)
    markdown_links = source.scan(/\]\(([^)\s]+\.html#[^)\s]+)\)/).flatten
    html_links = source.scan(/href=["']([^"']+\.html#[^"']+)["']/).flatten

    (markdown_links + html_links).reject do |link_target|
      link_target.start_with?("http://", "https://", "//") || link_target.include?("://")
    end
  end

  def html_ids(source)
    source.scan(/\sid=["']([^"']+)["']/i).flatten
  end
end
