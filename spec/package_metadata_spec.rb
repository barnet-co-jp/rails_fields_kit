# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "package metadata" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:package_json_path) { File.join(repo_root, "package.json") }

  def package_json
    JSON.parse(File.read(package_json_path))
  end

  def package_exports
    package_json.fetch("exports")
  end

  def package_export_import_paths
    package_exports.transform_values { |metadata| metadata.fetch("import") }
  end

  def direct_package_import_names
    package_exports.keys.reject { |export_name| export_name == "." }.map { |export_name| export_name.delete_prefix("./") }
  end

  def copy_package_entrypoints(package_dir, node_package_entrypoint_dir)
    package_export_import_paths.each do |export_name, import_path|
      unless import_path.start_with?("./app/javascript/rails_fields_kit/") && import_path.end_with?(".js")
        raise "#{export_name} import path must point at a packaged JavaScript entrypoint: #{import_path}"
      end

      entrypoint_name = import_path.delete_prefix("./app/javascript/rails_fields_kit/")
      FileUtils.cp(
        File.join(repo_root, import_path.delete_prefix("./")),
        File.join(package_dir, entrypoint_name)
      )
      FileUtils.cp(
        File.join(package_dir, entrypoint_name),
        File.join(node_package_entrypoint_dir, entrypoint_name)
      )
    end
  end

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
      copy_package_entrypoints(package_dir, node_package_entrypoint_dir)
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
    package = package_json

    expect(package.fetch("name")).to eq("rails_fields_kit")
    expect(package.fetch("type")).to eq("module")
    expect(package.fetch("types")).to eq("./app/javascript/rails_fields_kit/index.d.ts")
    expect(package.fetch("exports")).to eq(
      "." => {
        "types" => "./app/javascript/rails_fields_kit/index.d.ts",
        "import" => "./app/javascript/rails_fields_kit/index.js",
        "default" => "./app/javascript/rails_fields_kit/index.js"
      },
      "./native_field_accessibility_contract" => {
        "types" => "./app/javascript/rails_fields_kit/native_field_accessibility_contract.d.ts",
        "import" => "./app/javascript/rails_fields_kit/native_field_accessibility_contract.js",
        "default" => "./app/javascript/rails_fields_kit/native_field_accessibility_contract.js"
      },
      "./native_field_constraint_contract" => {
        "types" => "./app/javascript/rails_fields_kit/native_field_constraint_contract.d.ts",
        "import" => "./app/javascript/rails_fields_kit/native_field_constraint_contract.js",
        "default" => "./app/javascript/rails_fields_kit/native_field_constraint_contract.js"
      },
      "./read_rendered_error_surface" => {
        "types" => "./app/javascript/rails_fields_kit/read_rendered_error_surface.d.ts",
        "import" => "./app/javascript/rails_fields_kit/read_rendered_error_surface.js",
        "default" => "./app/javascript/rails_fields_kit/read_rendered_error_surface.js"
      },
      "./tom_select_controller" => {
        "types" => "./app/javascript/rails_fields_kit/tom_select_controller.d.ts",
        "import" => "./app/javascript/rails_fields_kit/tom_select_controller.js",
        "default" => "./app/javascript/rails_fields_kit/tom_select_controller.js"
      },
      "./tom_select_plugin_contract" => {
        "types" => "./app/javascript/rails_fields_kit/tom_select_plugin_contract.d.ts",
        "import" => "./app/javascript/rails_fields_kit/tom_select_plugin_contract.js",
        "default" => "./app/javascript/rails_fields_kit/tom_select_plugin_contract.js"
      },
      "./tom_select_text_override_contract" => {
        "types" => "./app/javascript/rails_fields_kit/tom_select_text_override_contract.d.ts",
        "import" => "./app/javascript/rails_fields_kit/tom_select_text_override_contract.js",
        "default" => "./app/javascript/rails_fields_kit/tom_select_text_override_contract.js"
      }
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
        const directImportNames = #{JSON.generate(direct_package_import_names)}
        const directModules = {}
        for (const importName of directImportNames) {
          directModules[importName] = await import(`rails_fields_kit/${importName}`)
        }

        const controllerModule = directModules["tom_select_controller"]
        const nativeAccessibilityContractModule = directModules["native_field_accessibility_contract"]
        const nativeConstraintContractModule = directModules["native_field_constraint_contract"]
        const pluginContractModule = directModules["tom_select_plugin_contract"]
        const errorSurfaceModule = directModules["read_rendered_error_surface"]
        const textContractModule = directModules["tom_select_text_override_contract"]

        if (typeof controllerModule.default !== "function") {
          throw new Error("direct controller package import did not export a default controller class")
        }

        if (rootModule.default !== rootModule.TomSelectController) {
          throw new Error("package root default export no longer matches the named TomSelectController export")
        }

        if (rootModule.TomSelectController !== controllerModule.default) {
          throw new Error("package root named export no longer matches the direct controller package import")
        }

        if (typeof rootModule.tomSelectPluginContract !== "function") {
          throw new Error("package root import did not expose tomSelectPluginContract")
        }

        if (typeof rootModule.readRenderedErrorSurface !== "function") {
          throw new Error("package root import did not expose readRenderedErrorSurface")
        }

        if (typeof rootModule.tomSelectTextOverrideContract !== "function") {
          throw new Error("package root import did not expose tomSelectTextOverrideContract")
        }

        if (typeof rootModule.nativeFieldConstraintContract !== "function") {
          throw new Error("package root import did not expose nativeFieldConstraintContract")
        }

        if (rootModule.nativeFieldAccessibilityContract !== nativeAccessibilityContractModule.default) {
          throw new Error("package root named export no longer matches the direct native field accessibility contract import")
        }

        if (rootModule.nativeFieldConstraintContract !== nativeConstraintContractModule.default) {
          throw new Error("package root named export no longer matches the direct native field constraint contract import")
        }

        if (rootModule.tomSelectPluginContract !== pluginContractModule.default) {
          throw new Error("package root named export no longer matches the direct Tom Select plugin contract import")
        }

        if (rootModule.readRenderedErrorSurface !== errorSurfaceModule.default) {
          throw new Error("package root named export no longer matches the direct rendered error surface import")
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
