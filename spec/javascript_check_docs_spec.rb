# frozen_string_literal: true

require "json"
require "yaml"
require "spec_helper"

RSpec.describe "JavaScript check documentation" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:development_doc) { File.read(File.join(repo_root, "doc/development.md")) }
  let(:package_json) { JSON.parse(File.read(File.join(repo_root, "package.json"))) }
  let(:workflow) do
    YAML.safe_load(
      File.read(File.join(repo_root, ".github/workflows/ci.yml")),
      aliases: true
    )
  end
  let(:check_javascript_source) { File.read(File.join(repo_root, "scripts/check_javascript.mjs")) }

  it "keeps the Node JavaScript check boundary aligned across package metadata, CI, and docs" do
    javascript_job = workflow.fetch("jobs").fetch("javascript")
    javascript_steps = javascript_job.fetch("steps")
    node_setup_step = javascript_steps.find { |step| step["uses"]&.start_with?("actions/setup-node@") }
    node_versions = javascript_job.fetch("strategy").fetch("matrix").fetch("node-version")

    expect(package_json.fetch("engines").fetch("node")).to eq("22.x || 24.x")
    expect(node_versions).to eq(["22", "24"])
    expect(node_setup_step.fetch("with").fetch("node-version")).to eq("${{ matrix.node-version }}")
    expect(development_doc).to include(
      "The JavaScript syntax check uses Node 22.x and Node 24.x, matching `package.json` and the GitHub Actions `javascript` job matrix.",
      "`npm run check:js` on Node 22.x and Node 24.x"
    )
  end

  it "keeps the check:js runner inventory represented in the development guide" do
    expected_check_signals = {
      "syntax: package entrypoint" => "public package entrypoint",
      "syntax: Tom Select controller" => "Tom Select controller source",
      "JavaScript smoke inventory guard" => "JavaScript smoke inventory guard",
      "package exports smoke" => "package `exports` import wiring",
      "TypeScript declaration metadata smoke" => "TypeScript declaration metadata",
      "Tom Select query params smoke" => "Tom Select fixed query params",
      "Tom Select interaction events smoke" => "Tom Select forwarded interaction and request event payloads",
      "Tom Select create headers and response normalization smoke" => "Tom Select create-on-the-fly JSON request headers and success response normalization",
      "Tom Select error surface smoke" => "Tom Select error-surface metadata",
      "Tom Select Turbo lifecycle smoke" => "Tom Select Turbo lifecycle behavior",
      "Tom Select label fallback smoke" => "Tom Select label fallback rendering",
      "Tom Select option value guard smoke" => "Tom Select option value guard behavior",
      "Tom Select render text fallback smoke" => "Tom Select render text fallback rendering",
      "Tom Select plugin contract smoke" => "Tom Select plugin contract reading",
      "selected preload config contract smoke" => "selected preload config reading"
    }

    runner_check_names = check_javascript_source.scan(/name: "([^"]+)"/).flatten

    expect(runner_check_names).to eq(expected_check_signals.keys)
    expected_check_signals.each_value do |documentation_signal|
      expect(development_doc).to include(documentation_signal)
    end
  end
end
