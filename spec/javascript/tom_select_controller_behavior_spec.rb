# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select controller behavior" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_controller_sandbox
    Dir.mktmpdir("rails-fields-kit-controller-behavior") do |tmpdir|
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
      File.write(
        File.join(stimulus_dir, "package.json"),
        "{\n  \"name\": \"@hotwired/stimulus\",\n  \"type\": \"module\",\n  \"exports\": \"./index.js\"\n}\n"
      )
      File.write(File.join(stimulus_dir, "index.js"), "export class Controller {}\n")
      File.write(
        File.join(tom_select_dir, "package.json"),
        "{\n  \"name\": \"tom-select\",\n  \"type\": \"module\",\n  \"exports\": \"./index.js\"\n}\n"
      )
      File.write(File.join(tom_select_dir, "index.js"), <<~JS)
        export default class TomSelect {
          constructor(element, options) {
            this.element = element
            this.options = options
          }

          on() {}
          destroy() {}
          getValue() { return "" }
        }
      JS

      yield File.join(package_dir, "tom_select_controller.js")
    end
  end

  def run_node_behavior_check(controller_path, script:)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, controller_path)

    expect(status).to be_success, <<~MESSAGE
      expected Tom Select controller behavior harness to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "keeps falsy remote option values renderable while skipping empty rich fields" do
    build_controller_sandbox do |controller_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const controllerUrl = pathToFileURL(process.argv[1]).href
        const Controller = (await import(controllerUrl)).default
        const controller = new Controller()

        controller.labelFieldValue = "text"
        controller.hasOptionDescriptionFieldValue = true
        controller.optionDescriptionFieldValue = "description"
        controller.hasOptionBadgeFieldValue = true
        controller.optionBadgeFieldValue = "badge"

        const escape = (value) => String(value)
          .replaceAll("&", "&amp;")
          .replaceAll("<", "&lt;")
          .replaceAll(">", "&gt;")

        const html = controller.optionTemplate({ text: 0, description: false, badge: 0 }, escape, "option")

        assert(html.includes('<span class="rfk-option-label">0</span>'), "numeric zero label should render")
        assert(html.includes('<span class="rfk-option-badge">0</span>'), "numeric zero badge should render")
        assert(html.includes('<div class="rfk-option-description">false</div>'), "boolean false description should render")

        const emptyHtml = controller.optionTemplate({ text: null, description: "", badge: null }, escape, "option")

        assert(emptyHtml.includes('<span class="rfk-option-label"></span>'), "empty label should render as an empty string")
        assert(!emptyHtml.includes("rfk-option-badge"), "null badge should be skipped")
        assert(!emptyHtml.includes("rfk-option-description"), "empty description should be skipped")

        const escapedHtml = controller.optionTemplate({ text: "<b>safe</b>", description: 0, badge: false }, escape, "option")
        assert(escapedHtml.includes("&lt;b&gt;safe&lt;/b&gt;"), "Tom Select escape callback should still escape labels")
      JS

      run_node_behavior_check(controller_path, script:)
    end
  end

  it "keeps falsy selected values eligible for selected preload" do
    build_controller_sandbox do |controller_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const controllerUrl = pathToFileURL(process.argv[1]).href
        const Controller = (await import(controllerUrl)).default
        const controller = new Controller()

        controller.tomSelect = {
          options: { present: { value: "present", text: "Present" } },
          getValue() {
            return [0, false, "", null, undefined, "present", "missing"]
          }
        }

        const values = controller.selectedValuesNeedingOptions()

        assert(values.length === 3, `expected three missing selected values, got ${JSON.stringify(values)}`)
        assert(values[0] === 0, "numeric zero should need selected preload when no option exists")
        assert(values[1] === false, "boolean false should need selected preload when no option exists")
        assert(values[2] === "missing", "non-empty missing value should still need selected preload")
      JS

      run_node_behavior_check(controller_path, script:)
    end
  end

  it "dispatches request error details and marks the opt-in error surface" do
    build_controller_sandbox do |controller_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const controllerUrl = pathToFileURL(process.argv[1]).href
        const Controller = (await import(controllerUrl)).default
        const surface = {
          hidden: true,
          dataset: {
            rfkErrorState: "stale",
            rfkErrorOperation: "stale",
            rfkErrorStatus: "500"
          },
          textContent: "Previous error"
        }

        globalThis.document = {
          getElementById(id) {
            return id === "remote-error" ? surface : null
          }
        }

        const controller = new Controller()
        const events = []
        controller.hasErrorSurfaceIdValue = true
        controller.errorSurfaceIdValue = "remote-error"
        controller.dispatch = (eventName, payload) => events.push({ eventName, payload })

        const response = { status: 422 }
        const error = new Error("request failed")
        error.response = response
        error.payload = { errors: ["invalid"] }

        controller.dispatchRequestError("load-error", "load", { query: "abc" }, error)

        assert(surface.hidden === false, "error surface should be visible after a request error")
        assert(surface.dataset.rfkErrorState === "error", "error surface should expose error state")
        assert(surface.dataset.rfkErrorOperation === "load", "error surface should expose the failing operation")
        assert(surface.dataset.rfkErrorStatus === "422", "error surface should expose the response status")
        assert(events.length === 1, "exactly one request error event should be dispatched")

        const event = events[0]
        const detail = event.payload.detail
        assert(event.eventName === "load-error", "request error event name should stay stable")
        assert(detail.operation === "load", "detail.operation should be included")
        assert(detail.query === "abc", "context keys should be forwarded into the detail")
        assert(detail.error === error, "detail.error should reference the original error")
        assert(detail.response === response, "detail.response should reference the response")
        assert(detail.payload.errors[0] === "invalid", "detail.payload should include the parsed payload")
        assert(detail.status === 422, "detail.status should include the response status")
        assert(detail.surface === surface, "detail.surface should reference the marked surface")
      JS

      run_node_behavior_check(controller_path, script:)
    end
  end

  it "clears the opt-in error surface state" do
    build_controller_sandbox do |controller_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const controllerUrl = pathToFileURL(process.argv[1]).href
        const Controller = (await import(controllerUrl)).default
        const surface = {
          hidden: false,
          dataset: {
            rfkErrorState: "error",
            rfkErrorOperation: "load",
            rfkErrorStatus: "422"
          },
          textContent: "Previous error"
        }

        globalThis.document = {
          getElementById(id) {
            return id === "remote-error" ? surface : null
          }
        }

        const controller = new Controller()
        controller.hasErrorSurfaceIdValue = true
        controller.errorSurfaceIdValue = "remote-error"

        controller.clearErrorSurface()

        assert(surface.hidden === true, "error surface should be hidden after clear")
        assert(!("rfkErrorState" in surface.dataset), "error state dataset key should be removed")
        assert(!("rfkErrorOperation" in surface.dataset), "operation dataset key should be removed")
        assert(!("rfkErrorStatus" in surface.dataset), "status dataset key should be removed")
        assert(surface.textContent === "", "error surface text should be cleared")
      JS

      run_node_behavior_check(controller_path, script:)
    end
  end
end
