# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select initial state hydration" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_controller_sandbox
    Dir.mktmpdir("rails-fields-kit-initial-state") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")
      stimulus_dir = File.join(tmpdir, "node_modules/@hotwired/stimulus")
      tom_select_dir = File.join(tmpdir, "node_modules/tom-select")

      FileUtils.mkdir_p(package_dir)
      FileUtils.mkdir_p(stimulus_dir)
      FileUtils.mkdir_p(tom_select_dir)

      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      %w[tom_select_controller.js tom_select_controller_base.js].each do |filename|
        FileUtils.cp(
          File.join(repo_root, "app/javascript/rails_fields_kit", filename),
          File.join(package_dir, filename)
        )
      end
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
      expected Tom Select initial-state checks to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "hydrates a selected scalar even when a temporary option already exists" do
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
        controller.kindValue = "combobox"
        controller.hasSelectedUrlValue = true
        controller.selectedUrlValue = "/selected"
        controller.selectedQueryParamsValue = {}
        controller.selectedParamValue = "id"
        controller.selectedMultipleParamValue = "ids"
        controller.tomSelect = {
          options: {
            "42": { value: "42", text: "42", rfkSelectedLabelPending: true }
          },
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

  it "replaces the temporary scalar label with the selected preload payload" do
    build_controller_sandbox do |controller_path|
      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const Controller = (await import(pathToFileURL(process.argv[1]).href)).default
        const controller = new Controller()
        const events = []
        const optionElement = {
          dataset: { rfkSelectedLabelPending: "true" },
          removeAttribute() {}
        }

        controller.kindValue = "combobox"
        controller.valueFieldValue = "value"
        controller.labelFieldValue = "text"
        controller.tomSelect = {
          currentValue: "42",
          options: {
            "42": { value: "42", text: "42", rfkSelectedLabelPending: true, $option: optionElement }
          },
          getValue() {
            return this.currentValue
          },
          updateOption(value, option) {
            this.options[value] = option
          },
          addOption(option) {
            this.options[option.value] = option
          },
          addItem(value) {
            this.currentValue = String(value)
          },
          refreshOptions() {}
        }
        controller.clearErrorSurface = () => {}
        controller.dispatch = (name, options) => events.push([name, options.detail])

        controller.applySelectedOptions({ value: "42", text: "Acme Corp" }, ["42"])

        assert(controller.tomSelect.options["42"].text === "Acme Corp", "selected preload should replace the temporary label")
        assert(!controller.tomSelect.options["42"].rfkSelectedLabelPending, "pending marker should be removed")
        assert(!optionElement.dataset.rfkSelectedLabelPending, "pending DOM marker should be removed")
        assert(events.length === 1 && events[0][0] === "selected-load", "selected-load should still be dispatched")
      JS

      run_node_check(controller_path, script:)
    end
  end

  it "uses server-rendered lookup text and id without a redundant selected request" do
    build_controller_sandbox do |controller_path|
      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const Controller = (await import(pathToFileURL(process.argv[1]).href)).default
        const controller = new Controller()
        let fetchCount = 0
        const idField = { value: "42" }
        const textField = { value: "Widget 42" }

        globalThis.fetch = () => {
          fetchCount += 1
          throw new Error("selected preload should not run")
        }

        controller.kindValue = "lookup"
        controller.valueFieldValue = "value"
        controller.labelFieldValue = "text"
        controller.hasDisplayFieldValue = false
        controller.hasSelectedUrlValue = true
        controller.lookupIdField = () => idField
        controller.lookupTextField = () => textField
        controller.tomSelect = {
          currentValue: "42",
          options: { "42": { value: "42", text: "42" } },
          getValue() {
            return this.currentValue
          },
          updateOption(value, option) {
            this.options[value] = option
          },
          addOption(option) {
            this.options[option.value] = option
          },
          addItem(value) {
            this.currentValue = String(value)
          }
        }

        controller.loadSelectedOptions()

        assert(fetchCount === 0, `expected no selected preload request, got ${fetchCount}`)
        assert(controller.tomSelect.options["42"].text === "Widget 42", "lookup should use the server-rendered text label")
      JS

      run_node_check(controller_path, script:)
    end
  end

  it "treats an id-only lookup as unresolved and synchronizes hydrated text" do
    build_controller_sandbox do |controller_path|
      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const Controller = (await import(pathToFileURL(process.argv[1]).href)).default
        const controller = new Controller()
        const idField = { value: "42" }
        const textField = { value: "" }

        controller.kindValue = "lookup"
        controller.valueFieldValue = "value"
        controller.labelFieldValue = "text"
        controller.lookupIdField = () => idField
        controller.lookupTextField = () => textField
        controller.tomSelect = {
          currentValue: "42",
          options: { "42": { value: "42", text: "42" } },
          getValue() {
            return this.currentValue
          },
          updateOption(value, option) {
            this.options[value] = option
          },
          addOption(option) {
            this.options[option.value] = option
          },
          addItem(value) {
            this.currentValue = String(value)
          },
          refreshOptions() {}
        }
        controller.clearErrorSurface = () => {}
        controller.dispatch = () => {}

        assert(controller.selectedValuesNeedingOptions().join(",") === "42", "id-only lookup should require label hydration")

        controller.applySelectedOptions({ value: "42", text: "Hydrated widget" }, ["42"])

        assert(textField.value === "Hydrated widget", `expected hydrated lookup text, got ${textField.value}`)
        assert(idField.value === "42", `expected lookup id to remain 42, got ${idField.value}`)
      JS

      run_node_check(controller_path, script:)
    end
  end

  it "does not apply remote field mappings to a purely static select" do
    build_controller_sandbox do |controller_path|
      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const Controller = (await import(pathToFileURL(process.argv[1]).href)).default
        const controller = new Controller()

        controller.createValue = false
        controller.freeTextValue = false
        controller.hasPersistValue = false
        controller.placeholderValue = ""
        controller.pluginsValue = []
        controller.element = { getAttribute() { return null } }
        controller.hasClassNamesValue = false
        controller.hasMaxOptionsValue = false
        controller.hasMaxItemsValue = false
        controller.hasLoadThrottleValue = false
        controller.hasDelimiterValue = false
        controller.hasDropdownParentValue = false
        controller.hasPreloadValue = false
        controller.hasOpenOnFocusValue = false
        controller.hasCloseAfterSelectValue = false
        controller.hasHideSelectedValue = false
        controller.hasUrlValue = false
        controller.hasSelectedUrlValue = false
        controller.hasCreateUrlValue = false
        controller.hasAddPrecedenceValue = false
        controller.hasCreateOnBlurValue = false
        controller.hasClearAfterSelectValue = false
        controller.valueFieldValue = "id"
        controller.labelFieldValue = "label"
        controller.searchFieldValue = "label"

        const options = controller.options()

        assert(options.valueField === undefined, "static select should keep Tom Select's native value field mapping")
        assert(options.labelField === undefined, "static select should keep Tom Select's native text label mapping")
        assert(options.searchField === undefined, "static select should keep Tom Select's native search mapping")
      JS

      run_node_check(controller_path, script:)
    end
  end
end
