# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "package metadata" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:package_json_path) { File.join(repo_root, "package.json") }

  def build_entrypoint_sandbox
    Dir.mktmpdir("rails-fields-kit-entrypoints") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")
      stimulus_dir = File.join(tmpdir, "node_modules/@hotwired/stimulus")
      tom_select_dir = File.join(tmpdir, "node_modules/tom-select")

      FileUtils.mkdir_p(package_dir)
      FileUtils.mkdir_p(stimulus_dir)
      FileUtils.mkdir_p(tom_select_dir)

      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      File.write(
        File.join(package_dir, "index.js"),
        File.read(File.join(repo_root, "app/javascript/rails_fields_kit/index.js"))
          .gsub('"./tom_select_controller"', '"./tom_select_controller.js"')
          .gsub('"./rendered_interaction_config"', '"./rendered_interaction_config.js"')
          .gsub('"./rendered_option_payload_mapping"', '"./rendered_option_payload_mapping.js"')
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/tom_select_controller.js"),
        File.join(package_dir, "tom_select_controller.js")
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_interaction_config.js"),
        File.join(package_dir, "rendered_interaction_config.js")
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_option_payload_mapping.js"),
        File.join(package_dir, "rendered_option_payload_mapping.js")
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

  def run_node_entrypoint_check(*paths, script:)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, *paths)

    expect(status).to be_success, <<~MESSAGE
      expected documented JavaScript entrypoints to load successfully

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "exports the documented JavaScript entrypoints" do
    package = JSON.parse(File.read(package_json_path))

    expect(package.fetch("name")).to eq("rails_fields_kit")
    expect(package.fetch("type")).to eq("module")
    expect(package.fetch("exports")).to eq(
      "." => "./app/javascript/rails_fields_kit/index.js",
      "./tom_select_controller" => "./app/javascript/rails_fields_kit/tom_select_controller.js"
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

        if (typeof indexModule.readRenderedInteractionConfig !== "function") {
          throw new Error("package root did not export readRenderedInteractionConfig")
        }

        const interactionElement = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-kind-value": "combobox",
              "data-rails-fields-kit--tom-select-max-options-value": "25",
              "data-rails-fields-kit--tom-select-load-throttle-value": "300",
              "data-rails-fields-kit--tom-select-preload-value": "true",
              "data-rails-fields-kit--tom-select-open-on-focus-value": "false",
              "data-rails-fields-kit--tom-select-close-after-select-value": "true",
              "data-rails-fields-kit--tom-select-hide-selected-value": "true",
              "data-rails-fields-kit--tom-select-persist-value": "true"
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const interactionConfig = indexModule.readRenderedInteractionConfig(interactionElement)
        if (!interactionConfig || interactionConfig.maxOptions !== 25) {
          throw new Error("interaction config helper did not read maxOptions")
        }

        if (interactionConfig.loadThrottle !== 300) {
          throw new Error("interaction config helper did not read loadThrottle")
        }

        if (interactionConfig.persist !== true) {
          throw new Error("interaction config helper did not read persist")
        }

        if (typeof indexModule.readRenderedOptionPayloadMapping !== "function") {
          throw new Error("package root did not export readRenderedOptionPayloadMapping")
        }

        const mappingElement = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-kind-value": "combobox",
              "data-rails-fields-kit--tom-select-value-field-value": "id",
              "data-rails-fields-kit--tom-select-label-field-value": "name",
              "data-rails-fields-kit--tom-select-search-field-value": "name,email",
              "data-rails-fields-kit--tom-select-option-description-field-value": "email",
              "data-rails-fields-kit--tom-select-option-badge-field-value": "status"
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const mapping = indexModule.readRenderedOptionPayloadMapping(mappingElement)
        if (!mapping || mapping.valueField !== "id") {
          throw new Error("option payload mapping helper did not read the value field")
        }

        if (mapping.labelField !== "name") {
          throw new Error("option payload mapping helper did not preserve the label field")
        }

        if (mapping.searchFields.join("|") !== "name|email") {
          throw new Error("option payload mapping helper did not decode the search fields")
        }

        if (mapping.optionDescriptionField !== "email") {
          throw new Error("option payload mapping helper did not read the description field")
        }

        if (mapping.optionBadgeField !== "status") {
          throw new Error("option payload mapping helper did not read the badge field")
        }
      JS

      run_node_entrypoint_check(index_entrypoint_path, controller_entrypoint_path, script:)
    end
  end
end
