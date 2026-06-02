# frozen_string_literal: true

require "spec_helper"
require "pathname"

RSpec.describe "documentation example drift" do
  repository_root = Pathname.new(File.expand_path("../..", __dir__))

  def read_doc(path)
    Pathname.new(File.expand_path("../#{path}", __dir__)).read
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##\s)/, 2).first
  end

  it "keeps README and setup JavaScript examples aligned on public entrypoints" do
    docs = {
      "README.md" => read_doc("README.md"),
      "doc/setup.md" => read_doc("doc/setup.md")
    }
    setup_signals = {
      "package-root controller import" => "import { TomSelectController } from \"rails_fields_kit\"",
      "direct controller import" => "import TomSelectController from \"rails_fields_kit/tom_select_controller\"",
      "package-root bundler alias" => "find: /^rails_fields_kit$/",
      "direct controller bundler alias" => "find: /^rails_fields_kit\\/tom_select_controller$/",
      "package-root importmap pin" => "pin \"rails_fields_kit\", to: \"rails_fields_kit/index.js\"",
      "direct controller importmap pin" => "pin \"rails_fields_kit/tom_select_controller\", to: \"rails_fields_kit/tom_select_controller.js\""
    }

    missing = []
    docs.each do |path, content|
      setup_signals.each do |label, signal|
        missing << "#{path} missing #{label}: #{signal}" unless content.include?(signal)
      end
    end

    expect(missing).to be_empty, "JavaScript setup example drift:\n#{missing.join("\n")}"
  end

  it "keeps shared metadata examples aligned on representative field and predicate signals" do
    docs = {
      "doc/token_suggestions.md" => "RailsFieldsKit::TokenSuggestions.build(",
      "doc/ransack_suggestions.md" => "RailsFieldsKit::RansackSuggestions.build(",
      "doc/table_adapters.md" => "RailsFieldsKit::TableFilterInput.ransack_filter("
    }
    shared_signals = [
      "ORDER_SEARCH_FIELDS",
      "status:",
      "assignee:",
      "ransack_predicate:",
      "values: %w[open closed]"
    ]

    missing = []
    docs.each do |path, public_surface|
      section = markdown_section(read_doc(path), "## Shared metadata source pattern")
      shared_signals.each do |signal|
        missing << "#{path} shared metadata section missing #{signal}" unless section.include?(signal)
      end
      missing << "#{path} shared metadata section missing #{public_surface}" unless section.include?(public_surface)
      unless section.match?(/host app(?:lication)?/i) && section.match?(/registry object|does not own the registry/i)
        missing << "#{path} shared metadata section must keep the host-app-owned registry boundary visible"
      end
    end

    expect(missing).to be_empty, "Shared metadata docs example drift:\n#{missing.join("\n")}"
  end
end
