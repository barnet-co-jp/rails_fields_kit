# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select controller contract" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_controller_sandbox
    Dir.mktmpdir("rails-fields-kit-tom-select-controller") do |tmpdir|
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
      File.write(File.join(tom_select_dir, "index.js"), "export default class TomSelect {}\n")

      yield File.join(package_dir, "tom_select_controller.js")
    end
  end

  def run_node_controller_check(controller_path, script:)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, controller_path)

    expect(status).to be_success, <<~MESSAGE
      expected Tom Select controller contract check to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "adds the CSRF header for create requests only when the meta tag provides a token" do
    build_controller_sandbox do |controller_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const controllerUrl = pathToFileURL(process.argv[1]).href
        const Controller = (await import(controllerUrl)).default
        const controller = new Controller()

        globalThis.document = {
          querySelector(selector) {
            if (selector !== "meta[name='csrf-token']") throw new Error(`unexpected selector ${selector}`)
            return { content: "secure-token" }
          }
        }

        const headersWithToken = controller.createRequestHeaders()
        if (headersWithToken.Accept !== "application/json") throw new Error("missing Accept header")
        if (headersWithToken["Content-Type"] !== "application/json") throw new Error("missing Content-Type header")
        if (headersWithToken["X-CSRF-Token"] !== "secure-token") throw new Error("missing CSRF token header")

        globalThis.document = {
          querySelector() { return null }
        }

        const headersWithoutToken = controller.createRequestHeaders()
        if (headersWithoutToken.Accept !== "application/json") throw new Error("missing Accept header without token")
        if (headersWithoutToken["Content-Type"] !== "application/json") throw new Error("missing Content-Type header without token")
        if (Object.prototype.hasOwnProperty.call(headersWithoutToken, "X-CSRF-Token")) {
          throw new Error("CSRF header should be omitted when the meta tag is absent")
        }
      JS

      run_node_controller_check(controller_path, script:)
    end
  end
end
