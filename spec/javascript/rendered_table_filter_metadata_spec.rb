# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "rendered table filter metadata reader" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_runtime_sandbox
    Dir.mktmpdir("rails-fields-kit-table-filter-metadata") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")
      stimulus_dir = File.join(tmpdir, "node_modules/@hotwired/stimulus")
      tom_select_dir = File.join(tmpdir, "node_modules/tom-select")

      FileUtils.mkdir_p(package_dir)
      FileUtils.mkdir_p(stimulus_dir)
      FileUtils.mkdir_p(tom_select_dir)

      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(File.join(repo_root, "app/javascript/rails_fields_kit/index.js"), File.join(package_dir, "index.js"))
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

      yield tmpdir
    end
  end

  def run_node_runtime_check(*paths, script:)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, *paths)

    expect(status).to be_success, <<~MESSAGE
      expected rendered table filter metadata checks to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "reads Ransack table filter metadata without exposing parsing or query execution" do
    build_runtime_sandbox do |tmpdir|
      entrypoint_path = File.join(tmpdir, "app/javascript/rails_fields_kit/index.js")

      script = <<~'JS'
        import { pathToFileURL } from "node:url"

        const { readRenderedTableFilterMetadata } = await import(pathToFileURL(process.argv[1]).href)

        function elementWith(attributes) {
          return {
            getAttribute(name) {
              return attributes[name] ?? null
            },
            hasAttribute(name) {
              return Object.prototype.hasOwnProperty.call(attributes, name)
            }
          }
        }

        const metadata = readRenderedTableFilterMetadata(elementWith({
          "data-rails-fields-kit-table-filter-adapter": "ransack",
          "data-rails-fields-kit-table-filter-param-name": "q",
          "data-rails-fields-kit-table-filter-fields": JSON.stringify({ name: "name_cont", status: "status_eq" })
        }))

        if (JSON.stringify(metadata) !== JSON.stringify({
          adapter: "ransack",
          paramName: "q",
          fields: { name: "name_cont", status: "status_eq" }
        })) {
          throw new Error(`unexpected metadata: ${JSON.stringify(metadata)}`)
        }

        if (readRenderedTableFilterMetadata(elementWith({})) !== null) {
          throw new Error("expected non-table or non-Ransack fields to return null")
        }

        if (readRenderedTableFilterMetadata(null) !== null) {
          throw new Error("expected null elements to return null")
        }
      JS

      run_node_runtime_check(entrypoint_path, script:)
    end
  end
end
