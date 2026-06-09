# frozen_string_literal: true

require "rubygems"
require "spec_helper"
require "uri"

RSpec.describe "Rails Fields Kit docs drift guards" do
  let(:repo_root) { File.expand_path("../..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(repo_root, "rails_fields_kit.gemspec")) }

  def read_repo_file(relative_path)
    File.read(File.join(repo_root, relative_path))
  end

  it "keeps generated setup notes pointed at setup doctor output review evidence" do
    generated_setup_note = read_repo_file("lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md")

    expect(generated_setup_note).to include(
      "Run `rails rails_fields_kit:doctor` after installation",
      "use the upstream setup doctor output review",
      "Setup doctor output review: <https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/doc/setup_doctor_output_review.md>"
    )
  end

  it "keeps repository-local markdown heading anchors from drifting" do
    markdown_paths = ["README.md", *Dir.glob(File.join(repo_root, "doc/**/*.md")).map { |path| relative_repo_path(path) }]
    markdown_anchors = markdown_paths.to_h do |relative_path|
      [relative_path, markdown_heading_anchors(read_repo_file(relative_path))]
    end
    broken_links = []

    markdown_paths.each do |source_path|
      markdown_links(read_repo_file(source_path)).each do |target|
        next if external_or_non_markdown_anchor?(target)

        target_file, anchor = target.split("#", 2)
        next if anchor.nil? || anchor.empty?

        resolved_file = if target_file.empty?
          source_path
        else
          relative_repo_path(File.expand_path(target_file, File.dirname(File.join(repo_root, source_path))))
        end

        next unless resolved_file.end_with?(".md")

        unless markdown_anchors.key?(resolved_file)
          broken_links << "#{source_path} -> #{target} points at missing markdown file #{resolved_file}"
          next
        end

        normalized_anchor = normalize_markdown_anchor(anchor)
        next if markdown_anchors.fetch(resolved_file).include?(normalized_anchor)

        broken_links << "#{source_path} -> #{target} is missing ##{normalized_anchor} in #{resolved_file}"
      end
    end

    expect(broken_links).to be_empty, broken_links.join("\n")
  end

  it "keeps the table group FormBuilder split implementation discoverable" do
    development_doc = read_repo_file("doc/development.md")
    table_group_docs = read_repo_file("doc/table_group_html.md")
    table_group_source = read_repo_file("lib/rails_fields_kit/form_builder_table_groups.rb")

    expect(specification.files).to include(
      "doc/table_group_html.md",
      "lib/rails_fields_kit/form_builder_table_groups.rb"
    )

    expect(table_group_source).to include(
      "def rfk_table_filters(columns, group_html: nil)",
      "def rfk_table_cell_editors(columns, group_html: nil)",
      "RailsFieldsKit::TableMetadata.render_filters",
      "RailsFieldsKit::TableMetadata.render_cell_editors"
    )

    expect(table_group_docs).to include(
      "`lib/rails_fields_kit/form_builder_table_groups.rb`",
      "`RailsFieldsKit::FormBuilder`",
      "Check that split definition before treating the older base helper file as the complete table helper surface."
    )

    expect(development_doc).to include(
      "When checking the table FormBuilder helper surface",
      "read `lib/rails_fields_kit/form_builder.rb` together with `lib/rails_fields_kit/form_builder_table_groups.rb`",
      "The base file alone does not show the full `group_html:` surface"
    )
  end

  def markdown_links(source)
    source.scan(/(?<!!)\[[^\]]+\]\(([^)]+)\)/).flatten.map do |target|
      target.strip.sub(/\A<(.+)>\z/, "\\1").split(/\s+/, 2).first
    end
  end

  def markdown_heading_anchors(source)
    counts = Hash.new(0)

    source.each_line.filter_map do |line|
      next unless line.match?(/\A#{1,6}\s+/)

      heading = line.sub(/\A#{1,6}\s+/, "").sub(/\s+#+\s*\z/, "").strip
      anchor = normalize_markdown_anchor(heading)
      count = counts[anchor]
      counts[anchor] += 1

      count.zero? ? anchor : "#{anchor}-#{count}"
    end
  end

  def normalize_markdown_anchor(value)
    decoded = URI.decode_www_form_component(value.to_s)
    decoded
      .gsub(/`([^`]*)`/, "\\1")
      .gsub(/<[^>]+>/, "")
      .downcase
      .gsub(/[^\p{Alnum}\p{Han}\p{Hiragana}\p{Katakana}\s_-]/, "")
      .strip
      .gsub(/\s+/, "-")
  end

  def external_or_non_markdown_anchor?(target)
    target.match?(/\A(?:[a-z][a-z0-9+.-]*:|\/\/)/i) || target.start_with?("/") || !target.include?("#")
  end

  def relative_repo_path(path)
    Pathname.new(path).relative_path_from(Pathname.new(repo_root)).to_s
  end
end
