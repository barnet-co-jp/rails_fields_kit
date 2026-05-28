# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "rendered text override reader" do
  let(:repo_root) { File.expand_path("..", __dir__) }

  def build_helper_sandbox
    Dir.mktmpdir("rails-fields-kit-text-override-reader") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")

      FileUtils.mkdir_p(package_dir)
      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_text_overrides.js"),
        File.join(package_dir, "rendered_text_overrides.js")
      )

      yield File.join(package_dir, "rendered_text_overrides.js")
    end
  end

  def run_node_check(helper_path, script)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, helper_path)

    expect(status).to be_success, <<~MESSAGE
      expected rendered text override helper to behave as documented

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "returns the rendered text overrides for a Rails Fields Kit field" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedTextOverrides } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-kind-value": "combobox",
              "data-rails-fields-kit--tom-select-no-results-text-value": "No matches",
              "data-rails-fields-kit--tom-select-loading-text-value": "Searching...",
              "data-rails-fields-kit--tom-select-create-text-value": "Create"
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const overrides = readRenderedTextOverrides(element)
        if (!overrides) throw new Error("expected text overrides for rendered field")
        if (overrides.noResultsText !== "No matches") throw new Error("missing noResultsText")
        if (overrides.loadingText !== "Searching...") throw new Error("missing loadingText")
        if (overrides.createText !== "Create") throw new Error("missing createText")
      JS

      run_node_check(helper_path, script)
    end
  end

  it "reads the final rendered fallback copy when no field-level override is present" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedTextOverrides } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-kind-value": "select",
              "data-rails-fields-kit--tom-select-no-results-text-value": "該当する項目はありません",
              "data-rails-fields-kit--tom-select-loading-text-value": "読み込み中...",
              "data-rails-fields-kit--tom-select-create-text-value": "追加"
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const overrides = readRenderedTextOverrides(element)
        if (overrides.noResultsText !== "該当する項目はありません") {
          throw new Error("missing rendered fallback noResultsText")
        }
        if (overrides.loadingText !== "読み込み中...") {
          throw new Error("missing rendered fallback loadingText")
        }
        if (overrides.createText !== "追加") {
          throw new Error("missing rendered fallback createText")
        }
      JS

      run_node_check(helper_path, script)
    end
  end

  it "returns null when the rendered field is not a Rails Fields Kit Tom Select field" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedTextOverrides } = await import(helperUrl)

        const element = {
          getAttribute() {
            return null
          }
        }

        if (readRenderedTextOverrides(element) !== null) {
          throw new Error("expected null when kind is not present")
        }
      JS

      run_node_check(helper_path, script)
    end
  end
end
