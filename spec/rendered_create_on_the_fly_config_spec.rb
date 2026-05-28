# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "rendered create-on-the-fly config reader" do
  let(:repo_root) { File.expand_path("..", __dir__) }

  def build_helper_sandbox
    Dir.mktmpdir("rails-fields-kit-create-on-the-fly-reader") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")

      FileUtils.mkdir_p(package_dir)
      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_create_on_the_fly_config.js"),
        File.join(package_dir, "rendered_create_on_the_fly_config.js")
      )

      yield File.join(package_dir, "rendered_create_on_the_fly_config.js")
    end
  end

  def run_node_check(helper_path, script)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, helper_path)

    expect(status).to be_success, <<~MESSAGE
      expected create-on-the-fly helper to behave as documented

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "returns a stable create-on-the-fly config for rendered fields" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedCreateOnTheFlyConfig } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-create-url-value": "/customers.json",
              "data-rails-fields-kit--tom-select-create-param-value": "customer[name]",
              "data-rails-fields-kit--tom-select-create-params-value": JSON.stringify({ account_id: 7, source: "orders" })
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const config = readRenderedCreateOnTheFlyConfig(element)
        if (!config) throw new Error("expected config for rendered create-on-the-fly field")
        if (config.createUrl !== "/customers.json") throw new Error("missing createUrl")
        if (config.createParam !== "customer[name]") throw new Error("missing createParam")
        if (config.createParams.account_id !== 7 || config.createParams.source !== "orders") {
          throw new Error("missing createParams")
        }
      JS

      run_node_check(helper_path, script)
    end
  end

  it "returns null when the rendered field does not opt into create-on-the-fly" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedCreateOnTheFlyConfig } = await import(helperUrl)

        const element = {
          getAttribute() {
            return null
          }
        }

        if (readRenderedCreateOnTheFlyConfig(element) !== null) {
          throw new Error("expected null when create_url is not present")
        }
      JS

      run_node_check(helper_path, script)
    end
  end

  it "falls back to the documented default create param name and empty create params" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedCreateOnTheFlyConfig } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            if (name === "data-rails-fields-kit--tom-select-create-url-value") {
              return "/customers.json"
            }

            return null
          }
        }

        const config = readRenderedCreateOnTheFlyConfig(element)
        if (config.createParam !== "text") throw new Error("expected default createParam")
        if (Object.keys(config.createParams).length !== 0) {
          throw new Error("expected empty createParams")
        }
      JS

      run_node_check(helper_path, script)
    end
  end
end
