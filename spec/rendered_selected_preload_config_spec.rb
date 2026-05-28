# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "rendered selected preload config reader" do
  let(:repo_root) { File.expand_path("..", __dir__) }

  def build_helper_sandbox
    Dir.mktmpdir("rails-fields-kit-selected-preload-reader") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")

      FileUtils.mkdir_p(package_dir)
      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_selected_preload_config.js"),
        File.join(package_dir, "rendered_selected_preload_config.js")
      )

      yield File.join(package_dir, "rendered_selected_preload_config.js")
    end
  end

  def run_node_check(helper_path, script)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, helper_path)

    expect(status).to be_success, <<~MESSAGE
      expected selected preload helper to behave as documented

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "returns a stable selected preload config for rendered fields" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedSelectedPreloadConfig } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-selected-url-value": "/customers/selected.json",
              "data-rails-fields-kit--tom-select-selected-param-value": "customer_id",
              "data-rails-fields-kit--tom-select-selected-multiple-param-value": "customer_ids",
              "data-rails-fields-kit--tom-select-selected-query-params-value": "{\"account_id\":7,\"context\":\"orders\"}"
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const config = readRenderedSelectedPreloadConfig(element)
        if (!config) throw new Error("expected config for rendered selected preload field")
        if (config.selectedUrl !== "/customers/selected.json") throw new Error("missing selectedUrl")
        if (config.selectedParam !== "customer_id") throw new Error("missing selectedParam")
        if (config.selectedMultipleParam !== "customer_ids") throw new Error("missing selectedMultipleParam")
        if (config.selectedQueryParams.account_id !== 7 || config.selectedQueryParams.context !== "orders") {
          throw new Error("missing selectedQueryParams")
        }
      JS

      run_node_check(helper_path, script)
    end
  end

  it "returns null when the rendered field does not opt into selected preload" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedSelectedPreloadConfig } = await import(helperUrl)

        const element = {
          getAttribute() {
            return null
          }
        }

        if (readRenderedSelectedPreloadConfig(element) !== null) {
          throw new Error("expected null when selected_url is not present")
        }
      JS

      run_node_check(helper_path, script)
    end
  end

  it "falls back to documented default param names and empty query params" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedSelectedPreloadConfig } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            if (name === "data-rails-fields-kit--tom-select-selected-url-value") {
              return "/customers/selected.json"
            }

            return null
          }
        }

        const config = readRenderedSelectedPreloadConfig(element)
        if (config.selectedParam !== "id") throw new Error("expected default selectedParam")
        if (config.selectedMultipleParam !== "ids") throw new Error("expected default selectedMultipleParam")
        if (Object.keys(config.selectedQueryParams).length !== 0) {
          throw new Error("expected empty selectedQueryParams")
        }
      JS

      run_node_check(helper_path, script)
    end
  end
end
