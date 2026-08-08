# frozen_string_literal: true

require "spec_helper"

RSpec.describe "release notes and changelog alignment" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:changelog) { File.read(File.join(root, "CHANGELOG.md")) }
  let(:release_notes) { File.read(File.join(root, "doc/release_notes_0_1_1.md")) }
  let(:unreleased) { markdown_section(changelog, "## Unreleased") }
  let(:relationship) { markdown_section(release_notes, "## Relationship to `CHANGELOG.md` Unreleased") }

  it "keeps the release digest, Added, and Fixed structure represented in the draft summary" do
    expect(unreleased).to include("### Release digest", "### Added", "### Fixed")
    expect(relationship).to include("- Added:", "- Fixed:")

    expect(unreleased.index("### Release digest")).to be < unreleased.index("### Added")
    expect(unreleased.index("### Added")).to be < unreleased.index("### Fixed")
  end

  it "keeps representative landed Added and Fixed signals in both documents" do
    added_signals = [
      /`rfk_lookup`/,
      /`option_metadata_fields`/,
      /token search/i,
      /table metadata/i,
      /JavaScript exports/,
      /request-failure/
    ]
    fixed_signals = [
      /remote request lifecycle/i,
      /Ransack suggestion metadata/i,
      /table metadata collection/i,
      /renderer immutability/i,
      /TableRenderer input normalization/
    ]

    [unreleased, relationship].each do |document|
      (added_signals + fixed_signals).each { |signal| expect(document).to match(signal) }
    end
  end

  it "keeps exhaustive history, summary, and landed-only responsibilities distinct" do
    expect(unreleased).to include(
      "detailed entries remain the exhaustive source of truth",
      "Keep proposal or open-PR behavior out of this section until it has landed"
    )
    expect(relationship).to include(
      "exhaustive release-history source of truth",
      "reviewer-facing and GitHub-release-facing summary",
      "Do not add open-PR or proposal helper names here until they have landed"
    )
  end

  def markdown_section(markdown, heading)
    lines = markdown.lines
    start_index = lines.index { |line| line.chomp == heading }
    raise "Missing heading: #{heading}" unless start_index

    end_index = ((start_index + 1)...lines.length).find { |index| lines[index].start_with?("## ") }
    lines[start_index...(end_index || lines.length)].join
  end
end
