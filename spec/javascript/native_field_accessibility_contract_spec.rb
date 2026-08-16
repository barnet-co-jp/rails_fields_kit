# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "native field accessibility contract helper" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_package_root_sandbox
    Dir.mktmpdir("rails-fields-kit-native-field-contract") do |tmpdir|
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
      expected native field accessibility contract harness to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "reads describedby ids, hint, error, and wrapper from a rendered native field" do
    build_package_root_sandbox do |index_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        class FakeDocument {
          constructor() {
            this.elements = new Map()
          }

          register(element) {
            element.ownerDocument = this
            if (element.id) this.elements.set(element.id, element)
            return element
          }

          getElementById(id) {
            return this.elements.get(id) || null
          }
        }

        class FakeElement {
          constructor(tagName, { id = null, className = "", attributes = {}, parent = null } = {}) {
            this.tagName = tagName.toUpperCase()
            this.id = id
            this.parentElement = parent
            this.attributes = { ...attributes }
            if (id) this.attributes.id = id
            if (className) this.attributes.class = className
            this.classList = {
              contains: (className) => (this.attributes.class || "").split(/\\s+/).includes(className)
            }
          }

          getAttribute(name) {
            return Object.hasOwn(this.attributes, name) ? this.attributes[name] : null
          }

          closest(selector) {
            if (selector !== ".rfk-field") return null

            let element = this
            while (element) {
              if (element.classList.contains("rfk-field")) return element
              element = element.parentElement
            }
            return null
          }
        }

        const indexUrl = pathToFileURL(process.argv[1]).href
        const { nativeFieldAccessibilityContract } = await import(indexUrl)

        const document = new FakeDocument()
        const wrapper = document.register(new FakeElement("div", { id: "order_name_field", className: "rfk-field" }))
        const hint = document.register(new FakeElement("div", { id: "order_name_hint", className: "rfk-hint", parent: wrapper }))
        const error = document.register(new FakeElement("div", { id: "order_name_error", className: "rfk-error", parent: wrapper }))
        const input = document.register(new FakeElement("input", {
          parent: wrapper,
          attributes: { "aria-describedby": "order_name_hint order_name_error" }
        }))

        const contract = nativeFieldAccessibilityContract(input)

        assert(contract.describedByIds.join(" ") === "order_name_hint order_name_error", "describedby ids should stay ordered")
        assert(contract.describedByElements.length === 2, "describedby elements should resolve from the owner document")
        assert(contract.describedByElements[0] === hint, "hint element should remain in describedby order")
        assert(contract.hintElement === hint, "hintElement should resolve by the rendered hint class")
        assert(contract.errorElement === error, "errorElement should resolve by the rendered error class")
        assert(contract.wrapperElement === wrapper, "wrapperElement should resolve the nearest field wrapper")
      JS

      run_node_contract_check(index_path, script:)
    end
  end

  it "returns explicit empty values without creating accessibility wiring" do
    build_package_root_sandbox do |index_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        class FakeElement {
          constructor(tagName, { className = "", parent = null } = {}) {
            this.tagName = tagName.toUpperCase()
            this.parentElement = parent
            this.attributes = className ? { class: className } : {}
            this.ownerDocument = { getElementById: () => null }
            this.classList = {
              contains: (className) => (this.attributes.class || "").split(/\\s+/).includes(className)
            }
          }

          getAttribute(name) {
            return Object.hasOwn(this.attributes, name) ? this.attributes[name] : null
          }

          closest(selector) {
            if (selector !== ".rfk-field") return null

            let element = this
            while (element) {
              if (element.classList.contains("rfk-field")) return element
              element = element.parentElement
            }
            return null
          }
        }

        const indexUrl = pathToFileURL(process.argv[1]).href
        const { nativeFieldAccessibilityContract } = await import(indexUrl)
        const wrapper = new FakeElement("div", { className: "rfk-field" })
        const input = new FakeElement("input", { parent: wrapper })

        const contract = nativeFieldAccessibilityContract(input)

        assert(Array.isArray(contract.describedByIds) && contract.describedByIds.length === 0, "missing aria-describedby should be an empty id list")
        assert(Array.isArray(contract.describedByElements) && contract.describedByElements.length === 0, "missing aria-describedby should be an empty element list")
        assert(contract.hintElement === null, "missing hint should be null")
        assert(contract.errorElement === null, "missing error should be null")
        assert(contract.wrapperElement === wrapper, "wrapper should still be readable when accessibility is opted out")
      JS

      run_node_contract_check(index_path, script:)
    end
  end

  it "returns null for non-native or non-element inputs" do
    build_package_root_sandbox do |index_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const indexUrl = pathToFileURL(process.argv[1]).href
        const { nativeFieldAccessibilityContract } = await import(indexUrl)
        const unrelated = {
          tagName: "DIV",
          getAttribute() { return null },
          closest() { return null }
        }

        assert(nativeFieldAccessibilityContract(null) === null, "null should return null")
        assert(nativeFieldAccessibilityContract({}) === null, "non-elements should return null")
        assert(nativeFieldAccessibilityContract(unrelated) === null, "unrelated elements should return null")
      JS

      run_node_contract_check(index_path, script:)
    end
  end
end
