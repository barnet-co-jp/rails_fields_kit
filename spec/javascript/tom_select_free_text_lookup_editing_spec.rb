# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select free-text lookup editing" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_controller_sandbox
    Dir.mktmpdir("rails-fields-kit-free-text-lookup") do |tmpdir|
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
      File.write(File.join(stimulus_dir, "index.js"), <<~JS)
        export class Controller {
          dispatch() {}
        }
      JS
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
      expected free-text lookup editing harness to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "restores only user-created lookup values into the textbox on focus" do
    build_controller_sandbox do |controller_path|
      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const Controller = (await import(pathToFileURL(process.argv[1]).href)).default

        function buildController({ kind = "lookup", freeText = true, createOnBlur = true, userCreated = true } = {}) {
          const controller = new Controller()
          const textField = { value: "やき" }
          const idField = { value: "やき" }
          const calls = []
          const value = "やき"
          const option = { value, text: value }

          controller.kindValue = kind
          controller.freeTextValue = freeText
          controller.createOnBlurValue = createOnBlur
          controller.hasUrlValue = true
          controller.minLengthValue = 0
          controller.labelFieldValue = "text"
          controller.valueFieldValue = "value"
          controller.hasDisplayFieldValue = false
          controller.labelFallbackValue = true
          controller.lookupTextField = () => textField
          controller.lookupIdField = () => idField
          controller.tomSelect = {
            options: { [value]: option },
            userOptions: userCreated ? { [value]: true } : {},
            getValue() {
              return value
            },
            removeItem(removedValue, silent) {
              calls.push(["removeItem", removedValue, silent])
            },
            setTextboxValue(text) {
              calls.push(["setTextboxValue", text])
            },
            load(query) {
              calls.push(["load", query])
            }
          }

          return { controller, textField, idField, calls }
        }

        {
          const { controller, textField, idField, calls } = buildController()
          controller.restoreFreeTextLookupForEditing()

          assert(calls.length === 3, `expected remove, textbox restore, and load calls: ${JSON.stringify(calls)}`)
          assert(calls[0][0] === "removeItem" && calls[0][1] === "やき" && calls[0][2] === true, "free-text item should be silently removed")
          assert(calls[1][0] === "setTextboxValue" && calls[1][1] === "やき", "free-text should return to the textbox")
          assert(calls[2][0] === "load" && calls[2][1] === "やき", "restored text should be used for remote search")
          assert(textField.value === "やき", "lookup text hidden field should keep the free text")
          assert(idField.value === "", "lookup id hidden field should be cleared while editing free text")
        }

        {
          const { controller, calls } = buildController({ userCreated: false })
          controller.restoreFreeTextLookupForEditing()
          assert(calls.length === 0, "a normal selected option must remain selected on focus")
        }

        {
          const { controller, calls } = buildController({ kind: "tags" })
          controller.restoreFreeTextLookupForEditing()
          assert(calls.length === 0, "non-lookup fields must keep their existing behavior")
        }

        {
          const { controller, calls } = buildController({ createOnBlur: false })
          controller.restoreFreeTextLookupForEditing()
          assert(calls.length === 0, "lookup fields without create_on_blur must keep their existing behavior")
        }
      JS

      run_node_check(controller_path, script:)
    end
  end
end
