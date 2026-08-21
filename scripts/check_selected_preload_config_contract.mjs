import assert from "node:assert/strict"
import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-selected-preload-config-"))

function elementWithAttributes(attributes) {
  return {
    getAttribute(name) {
      return attributes[name] ?? null
    },
    hasAttribute(name) {
      return Object.hasOwn(attributes, name)
    }
  }
}

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\",\n  \"exports\": \"./index.js\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

try {
  const packageRoot = path.join(sandboxRoot, "node_modules", "rails_fields_kit")
  await mkdir(path.join(packageRoot, "app", "javascript", "rails_fields_kit"), { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\",\n  \"exports\": \"./app/javascript/rails_fields_kit/index.js\"\n}\n")
  await cp(
    path.join(repoRoot, "app", "javascript", "rails_fields_kit", "index.js"),
    path.join(packageRoot, "app", "javascript", "rails_fields_kit", "index.js")
  )
  await cp(
    path.join(repoRoot, "app", "javascript", "rails_fields_kit", "tom_select_controller.js"),
    path.join(packageRoot, "app", "javascript", "rails_fields_kit", "tom_select_controller.js")
  )
  await cp(
    path.join(repoRoot, "app", "javascript", "rails_fields_kit", "tom_select_controller_base.js"),
    path.join(packageRoot, "app", "javascript", "rails_fields_kit", "tom_select_controller_base.js")
  )

  await writeStubPackage(
    "@hotwired/stimulus",
    "export class Controller {\n  static values = {}\n}\n"
  )
  await writeStubPackage(
    "tom-select",
    "export default class TomSelect {\n  constructor(element, options = {}) {\n    this.element = element\n    this.options = options\n  }\n\n  destroy() {}\n}\n"
  )

  const { readRenderedSelectedPreloadConfig } = await import(pathToFileURL(path.join(packageRoot, "app", "javascript", "rails_fields_kit", "index.js")).href)

  const fullConfigElement = elementWithAttributes({
    "data-rails-fields-kit--tom-select-selected-url-value": "/customers/selected.json",
    "data-rails-fields-kit--tom-select-selected-param-value": "customer_id",
    "data-rails-fields-kit--tom-select-selected-multiple-param-value": "customer_ids",
    "data-rails-fields-kit--tom-select-selected-query-params-value": JSON.stringify({ account_id: "42", locale: "ja" })
  })
  assert.deepEqual(readRenderedSelectedPreloadConfig(fullConfigElement), {
    selectedUrl: "/customers/selected.json",
    selectedParam: "customer_id",
    selectedMultipleParam: "customer_ids",
    selectedQueryParams: { account_id: "42", locale: "ja" }
  })

  const defaultParamElement = elementWithAttributes({
    "data-rails-fields-kit--tom-select-selected-url-value": "/customers/selected.json"
  })
  assert.deepEqual(readRenderedSelectedPreloadConfig(defaultParamElement), {
    selectedUrl: "/customers/selected.json",
    selectedParam: "id",
    selectedMultipleParam: "ids",
    selectedQueryParams: {}
  })

  assert.equal(readRenderedSelectedPreloadConfig(elementWithAttributes({})), null)
  assert.equal(readRenderedSelectedPreloadConfig(null), null)

  const invalidQueryParamsElement = elementWithAttributes({
    "data-rails-fields-kit--tom-select-selected-url-value": "/customers/selected.json",
    "data-rails-fields-kit--tom-select-selected-query-params-value": "not-json"
  })
  assert.deepEqual(readRenderedSelectedPreloadConfig(invalidQueryParamsElement)?.selectedQueryParams, {})

  console.log("rails_fields_kit selected preload config contract smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
