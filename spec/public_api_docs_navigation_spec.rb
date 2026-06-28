# frozen_string_literal: true

require "spec_helper"

RSpec.describe "public API docs navigation guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:public_api) { read_repo_file("doc/public_api.md") }
  let(:readme) { read_repo_file("README.md") }
  let(:setup_doc) { read_repo_file("doc/setup.md") }
  let(:development_doc) { read_repo_file("doc/development.md") }

  it "keeps quick navigation anchors aligned with source-of-truth headings" do
    anchors = public_api.scan(/^## Quick navigation\n\n(?<body>(?:- \[[^\n]+\]\(#[^\n]+\)\n)+)/m)
      .flatten
      .first
      .scan(/\[[^\]]+\]\(#([^\)]+)\)/)
      .flatten

    expect(anchors).not_to be_empty

    headings = public_api.scan(/^##+\s+(.+)$/).flatten.map { |heading| markdown_anchor(heading) }

    expect(anchors - headings).to eq([])
    expect(anchors).to include(
      "formbuilder-helpers",
      "javascript-exports",
      "stimulus-values",
      "stimulus-events"
    )

    expect(readme).to include("doc/public_api.md", "doc/public_api.md#javascript-exports")
    expect(setup_doc).to include("doc/public_api.md#javascript-exports")
  end

  it "keeps Stimulus values docs focused on representative value families and integration boundaries" do
    stimulus_values = section("Stimulus values", "Stimulus lifecycle contract")

    expect(stimulus_values).to include(
      "remote URLs",
      "request parameter names",
      "JSON field names",
      "selected preload settings",
      "create-on-the-fly settings",
      "rendering labels",
      "plugin lists",
      "max_options",
      "max_items",
      "load_throttle",
      "delimiter",
      "dropdown_parent"
    )
    expect(stimulus_values).to include(
      "data-rails-fields-kit--tom-select-kind-value",
      "diagnostics and controller behavior rather than the preferred host-app integration surface",
      "host apps should use documented helper options, events, and package-root contract readers"
    )
    expect(development_doc).to include(
      "Tom Select data value drift guard",
      "FormBuilder-generated data value names remain represented in `TomSelectController.static values`",
      "public docs inventory guard"
    )
  end

  def read_repo_file(path)
    File.read(File.join(root, path))
  end

  def section(start_heading, next_heading)
    public_api.match(/^## #{Regexp.escape(start_heading)}\n(?<body>.*?)^## #{Regexp.escape(next_heading)}\n/m)[:body]
  end

  def markdown_anchor(heading)
    heading
      .downcase
      .gsub(/`([^`]+)`/, "\\1")
      .gsub(/[^a-z0-9\s-]/, "")
      .strip
      .gsub(/\s+/, "-")
  end
end
