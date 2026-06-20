# frozen_string_literal: true

require "rubygems"
require "spec_helper"
require "pathname"
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
      "Run `rails rails_fields_kit:doctor` after the first-pass wiring",
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

        unless markdown_anchors.fetch(resolved_file).include?(anchor)
          broken_links << "#{source_path} -> #{target} points at missing anchor ##{anchor} in #{resolved_file}"
        end
      end
    end

    expect(broken_links).to be_empty
  end

  it "keeps referenced docs packaged in the gem" do
    packaged_files = specification.files

    required_docs = %w[
      README.md
      doc/configuration.md
      doc/configuration_profiles.md
      doc/controller_helpers.md
      doc/events.md
      doc/field_helpers.md
      doc/package_root_helper_release_evidence.md
      doc/public_api.md
      doc/ransack_suggestions.md
      doc/select_migration.md
      doc/selected_preload_release_gate.md
      doc/setup.md
      doc/setup_doctor_output_review.md
      doc/shared_metadata_navigation.md
      doc/shared_metadata_runnable_guide.md
      doc/support_boundary.md
      doc/table_adapters.md
      doc/table_group_html.md
      doc/token_suggestions.md
      doc/tom_select_turbo_lifecycle.md
      doc/tom_select_visual_reference.html
      doc/visual_references.md
      lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md
    ]

    expect(required_docs - packaged_files).to be_empty
  end

  def markdown_links(markdown)
    markdown.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten
  end

  def external_or_non_markdown_anchor?(target)
    uri = URI.parse(target)

    return true if uri.scheme || uri.host
    return true if target.start_with?("mailto:")
    return true unless target.include?("#")

    false
  rescue URI::InvalidURIError
    true
  end

  def markdown_heading_anchors(markdown)
    markdown.lines.filter_map do |line|
      next unless line.start_with?("#")

      heading = line.sub(/^#+\s*/, "").strip
      heading.downcase.gsub(/[^a-z0-9\s-]/, "").tr(" ", "-")
    end
  end

  def relative_repo_path(path)
    Pathname.new(path).relative_path_from(Pathname.new(repo_root)).to_s
  end
end