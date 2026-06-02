# frozen_string_literal: true

require "spec_helper"
require "pathname"

RSpec.describe "documentation example drift" do
  def read_doc(path)
    Pathname.new(File.expand_path("../#{path}", __dir__)).read
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
end
