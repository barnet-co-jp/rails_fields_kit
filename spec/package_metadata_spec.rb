# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "package metadata" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:package_json_path) { File.join(repo_root, "package.json") }

  def build_entrypoint_sandbox
    Dir.mktmpdir("rails-fields-kit-entrypoints") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")
      node_package_dir = File.join(tmpdir, "node_modules/rails_fields_kit")
      node_package_entrypoint_dir = File.join(node_package_dir, "app/javascript/rails_fields_kit")
      stimulus_dir = File.join(tmpdir, "node_modules/@hotwired/stimulus")
      tom_select_dir = File.join(tmpdir, "node_modules/tom-select")

      FileUtils.mkdir_p(package_dir)
      FileUtils.mkdir_p(node_package_entrypoint_dir)
      FileUtils.mkdir_p(stimulus_dir)
      FileUtils.mkdir_p(tom_select_dir)

      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(package_json_path, File.join(node_package_dir, "package.json"))
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/index.js"),
        File.join(package_dir, "index.js")
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/native_field_accessibility_contract.js"),
        File.join(package_dir, "native_field_accessibility_contract.js")
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/tom_select_controller.js"),
        File.join(package_dir, "tom_select_controller.js")
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/tom_select_text_override_contract.js"),
        File.join(package_dir, "tom_select_text_override_contract.js")
      )
      FileUtils.cp(
        File.join(package_dir, "index.js"),
        File.join(node_package_entrypoint_dir, "index.js")
      )
      FileUtils.cp(
        File.join(package_dir, "native_field_accessibility_contract.js"),
        File.join(node_package_entrypoint_dir, "native_field_accessibility_contract.js")
      )
      FileUtils.cp(
        File.join(package_dir, "tom_select_controller.js"),
        File.join(node_package_entrypoint_dir, "tom_select_controller.js")
      )
      FileUtils.cp(
        File.join(package_dir, "tom_select_text_override_contract.js"),
        File.join(node_package_entrypoint_dir, "tom_select_text_override_contract.js")
      )
      File.write(
        File.join(stimulus_dir, "package.json"),
        "{\n  \"name\": \"@hotwired/stimulus\",\n  \"type\": \"module\",\n  \"exports\": \"./index.js\"\n}\n"
      )
      File.write(File.join(stimulus_dir, "index.js"), "export class Controller {}\n")
      File.write(
        File.join(tom_select_dir, "package.json"),
        "{\n  \"name\": \"tom-select\",\n  \"type\": \"module\",\n  \"exports\": \"./index.js\"\n}\n"
      )
      File.write(File.join(tom_select_dir, "index.js"), "export default class TomSelect {}\n")

      yield tmpdir
    end
  end

  def rendered_tom_select_field_fixture_script
    <<~JS
      const renderedTomSelectField = (attributes = {}) => ({
        attributes: {
          "data-controller": "rails-fields-kit--tom-select",
          ...attributes
        },
        getAttribute(name) { return this.attributes[name] ?? null },
        hasAttribute(name) { return Object.prototype.hasOwnProperty.call(this.attributes, name) }
      })

      const plainField = () => ({
        getAttribute() { return null },
        hasAttribute() { return false }
      })
    JS
  end

  def run_node_entrypoint_check(*paths, script:, chdir: nil)
    command = ["node", "--input-type=module", "-e", script, *paths]
    stdout, stderr, status = if chdir
      Open3.capture3(*command, chdir: chdir)
    else
      Open3.capture3(*command)
    end

    expect(status).to be_success, <<~MESSAGE
      expected documented JavaScript entrypoints to load successfully

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "exports the documented JavaScript entrypoints" do
    package = JSON.parse(File.read(package_json_path))

    expect(package.fetch("name")).to eq("rails_fields_kit")
    expect(package.fetch("type")).to eq("module")
    expect(package.fetch("exports")).to eq(
      "." => "./app/javascript/rails_fields_kit/index.js",
      "./native_field_accessibility_contract" => "./app/javascript/rails_fields_kit/native_field_accessibility_contract.js",
      "./tom_select_controller" => "./app/javascript/rails_fields_kit/tom_select_controller.js",
      "./tom_select_text_override_contract" => "./app/javascript/rails_fields_kit/tom_select_text_override_contract.js"
    )
  end

  it "loads the documented entrypoints and keeps the root export wired to the direct controller export" do
    build_entrypoint_sandbox do |tmpdir|
      index_entrypoint_path = File.join(tmpdir, "app/javascript/rails_fields_kit/index.js")
      controller_entrypoint_path = File.join(tmpdir, "app/javascript/rails_fields_kit/tom_select_controller.js")

      script = <<~JS
        import { pathToFileURL } from "node:url"

        const indexUrl = pathToFileURL(process.argv[1]).href
        const controllerUrl = pathToFileURL(process.argv[2]).href

        const indexModule = await import(indexUrl)
        const controllerModule = await import(controllerUrl)

        if (typeof controllerModule.default !== "function") {
          throw new Error("direct controller entrypoint did not export a default controller class")
        }

        if (indexModule.default !== indexModule.TomSelectController) {
          throw new Error("package root default export no longer matches the named TomSelectController export")
        }

        if (indexModule.TomSelectController !== controllerModule.default) {
          throw new Error("package root named export no longer matches the direct controller entrypoint")
        }
      JS

      run_node_entrypoint_check(index_entrypoint_path, controller_entrypoint_path, script:)
    end
  end

  it "loads the package-name imports documented for host applications" do
    build_entrypoint_sandbox do |tmpdir|
      script = <<~JS
        const rootModule = await import("rails_fields_kit")
        const controllerModule = await import("rails_fields_kit/tom_select_controller")
        const nativeContractModule = await import("rails_fields_kit/native_field_accessibility_contract")
        const textContractModule = await import("rails_fields_kit/tom_select_text_override_contract")

        if (typeof controllerModule.default !== "function") {
          throw new Error("direct controller package import did not export a default controller class")
        }

        if (rootModule.default !== rootModule.TomSelectController) {
          throw new Error("package root default export no longer matches the named TomSelectController export")
        }

        if (rootModule.TomSelectController !== controllerModule.default) {
          throw new Error("package root named export no longer matches the direct controller package import")
        }

        if (typeof rootModule.tomSelectTextOverrideContract !== "function") {
          throw new Error("package root import did not expose tomSelectTextOverrideContract")
        }

        if (rootModule.nativeFieldAccessibilityContract !== nativeContractModule.default) {
          throw new Error("package root named export no longer matches the direct native field accessibility contract import")
        }

        if (rootModule.tomSelectTextOverrideContract !== textContractModule.default) {
          throw new Error("package root named export no longer matches the direct Tom Select text override contract import")
        }
      JS

      run_node_entrypoint_check(script:, chdir: tmpdir)
    end
  end

  it "exports a package-root helper for the rendered Tom Select text override contract" do
    build_entrypoint_sandbox do |tmpdir|
      index_entrypoint_path = File.join(tmpdir, "app/javascript/rails_fields_kit/index.js")

      script = <<~JS
        import { pathToFileURL } from "node:url"

        const indexUrl = pathToFileURL(process.argv[1]).href
        const { tomSelectTextOverrideContract } = await import(indexUrl)

        if (typeof tomSelectTextOverrideContract !== "function") {
          throw new Error("package root did not export tomSelectTextOverrideContract")
        }

        #{rendered_tom_select_field_fixture_script}

        const field = renderedTomSelectField({
          "data-rails-fields-kit--tom-select-no-results-text-value": "No customers found",
          "data-rails-fields-kit--tom-select-loading-text-value": "Searching...",
          "data-rails-fields-kit--tom-select-create-text-value": "Create"
        })

        const contract = tomSelectTextOverrideContract(field)
        if (contract.noResultsText !== "No customers found") throw new Error("missing noResultsText")
        if (contract.loadingText !== "Searching...") throw new Error("missing loadingText")
        if (contract.createText !== "Create") throw new Error("missing createText")

        const fallbackContract = tomSelectTextOverrideContract(renderedTomSelectField())
        if (fallbackContract.noResultsText !== null) throw new Error("unexpected noResultsText fallback value")
        if (fallbackContract.loadingText !== null) throw new Error("unexpected loadingText fallback value")
        if (fallbackContract.createText !== null) throw new Error("unexpected createText fallback value")

        if (tomSelectTextOverrideContract(plainField()) !== null) {
          throw new Error("non Rails Fields Kit field should not return a text contract")
        }
      JS

      run_node_entrypoint_check(index_entrypoint_path, script:)
    end
  end
end
