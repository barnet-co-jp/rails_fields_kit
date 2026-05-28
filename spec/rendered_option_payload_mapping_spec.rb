# frozen_string_literal: true

require "fileutils"
require "open3"
require "spec_helper"
require "tmpdir"

RSpec.describe "rendered option payload mapping reader" do
  let(:repo_root) { File.expand_path("..", __dir__) }

  def build_helper_sandbox
    Dir.mktmpdir("rails-fields-kit-option-payload-reader") do |tmpdir|
      package_dir = File.join(tmpdir, "app/javascript/rails_fields_kit")

      FileUtils.mkdir_p(package_dir)
      File.write(File.join(tmpdir, "package.json"), "{\n  \"type\": \"module\"\n}\n")
      FileUtils.cp(
        File.join(repo_root, "app/javascript/rails_fields_kit/rendered_option_payload_mapping.js"),
        File.join(package_dir, "rendered_option_payload_mapping.js")
      )

      yield File.join(package_dir, "rendered_option_payload_mapping.js")
    end
  end

  def run_node_check(helper_path, script)
    stdout, stderr, status = Open3.capture3("node", "--input-type=module", "-e", script, helper_path)

    expect(status).to be_success, <<~MESSAGE
      expected option payload mapping helper to behave as documented

      stdout:
      #{stdout}

      stderr:
      #{stderr}
    MESSAGE
  end

  it "returns a stable option payload mapping for rendered fields" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedOptionPayloadMapping } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            const attributes = {
              "data-rails-fields-kit--tom-select-kind-value": "combobox",
              "data-rails-fields-kit--tom-select-value-field-value": "id",
              "data-rails-fields-kit--tom-select-label-field-value": "name",
              "data-rails-fields-kit--tom-select-search-field-value": "name, email , status",
              "data-rails-fields-kit--tom-select-option-description-field-value": "email",
              "data-rails-fields-kit--tom-select-option-badge-field-value": "status"
            }

            return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
          }
        }

        const mapping = readRenderedOptionPayloadMapping(element)
        if (!mapping) throw new Error("expected mapping for rendered field")
        if (mapping.valueField !== "id") throw new Error("missing valueField")
        if (mapping.labelField !== "name") throw new Error("missing labelField")
        if (mapping.searchFields.join("|") !== "name|email|status") {
          throw new Error("missing searchFields")
        }
        if (mapping.optionDescriptionField !== "email") {
          throw new Error("missing optionDescriptionField")
        }
        if (mapping.optionBadgeField !== "status") {
          throw new Error("missing optionBadgeField")
        }
      JS

      run_node_check(helper_path, script)
    end
  end

  it "falls back to documented defaults and null rich-rendering fields" do
    build_helper_sandbox do |helper_path|
      script = <<~JS
        import { pathToFileURL } from "node:url"

        const helperUrl = pathToFileURL(process.argv[1]).href
        const { readRenderedOptionPayloadMapping } = await import(helperUrl)

        const element = {
          getAttribute(name) {
            if (name === "data-rails-fields-kit--tom-select-kind-value") {
              return "select"
            }

            return null
          }
        }

        const mapping = readRenderedOptionPayloadMapping(element)
        if (mapping.valueField !== "value") throw new Error("expected default valueField")
        if (mapping.labelField !== "text") throw new Error("expected default labelField")
        if (mapping.searchFields.join("|") !== "text") {
          throw new Error("expected default searchFields")
        }
        if (mapping.optionDescriptionField !== null) {
          throw new Error("expected null optionDescriptionField")
        }
        if (mapping.optionBadgeField !== null) {
          throw new Error("expected null optionBadgeField")
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
        const { readRenderedOptionPayloadMapping } = await import(helperUrl)

        const element = {
          getAttribute() {
            return null
          }
        }

        if (readRenderedOptionPayloadMapping(element) !== null) {
          throw new Error("expected null when kind is not present")
        }
      JS

      run_node_check(helper_path, script)
    end
  end
end
