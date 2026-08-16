# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "Tom Select request lifecycle" do
  let(:repo_root) { File.expand_path("../..", __dir__) }

  def build_controller_sandbox
    Dir.mktmpdir("rfk-tom-select-lifecycle") do |tmpdir|
      stimulus_dir = File.join(tmpdir, "node_modules/@hotwired/stimulus")
      tom_select_dir = File.join(tmpdir, "node_modules/tom-select")

      FileUtils.mkdir_p(stimulus_dir)
      FileUtils.mkdir_p(tom_select_dir)
      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/tom_select_controller.js"),
        File.join(tmpdir, "tom_select_controller.js")
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

  def run_node_lifecycle_check(script, *paths, chdir: nil)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, *paths, chdir:)

    expect(status).to be_success, <<~MESSAGE
      expected Tom Select request lifecycle harness to pass

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "keeps stale request tokens from remaining current after a newer request starts" do
    build_controller_sandbox do |tmpdir|
      controller_path = File.join(tmpdir, "tom_select_controller.js")
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const { default: ControllerClass } = await import(pathToFileURL(process.argv[1]).href)
        const controller = new ControllerClass()
        controller.connected = true
        controller.requestControllers = {}
        controller.requestTokens = {}

        const first = controller.beginRequest("load")
        const second = controller.beginRequest("load")

        if (!first.signal.aborted) throw new Error("starting a newer load request should abort the previous signal")
        if (controller.requestIsCurrent("load", first.token)) throw new Error("stale load token should not remain current")
        if (!controller.requestIsCurrent("load", second.token)) throw new Error("latest load token should remain current")

        controller.finishRequest("load", first.token)
        if (!controller.requestIsCurrent("load", second.token)) throw new Error("finishing a stale token should not clear the latest request")

        controller.finishRequest("load", second.token)
        if (controller.requestIsCurrent("load", second.token)) throw new Error("finishing the latest token should clear the request")
      JS

      run_node_lifecycle_check(script, controller_path, chdir: tmpdir)
    end
  end

  it "aborts all request operations and clears tokens on disconnect" do
    build_controller_sandbox do |tmpdir|
      controller_path = File.join(tmpdir, "tom_select_controller.js")
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const { default: ControllerClass } = await import(pathToFileURL(process.argv[1]).href)
        const controller = new ControllerClass()
        controller.connected = true
        controller.requestControllers = {}
        controller.requestTokens = {}
        let destroyed = false
        controller.tomSelect = { destroy: () => { destroyed = true } }

        const load = controller.beginRequest("load")
        const selected = controller.beginRequest("selected-load")
        const create = controller.beginRequest("create")

        controller.disconnect()

        if (!load.signal.aborted) throw new Error("load request should abort on disconnect")
        if (!selected.signal.aborted) throw new Error("selected preload request should abort on disconnect")
        if (!create.signal.aborted) throw new Error("create request should abort on disconnect")
        if (controller.requestIsCurrent("load", load.token)) throw new Error("load token should not remain current after disconnect")
        if (controller.requestIsCurrent("selected-load", selected.token)) throw new Error("selected-load token should not remain current after disconnect")
        if (controller.requestIsCurrent("create", create.token)) throw new Error("create token should not remain current after disconnect")
        if (!destroyed) throw new Error("Tom Select instance should still be destroyed on disconnect")
      JS

      run_node_lifecycle_check(script, controller_path, chdir: tmpdir)
    end
  end
end
