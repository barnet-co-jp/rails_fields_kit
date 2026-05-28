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
          .gsub('"./rendered_create_on_the_fly_config"', '"./rendered_create_on_the_fly_config.js"')
          .gsub('"./rendered_remote_search_config"', '"./rendered_remote_search_config.js"')
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/tom_select_controller.js"),
        File.join(package_dir, "tom_select_controller.js")
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_create_on_the_fly_config.js"),
        File.join(package_dir, "rendered_create_on_the_fly_config.js")
      )
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_remote_search_config.js"),
        File.join(package_dir, "rendered_remote_search_config.js")
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

        if (typeof indexModule.readRenderedCreateOnTheFlyConfig !== "function") {
          throw new Error("package root did not export readRenderedCreateOnTheFlyConfig")
        }

        const createElement = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-create-url-value": "/customers.json",
              "data-rails-fields-kit--tom-select-create-param-value": "customer[name]",
              "data-rails-fields-kit--tom-select-create-params-value": JSON.stringify({ account_id: 7 })
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const createConfig = indexModule.readRenderedCreateOnTheFlyConfig(createElement)
        if (!createConfig || createConfig.createUrl !== "/customers.json") {
          throw new Error("create-on-the-fly helper did not read the create_url value")
        }

        if (createConfig.createParam !== "customer[name]") {
          throw new Error("create-on-the-fly helper did not preserve the create param name")
        }

        if (createConfig.createParams.account_id !== 7) {
          throw new Error("create-on-the-fly helper did not decode create params")
        }

        if (typeof indexModule.readRenderedRemoteSearchConfig !== "function") {
          throw new Error("package root did not export readRenderedRemoteSearchConfig")
        }

        const remoteSearchElement = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-url-value": "/customers/search.json",
              "data-rails-fields-kit--tom-select-query-param-value": "customer[name]",
              "data-rails-fields-kit--tom-select-query-params-value": JSON.stringify({ account_id: 7 })
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const remoteSearchConfig = indexModule.readRenderedRemoteSearchConfig(remoteSearchElement)
        if (!remoteSearchConfig || remoteSearchConfig.url !== "/customers/search.json") {
          throw new Error("remote search helper did not read the url value")
        }

        if (remoteSearchConfig.queryParam !== "customer[name]") {
          throw new Error("remote search helper did not preserve the query param name")
        }

        if (remoteSearchConfig.queryParams.account_id !== 7) {
          throw new Error("remote search helper did not decode query params")
        }
      JS

      run_node_entrypoint_check(index_entrypoint_path, controller_entrypoint_path, script:)
    end
  end
end
