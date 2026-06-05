# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select plugin contract helper" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_package_root_sandbox
    Dir.mktmpdir("rails-fields-kit-plugin-contract") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")

      FileUtils.mkdir_p(package_dir)
      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/index.js"),
        File.join(package_dir, "index.js")
      )
      File.write(File.join(package_dir, "tom_select_controller.js"), "export default class TomSelectController {}\n")

      yield File.join(package_dir, "index.js")
    end
  end

  def run_node_contract_check(index_path, script:)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, index_path)

    expect(status).to be_success, <<~MESSAGE
      expected Tom Select plugin contract harness to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "reads the effective plugin list and derived clearable state" do
    build_package_root_sandbox do |index_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const renderedTomSelectField = (plugins) => ({
          attributes: {
            "data-controller": "rails-fields-kit--tom-select",
            "data-rails-fields-kit--tom-select-plugins-value": JSON.stringify(plugins)
          },
          getAttribute(name) { return this.attributes[name] ?? null },
          hasAttribute(name) { return Object.hasOwn(this.attributes, name) }
        })

        const indexUrl = pathToFileURL(process.argv[1]).href
        const { tomSelectPluginContract } = await import(indexUrl)
        const contract = tomSelectPluginContract(renderedTomSelectField(["dropdown_input", "clear_button"]))

        assert(contract.plugins.join(" ") === "dropdown_input clear_button", "plugins should preserve rendered order")
        assert(contract.clearable === true, "clearable should be true when clear_button is effective")
      JS

      run_node_contract_check(index_path, script:)
    end
  end

  it "returns an empty non-clearable contract for missing, empty, or invalid plugin data" do
    build_package_root_sandbox do |index_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const renderedTomSelectField = (pluginValue) => ({
          attributes: {
            "data-controller": "rails-fields-kit--tom-select"
          },
          getAttribute(name) { return this.attributes[name] ?? null },
          hasAttribute(name) { return Object.hasOwn(this.attributes, name) },
          setPluginValue(value) {
            this.attributes["data-rails-fields-kit--tom-select-plugins-value"] = value
            return this
          }
        })

        const indexUrl = pathToFileURL(process.argv[1]).href
        const { tomSelectPluginContract } = await import(indexUrl)
        const missingContract = tomSelectPluginContract(renderedTomSelectField())
        const emptyContract = tomSelectPluginContract(renderedTomSelectField().setPluginValue(""))
        const invalidContract = tomSelectPluginContract(renderedTomSelectField().setPluginValue("not-json"))
        const objectContract = tomSelectPluginContract(renderedTomSelectField().setPluginValue(JSON.stringify({ plugin: "clear_button" })))

        ;[missingContract, emptyContract, invalidContract, objectContract].forEach((contract) => {
          assert(Array.isArray(contract.plugins) && contract.plugins.length === 0, "unsafe plugin data should return an empty plugin list")
          assert(contract.clearable === false, "unsafe plugin data should not be clearable")
        })
      JS

      run_node_contract_check(index_path, script:)
    end
  end

  it "returns null for non-element or non Rails Fields Kit Tom Select elements" do
    build_package_root_sandbox do |index_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const indexUrl = pathToFileURL(process.argv[1]).href
        const { tomSelectPluginContract } = await import(indexUrl)
        const unrelated = {
          attributes: {
            "data-rails-fields-kit--tom-select-plugins-value": JSON.stringify(["clear_button"])
          },
          getAttribute(name) { return this.attributes[name] ?? null },
          hasAttribute(name) { return Object.hasOwn(this.attributes, name) }
        }

        assert(tomSelectPluginContract(null) === null, "null should return null")
        assert(tomSelectPluginContract({}) === null, "non-elements should return null")
        assert(tomSelectPluginContract(unrelated) === null, "non Rails Fields Kit fields should return null")
      JS

      run_node_contract_check(index_path, script:)
    end
  end
end
