# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select controller runtime" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_runtime_sandbox
    Dir.mktmpdir("rails-fields-kit-runtime") do |tmpdir|
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
      File.write(
        File.join(tom_select_dir, "index.js"),
        <<~JS
          export default class TomSelect {
            constructor(element, options) {
              this.element = element
              this.optionsConfig = options
              this.handlers = {}
              this.options = {}
              this.items = []
              this.value = element.__tomSelectValue ?? []
              globalThis.__lastTomSelect = this
            }

            on(name, handler) {
              this.handlers[name] = handler
            }

            destroy() {
              this.destroyed = true
            }

            getValue() {
              return this.value
            }

            addOption(option) {
              this.options[option.value] = option
            }

            addItem(value, silent) {
              this.items.push({ value, silent })
              if (Array.isArray(this.value)) {
                if (!this.value.includes(value)) this.value = [...this.value, value]
              } else {
                this.value = value
              }
            }

            refreshOptions() {}
          }
        JS
      )

      yield tmpdir
    end
  end

  def run_node_runtime_check(*paths, script:)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, *paths)

    expect(status).to be_success, <<~MESSAGE
      expected Tom Select controller runtime checks to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "keeps stale requests from surfacing after a newer search or disconnect" do
    build_runtime_sandbox do |tmpdir|
      controller_path = File.join(tmpdir, "app/javascript/rails_fields_kit/tom_select_controller.js")

      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const { default: TomSelectController } = await import(pathToFileURL(process.argv[1]).href)

        const flush = async () => {
          await new Promise((resolve) => setTimeout(resolve, 0))
          await new Promise((resolve) => setTimeout(resolve, 0))
        }

        function installDocument(surface) {
          globalThis.document = {
            getElementById(id) {
              return id === "error-surface" ? surface : null
            },
            querySelector(selector) {
              return selector === "meta[name='csrf-token']" ? { content: "token" } : null
            },
            createElement() {
              return {
                _textContent: "",
                set textContent(value) {
                  this._textContent = value
                },
                get innerHTML() {
                  return this._textContent ?? ""
                }
              }
            }
          }
          globalThis.window = { location: { origin: "https://example.test" } }
        }

        function installFetchQueue() {
          const requests = []
          globalThis.fetch = (url, options = {}) => {
            let resolvePromise
            let rejectPromise
            const promise = new Promise((resolve, reject) => {
              resolvePromise = resolve
              rejectPromise = reject
            })
            const request = { url, options, resolve: resolvePromise, reject: rejectPromise }
            requests.push(request)
            if (options.signal) {
              if (options.signal.aborted) {
                const error = new Error("aborted")
                error.name = "AbortError"
                rejectPromise(error)
              } else {
                options.signal.addEventListener("abort", () => {
                  const error = new Error("aborted")
                  error.name = "AbortError"
                  rejectPromise(error)
                }, { once: true })
              }
            }
            return promise
          }
          return requests
        }

        function buildController({ hasSelectedUrl = false, selectedValue = [] } = {}) {
          const surface = { dataset: {}, hidden: true, textContent: "" }
          installDocument(surface)
          const controller = new TomSelectController()
          controller.__events = []
          controller.dispatch = (name, payload) => controller.__events.push({ name, detail: payload.detail })
          controller.element = {
            __tomSelectValue: selectedValue,
            getAttribute() {
              return null
            }
          }
          controller.createValue = false
          controller.freeTextValue = false
          controller.placeholderValue = ""
          controller.pluginsValue = []
          controller.hasPersistValue = false
          controller.hasMaxOptionsValue = false
          controller.hasMaxItemsValue = false
          controller.hasLoadThrottleValue = false
          controller.hasDelimiterValue = false
          controller.hasPreloadValue = false
          controller.hasOpenOnFocusValue = false
          controller.hasCloseAfterSelectValue = false
          controller.hasHideSelectedValue = false
          controller.hasSelectedUrlValue = hasSelectedUrl
          controller.hasCreateUrlValue = false
          controller.hasUrlValue = true
          controller.hasErrorSurfaceIdValue = true
          controller.errorSurfaceIdValue = "error-surface"
          controller.urlValue = "/search"
          controller.queryParamsValue = { scope: "users" }
          controller.queryParamValue = "q"
          controller.selectedUrlValue = "/selected"
          controller.selectedQueryParamsValue = {}
          controller.selectedParamValue = "id"
          controller.selectedMultipleParamValue = "ids"
          controller.createParamsValue = {}
          controller.createParamValue = "text"
          controller.valueFieldValue = "value"
          controller.labelFieldValue = "text"
          controller.searchFieldValue = "text"
          controller.minLengthValue = 0
          controller.noResultsTextValue = "No results"
          controller.loadingTextValue = "Loading"
          controller.createTextValue = "Create"
          return { controller, surface }
        }

        {
          const requests = installFetchQueue()
          const { controller, surface } = buildController()
          controller.hasSelectedUrlValue = false
          controller.connect()

          const callbacks = []
          controller.loadOptions("alpha", (options) => callbacks.push({ query: "alpha", options }))
          controller.loadOptions("beta", (options) => callbacks.push({ query: "beta", options }))

          if (requests.length !== 2) throw new Error(`expected two search requests, got ${requests.length}`)
          if (!requests[0].options.signal || !requests[0].options.signal.aborted) {
            throw new Error("expected the first search request to be aborted after the second query started")
          }

          requests[0].resolve({ ok: true, json: async () => ({ options: [{ value: "stale", text: "Stale" }] }) })
          requests[1].resolve({ ok: true, json: async () => ({ options: [{ value: "fresh", text: "Fresh" }] }) })

          await flush()

          if (controller.__events.length !== 1 || controller.__events[0].name !== "load" || controller.__events[0].detail.query !== "beta") {
            throw new Error(`expected only the latest load event, got ${JSON.stringify(controller.__events)}`)
          }

          if (callbacks.length !== 1 || callbacks[0].query !== "beta" || callbacks[0].options[0].value !== "fresh") {
            throw new Error(`expected only the latest load callback, got ${JSON.stringify(callbacks)}`)
          }

          if (!surface.hidden || Object.keys(surface.dataset).length !== 0) {
            throw new Error(`expected aborts to avoid error surface state, got ${JSON.stringify(surface)}`)
          }
        }

        {
          const requests = installFetchQueue()
          const { controller, surface } = buildController({ hasSelectedUrl: true, selectedValue: ["42"] })
          controller.connect()

          if (requests.length !== 1) throw new Error(`expected one selected preload request, got ${requests.length}`)

          controller.disconnect()

          if (!requests[0].options.signal || !requests[0].options.signal.aborted) {
            throw new Error("expected disconnect to abort the selected preload request")
          }

          requests[0].resolve({ ok: true, json: async () => ({ option: { value: "42", text: "Answer" } }) })

          await flush()

          if (controller.__events.length !== 0) {
            throw new Error(`expected disconnect to suppress stale selected-load events, got ${JSON.stringify(controller.__events)}`)
          }

          if (!surface.hidden || Object.keys(surface.dataset).length !== 0) {
            throw new Error(`expected disconnect abort to keep the error surface clean, got ${JSON.stringify(surface)}`)
          }
        }
      JS

      run_node_runtime_check(controller_path, script:)
    end
  end
end
