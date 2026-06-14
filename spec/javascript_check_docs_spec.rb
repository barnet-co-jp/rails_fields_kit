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

  it "keeps check:js guard families represented without mirroring every smoke script" do
    runner_check_names = check_javascript_source.scan(/name: "([^"]+)"/).flatten

    expect(runner_check_names).to include(
      "JavaScript smoke inventory guard",
      "package exports smoke"
    )

    expect(development_doc).to include(
      "package/import metadata",
      "request lifecycle and event payloads",
      "rendered text, option, and fallback semantics",
      "package-root contract readers",
      "docs and smoke-inventory drift"
    )
    expect(development_doc).to include(
      "Exact smoke script membership belongs to `scripts/check_javascript.mjs`",
      "`scripts/check_javascript_smoke_inventory.mjs`"
    )
  end
end
