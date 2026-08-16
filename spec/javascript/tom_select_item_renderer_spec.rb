# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select item renderer" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_renderer_sandbox
    Dir.mktmpdir("rails-fields-kit-item-renderer") do |tmpdir|
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
      File.write(File.join(tom_select_dir, "index.js"), "export default class TomSelect {}\n")

      yield tmpdir
    end
  end

  def run_node_renderer_check(*paths, script:)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, *paths)

    expect(status).to be_success, <<~MESSAGE
      expected Tom Select item renderer checks to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "renders selected items as compact tokens without reusing option markup" do
    build_renderer_sandbox do |tmpdir|
      controller_path = File.join(tmpdir, "app/javascript/rails_fields_kit/tom_select_controller.js")

      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const { default: TomSelectController } = await import(pathToFileURL(process.argv[1]).href)
        const controller = new TomSelectController()
        controller.labelFieldValue = "text"
        controller.valueFieldValue = "value"
        controller.labelFallbackValue = true
        controller.hasOptionDescriptionFieldValue = true
        controller.optionDescriptionFieldValue = "description"
        controller.hasOptionBadgeFieldValue = true
        controller.optionBadgeFieldValue = "badge"

        const escape = (value) => String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;")
        const renderers = controller.renderers()
        const data = {
          value: "alpha",
          text: "Alpha & Beta",
          description: "Verbose helper text",
          badge: "Current"
        }

        const item = renderers.item(data, escape)
        const expectedItem = '<span class="rfk-item-token"><span class="rfk-item-label">Alpha &amp; Beta</span></span>'
        if (item !== expectedItem) throw new Error(`expected compact item markup ${expectedItem}, got ${item}`)
        if (item.includes("rfk-option-main") || item.includes("rfk-option-description") || item.includes("rfk-option-badge")) {
          throw new Error(`expected selected item markup to omit rich option blocks, got ${item}`)
        }

        const option = renderers.option(data, escape)
        if (!option.includes("rfk-option-main") || !option.includes("rfk-option-description") || !option.includes("rfk-option-badge")) {
          throw new Error(`expected option markup to keep rich option blocks, got ${option}`)
        }
      JS

      run_node_renderer_check(controller_path, script:)
    end
  end


  it "renders escaped declarative metadata and synchronizes lookup fields" do
    build_renderer_sandbox do |tmpdir|
      controller_path = File.join(tmpdir, "app/javascript/rails_fields_kit/tom_select_controller.js")

      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const { default: TomSelectController } = await import(pathToFileURL(process.argv[1]).href)
        const controller = new TomSelectController()
        controller.labelFieldValue = "name"
        controller.valueFieldValue = "value"
        controller.labelFallbackValue = true
        controller.hasOptionDescriptionFieldValue = false
        controller.hasOptionBadgeFieldValue = false
        controller.hasOptionMetadataFieldsValue = true
        controller.optionMetadataFieldsValue = [
          { field: "price", label: "Price", suffix: " yen" },
          { field: "category", style: "badge" }
        ]
        const escape = (value) => String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;")
        const option = controller.renderers().option({ value: "1", name: "Product", price: "<100>", category: "Food" }, escape)
        if (!option.includes("rfk-option-metadata") || !option.includes("&lt;100&gt; yen") || option.includes("<100>")) throw new Error(option)
        if (!option.includes("rfk-option-metadata--badge")) throw new Error(option)

        const textField = { value: "" }
        const idField = { value: "" }
        controller.kindValue = "lookup"
        controller.lookupTextField = () => textField
        controller.lookupIdField = () => idField
        controller.tomSelect = { options: { "1": { value: "1", name: "Product" } } }
        controller.syncLookupSelection("1")
        if (textField.value !== "Product" || idField.value !== "1") throw new Error(`${textField.value}:${idField.value}`)
      JS

      run_node_renderer_check(controller_path, script:)
    end
  end
end
