# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "rendered remote search config reader" do
  let(:repo_root) { File.expand_path("..", __dir__) }

  def build_helper_sandbox
    Dir.mktmpdir("rails-fields-kit-remote-search-reader") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")

      FileUtils.mkdir_p(package_dir)
      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_remote_search_config.js"),
        File.join(package_dir, "rendered_remote_search_config.js")
      )

      yield File.join(package_dir, "rendered_remote_search_config.js")
    end
  end

  def run_node_check(helper_path, script)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, helper_path)

    expect(status).to be_success, <<~MESSAGE
      expected remote search helper to behave as documented

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "returns a stable remote search config for rendered fields" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedRemoteSearchConfig } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-url-value": "/customers/search.json",
              "data-rails-fields-kit--tom-select-query-param-value": "customer[name]",
              "data-rails-fields-kit--tom-select-query-params-value": JSON.stringify({ account_id: 7, context: "orders" })
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const config = readRenderedRemoteSearchConfig(element)
        if (!config) throw new Error("expected config for rendered remote search field")
        if (config.url !== "/customers/search.json") throw new Error("missing url")
        if (config.queryParam !== "customer[name]") throw new Error("missing queryParam")
        if (config.queryParams.account_id !== 7 || config.queryParams.context !== "orders") {
          throw new Error("missing queryParams")
        }
      JS

      run_node_check(helper_path, script)
    end
  end

  it "returns null when the rendered field does not opt into remote search" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedRemoteSearchConfig } = await import(helperUrl)

        const element = {
          getAttribute() {
            return null
          }
        }

        if (readRenderedRemoteSearchConfig(element) !== null) {
          throw new Error("expected null when url is not present")
        }
      JS

      run_node_check(helper_path, script)
    end
  end

  it "falls back to the documented default query param name and empty query params" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedRemoteSearchConfig } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            if (name === "data-rails-fields-kit--tom-select-url-value") {
              return "/customers/search.json"
            }

            return null
          }
        }

        const config = readRenderedRemoteSearchConfig(element)
        if (config.queryParam !== "q") throw new Error("expected default queryParam")
        if (Object.keys(config.queryParams).length !== 0) {
          throw new Error("expected empty queryParams")
        }
      JS

      run_node_check(helper_path, script)
    end
  end
end
