# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select controller dependent query params contract" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_controller_sandbox
    Dir.mktmpdir("rails-fields-kit-dependent-query-params") do |tmpdir|
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

  def run_node_controller_check(controller_path, script:)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, controller_path)

    expect(status).to be_success, <<~MESSAGE
      expected Tom Select controller dependent query params contract check to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "merges fixed and dependency query params while omitting blank dependency values" do
    build_controller_sandbox do |controller_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const controllerUrl = pathToFileURL(process.argv[1]).href
        const Controller = (await import(controllerUrl)).default
        const controller = new Controller()
        const elements = {
          "#category": { tagName: "INPUT", type: "text", value: "hardware" },
          "#empty": { tagName: "INPUT", type: "text", value: "" },
          "#accounts": { tagName: "SELECT", multiple: true, selectedOptions: [{ value: "100" }, { value: "" }] }
        }

        globalThis.document = {
          querySelector(selector) { return elements[selector] || null }
        }

        controller.hasDependsOnValue = true
        controller.dependsOnValue = {
          scope: "#category",
          empty: "#empty",
          account_item_id: "#accounts"
        }
        controller.queryParamsValue = { scope: "fixed", page: "1" }
        controller.dependencyParams = controller.currentDependencyParams()

        const params = controller.remoteSearchParams()
        if (params.scope !== "hardware") throw new Error("dependency param should override the fixed param")
        if (params.page !== "1") throw new Error("fixed params should be preserved")
        if (Object.prototype.hasOwnProperty.call(params, "empty")) throw new Error("blank dependency params should be omitted")
        if (!Array.isArray(params.account_item_id) || params.account_item_id.length !== 1 || params.account_item_id[0] !== "100") {
          throw new Error("multi-select dependency values should keep present selections")
        }
      JS

      run_node_controller_check(controller_path, script:)
    end
  end

  it "aborts stale loads, clears cached remote options, optionally clears selection, and dispatches dependency change" do
    build_controller_sandbox do |controller_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const controllerUrl = pathToFileURL(process.argv[1]).href
        const Controller = (await import(controllerUrl)).default
        const controller = new Controller()
        const category = { tagName: "INPUT", type: "text", value: "hardware" }

        globalThis.document = {
          querySelector(selector) {
            if (selector !== "#category") throw new Error(`unexpected selector ${selector}`)
            return category
          }
        }

        let aborted = false
        let optionsCleared = false
        let selectionCleared = false
        let reloadedQuery = null
        let dispatched = null

        controller.hasDependsOnValue = true
        controller.dependsOnValue = { category: "#category" }
        controller.queryParamsValue = {}
        controller.dependencyParams = controller.currentDependencyParams()
        controller.clearOnDependencyChangeValue = true
        controller.hasUrlValue = true
        controller.abortRequest = (operation) => { if (operation === "load") aborted = true }
        controller.dispatch = (name, payload) => { dispatched = { name, payload } }
        controller.tomSelect = {
          isOpen: true,
          lastQuery: "bolt",
          clearOptions() { optionsCleared = true },
          clear(silent) { selectionCleared = silent === true },
          load(query) { reloadedQuery = query }
        }

        category.value = "software"
        controller.handleDependencyChange()

        if (!aborted) throw new Error("dependency change should abort an in-flight load")
        if (!optionsCleared) throw new Error("dependency change should clear cached remote options")
        if (!selectionCleared) throw new Error("selection should clear when clearOnDependencyChangeValue is true")
        if (reloadedQuery !== "bolt") throw new Error("open dropdown should reload with the last query")
        if (!dispatched || dispatched.name !== "dependency-change") throw new Error("dependency change event should be dispatched")
        if (dispatched.payload.detail.params.category !== "software") throw new Error("event should include current params")
        if (dispatched.payload.detail.previousParams.category !== "hardware") throw new Error("event should include previous params")
        if (dispatched.payload.detail.changed.category.current !== "software") throw new Error("event should include changed params")
      JS

      run_node_controller_check(controller_path, script:)
    end
  end

  it "removes dependency listeners before reconnecting" do
    build_controller_sandbox do |controller_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const controllerUrl = pathToFileURL(process.argv[1]).href
        const Controller = (await import(controllerUrl)).default
        const controller = new Controller()
        const calls = { add: 0, remove: 0 }
        const element = {
          tagName: "INPUT",
          type: "text",
          value: "hardware",
          addEventListener() { calls.add += 1 },
          removeEventListener() { calls.remove += 1 }
        }

        globalThis.document = {
          querySelector(selector) {
            if (selector !== "#category") throw new Error(`unexpected selector ${selector}`)
            return element
          }
        }

        controller.hasDependsOnValue = true
        controller.dependsOnValue = { category: "#category" }
        controller.dependencyListeners = []

        controller.bindDependencyEvents()
        controller.bindDependencyEvents()
        controller.unbindDependencyEvents()

        if (calls.add !== 4) throw new Error(`expected four listener registrations, got ${calls.add}`)
        if (calls.remove !== 4) throw new Error(`expected four listener removals, got ${calls.remove}`)
        if (controller.dependencyListeners.length !== 0) throw new Error("dependency listeners should be cleared")
      JS

      run_node_controller_check(controller_path, script:)
    end
  end
end
