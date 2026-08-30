# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select lookup selection normalization" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_controller_sandbox
    Dir.mktmpdir("rails-fields-kit-lookup-selection") do |tmpdir|
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
      File.write(File.join(stimulus_dir, "index.js"), <<~JS)
        export class Controller {
          dispatch(name, options = {}) {
            if (globalThis.__rfkDispatchObserver) globalThis.__rfkDispatchObserver(name, options)
          }
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
      expected lookup selection normalization checks to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "normalizes the accepted lookup before forwarding item-add" do
    build_controller_sandbox do |controller_path|
      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const Controller = (await import(pathToFileURL(process.argv[1]).href)).default
        const controller = new Controller()
        const textField = { value: "サ" }
        const idField = { value: "" }
        const textboxValues = []
        const observed = []
        const option = { value: "42", text: "サポート商事（TCUST0001）" }

        controller.kindValue = "lookup"
        controller.valueFieldValue = "value"
        controller.labelFieldValue = "text"
        controller.hasDisplayFieldValue = false
        controller.labelFallbackValue = true
        controller.lookupTextField = () => textField
        controller.lookupIdField = () => idField
        controller.tomSelect = {
          options: { "42": option },
          setTextboxValue(value) {
            textboxValues.push(value)
          }
        }

        globalThis.__rfkDispatchObserver = (name) => {
          observed.push({ name, text: textField.value, id: idField.value, textbox: textboxValues.at(-1) })
        }

        controller.dispatch("item-add", { detail: { value: "42", option } })

        assert(textField.value === "サポート商事（TCUST0001）", `expected selected label, got ${textField.value}`)
        assert(idField.value === "42", `expected selected id, got ${idField.value}`)
        assert(textboxValues.length === 1 && textboxValues[0] === "", `expected stale query to be cleared: ${JSON.stringify(textboxValues)}`)
        assert(observed.length === 1 && observed[0].name === "item-add", `expected item-add dispatch: ${JSON.stringify(observed)}`)
        assert(observed[0].text === "サポート商事（TCUST0001）", "external item-add observers should see the normalized label")
        assert(observed[0].id === "42", "external item-add observers should see the normalized id")
        assert(observed[0].textbox === "", "external item-add observers should see the cleared textbox buffer")
      JS

      run_node_check(controller_path, script:)
    end
  end

  it "does not alter non-lookup item-add dispatches" do
    build_controller_sandbox do |controller_path|
      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const assert = (condition, message) => {
          if (!condition) throw new Error(message)
        }

        const Controller = (await import(pathToFileURL(process.argv[1]).href)).default
        const controller = new Controller()
        const observed = []
        let textboxChanges = 0

        controller.kindValue = "tags"
        controller.tomSelect = {
          options: { alpha: { value: "alpha", text: "alpha" } },
          setTextboxValue() {
            textboxChanges += 1
          }
        }

        globalThis.__rfkDispatchObserver = (name) => observed.push(name)

        controller.dispatch("item-add", { detail: { value: "alpha" } })

        assert(textboxChanges === 0, "non-lookup fields must keep their textbox behavior")
        assert(observed.length === 1 && observed[0] === "item-add", "non-lookup item-add must still be forwarded")
      JS

      run_node_check(controller_path, script:)
    end
  end
end
