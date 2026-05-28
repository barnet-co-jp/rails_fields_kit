# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "rendered interaction config reader" do
  let(:repo_root) { File.expand_path("..", __dir__) }

  def build_helper_sandbox
    Dir.mktmpdir("rails-fields-kit-interaction-reader") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")

      FileUtils.mkdir_p(package_dir)
      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_interaction_config.js"),
        File.join(package_dir, "rendered_interaction_config.js")
      )

      yield File.join(package_dir, "rendered_interaction_config.js")
    end
  end

  def run_node_check(helper_path, script)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, helper_path)

    expect(status).to be_success, <<~MESSAGE
      expected rendered interaction config helper to behave as documented

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "returns a stable interaction config for rendered fields" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedInteractionConfig } = await import(helperUrl)

        const element = {
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

        const config = readRenderedInteractionConfig(element)
        if (!config) throw new Error("expected config for rendered field")
        if (config.maxOptions !== 25) throw new Error("missing maxOptions")
        if (config.loadThrottle !== 300) throw new Error("missing loadThrottle")
        if (config.preload !== true) throw new Error("missing preload")
        if (config.openOnFocus !== false) throw new Error("missing openOnFocus")
        if (config.closeAfterSelect !== true) throw new Error("missing closeAfterSelect")
        if (config.hideSelected !== true) throw new Error("missing hideSelected")
        if (config.persist !== true) throw new Error("missing persist")
      JS

      run_node_check(helper_path, script)
    end
  end

  it "covers representative multiple-value interaction settings" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedInteractionConfig } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-kind-value": "token_search",
              "data-rails-fields-kit--tom-select-max-items-value": "20",
              "data-rails-fields-kit--tom-select-delimiter-value": " ",
              "data-rails-fields-kit--tom-select-persist-value": "false"
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const config = readRenderedInteractionConfig(element)
        if (config.maxItems !== 20) throw new Error("missing maxItems")
        if (config.delimiter !== " ") throw new Error("missing delimiter")
        if (config.persist !== false) throw new Error("missing persist override")
      JS

      run_node_check(helper_path, script)
    end
  end

  it "falls back to the documented default interaction shape" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedInteractionConfig } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            if (name === "data-rails-fields-kit--tom-select-kind-value") {
              return "select"
            }

            return null
          }
        }

        const config = readRenderedInteractionConfig(element)
        if (config.maxOptions !== null) throw new Error("expected null maxOptions")
        if (config.maxItems !== null) throw new Error("expected null maxItems")
        if (config.loadThrottle !== null) throw new Error("expected null loadThrottle")
        if (config.delimiter !== null) throw new Error("expected null delimiter")
        if (config.preload !== null) throw new Error("expected null preload")
        if (config.openOnFocus !== null) throw new Error("expected null openOnFocus")
        if (config.closeAfterSelect !== null) throw new Error("expected null closeAfterSelect")
        if (config.hideSelected !== null) throw new Error("expected null hideSelected")
        if (config.persist !== false) throw new Error("expected default persist false")
      JS

      run_node_check(helper_path, script)
    end
  end

  it "returns null when the rendered field is not a Rails Fields Kit Tom Select field" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedInteractionConfig } = await import(helperUrl)

        const element = {
          getAttribute() {
            return null
          }
        }

        if (readRenderedInteractionConfig(element) !== null) {
          throw new Error("expected null when kind is not present")
        }
      JS

      run_node_check(helper_path, script)
    end
  end
end
