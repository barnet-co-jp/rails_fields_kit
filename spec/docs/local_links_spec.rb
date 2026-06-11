# frozen_string_literal: true

require "spec_helper"
require "find"
require "pathname"
require "uri"

RSpec.describe "repository-local documentation links" do
  repository_root = Pathname.new(File.expand_path("../..", __dir__))
  documentation_paths = [repository_root.join("README.md")]
  Find.find(repository_root.join("doc")) do |path|
    next unless path.end_with?(".md", ".html")

    documentation_paths << Pathname.new(path)
  end

  def strip_code_fences(text)
    text.gsub(/```.*?```/m, "")
  end

  def markdown_targets(text)
    strip_code_fences(text).scan(/(?<!!)\[[^\]]+\]\(([^)]+)\)/).flatten
  end

  def html_targets(text)
    text.scan(/\b(?:href|src)=["']([^"']+)["']/i).flatten
  end

  def html_ids(text)
    text.scan(/\bid=["']([^"']+)["']/i).flatten
  end

  def target_reference(target)
    target = target.strip
    target[/\A<([^>]+)>/, 1] || target.split(/\s+/, 2).first
  end

  def local_target?(target)
    target = target_reference(target)
    return false if target.empty? || target.start_with?("#", "//")
    return false if target.match?(/\A[a-z][a-z0-9+.-]*:/i)

    true
  end

  def target_path(target)
    target = target_reference(target)
    target = target.split(/[?#]/, 2).first
    URI::DEFAULT_PARSER.unescape(target)
  end

  def same_file_html_fragment?(source_path, target)
    target = target_reference(target)
    return false unless source_path.extname == ".html"
    return false unless target.include?("#")
    return false if target.empty? || target.start_with?("//")
    return false if target.match?(/\A[a-z][a-z0-9+.-]*:/i)

    destination_path = target_path(target)
    destination = if destination_path.empty?
      source_path
    else
      source_path.dirname.join(destination_path).cleanpath
    end

    destination == source_path.cleanpath
  end

  def target_fragment(target)
    target = target_reference(target)
    fragment = target.split("#", 2).last
    return nil if fragment.nil? || fragment.empty? || fragment == target

    URI::DEFAULT_PARSER.unescape(fragment.split(/[?\s]/, 2).first)
  end

  it "points repository-local links at existing files" do
    broken_links = []

    documentation_paths.each do |source_path|
      targets = markdown_targets(source_path.read) + html_targets(source_path.read)

      targets.each do |target|
        next unless local_target?(target)

        destination = source_path.dirname.join(target_path(target)).cleanpath
        next if destination.to_s.start_with?(repository_root.to_s) && destination.exist?

        broken_links << "#{source_path.relative_path_from(repository_root)} -> #{target}"
      end
    end

    expect(broken_links).to be_empty, "Broken repository-local documentation links:\n#{broken_links.join("\n")}"
  end

  it "points same-file HTML fragment links at existing element ids" do
    missing_anchors = []

    documentation_paths.select { |source_path| source_path.extname == ".html" }.each do |source_path|
      source = source_path.read
      ids = html_ids(source)

      html_targets(source).each do |target|
        next unless same_file_html_fragment?(source_path, target)

        fragment = target_fragment(target)
        next if fragment && ids.include?(fragment)

        missing_anchors << "#{source_path.relative_path_from(repository_root)} -> #{target}"
      end
    end

    expect(missing_anchors).to be_empty, "Broken same-file HTML fragment links:\n#{missing_anchors.join("\n")}"
  end
end
