# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select server-rendered selected options" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_controller_sandbox
    Dir.mktmpdir("rails-fields-kit-server-selected") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")
      stimulus_dir = File.join(tmpdir, "node_modules/@hotwired/stimulus")
      tom_select_dir = File.join(tmpdir, "node_modules/tom-select")

      FileUtils.mkdir_p(package_dir)
      FileUtils.mkdir_p(stimulus_dir)
      FileUtils.mkdir_p(tom_select_dir)

      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/tom_select_controller.js"),
        File.join(package_dir, "tom_select_controller.js")
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/tom_select_controller_base.js"),
        File.join(package_dir, "tom_select_controller_base.js")
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

      yield File.join(package_dir, "tom_select_controller.js")
    end
  end

  def run_node_check(controller_path, script:)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, controller_path)

    expect(status).to be_success, <<~MESSAGE
      expected server-rendered selected option checks to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "skips selected preload when the selected option is already rendered" do
    build_controller_sandbox do |controller_path|
      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const Controller = (await import(pathToFileURL(process.argv[1]).href)).default
        const controller = new Controller()
        let fetchCount = 0

        globalThis.window = { location: { origin: "https://example.test" } }
        globalThis.fetch = () => {
          fetchCount += 1
          throw new Error("selected preload should not run")
        }

        controller.hasSelectedUrlValue = true
        controller.selectedUrlValue = "/selected"
        controller.selectedQueryParamsValue = {}
        controller.selectedParamValue = "id"
        controller.selectedMultipleParamValue = "ids"
        controller.tomSelect = {
          options: {
            "42": { value: "42", text: "大阪 100 あ 1234" }
          },
          getValue() {
            return "42"
          }
        }

        controller.loadSelectedOptions()

        assert(fetchCount === 0, `expected no selected preload request, got ${fetchCount}`)
        assert(controller.selectedValuesNeedingOptions().length === 0, "rendered selected option should satisfy label hydration")
      JS

      run_node_check(controller_path, script:)
    end
  end

  it "keeps selected preload available when option data is missing" do
    build_controller_sandbox do |controller_path|
      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const Controller = (await import(pathToFileURL(process.argv[1]).href)).default
        const controller = new Controller()
        const requests = []

        globalThis.window = { location: { origin: "https://example.test" } }
        globalThis.fetch = (url) => {
          requests.push(url)
          return new Promise(() => {})
        }

        controller.connected = true
        controller.requestControllers = {}
        controller.requestTokens = {}
        controller.hasSelectedUrlValue = true
        controller.selectedUrlValue = "/selected"
        controller.selectedQueryParamsValue = {}
        controller.selectedParamValue = "id"
        controller.selectedMultipleParamValue = "ids"
        controller.tomSelect = {
          options: {},
          getValue() {
            return "42"
          }
        }
        controller.clearErrorSurface = () => {}

        controller.loadSelectedOptions()

        assert(requests.length === 1, `expected one selected preload request, got ${requests.length}`)
        assert(requests[0].includes("id=42"), `expected selected id in request: ${requests[0]}`)
      JS

      run_node_check(controller_path, script:)
    end
  end
end
