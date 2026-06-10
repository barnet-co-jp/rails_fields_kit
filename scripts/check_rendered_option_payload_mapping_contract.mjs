import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"
import assert from "node:assert/strict"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-option-payload-"))

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

function fakeElement(attributes = {}) {
  return {
    getAttribute(name) {
      return Object.hasOwn(attributes, name) ? attributes[name] : null
    },
    hasAttribute(name) {
      return Object.hasOwn(attributes, name)
    }
  }
}

try {
  const packageRoot = path.join(sandboxRoot, "node_modules", "rails_fields_kit")

  await mkdir(packageRoot, { recursive: true })
  await cp(path.join(repoRoot, "package.json"), path.join(packageRoot, "package.json"))
  await cp(
    path.join(repoRoot, "app", "javascript", "rails_fields_kit"),
    path.join(packageRoot, "app", "javascript", "rails_fields_kit"),
    { recursive: true }
  )

  await writeStubPackage(
    "@hotwired/stimulus",
    "export class Controller {\n  static values = {}\n}\n"
  )
  await writeStubPackage(
    "tom-select",
    "export default class TomSelect {\n  constructor(element, options = {}) {\n    this.element = element\n    this.options = options\n  }\n\n  destroy() {}\n}\n"
  )

  const { readRenderedOptionPayloadMapping } = await import(pathToFileURL(path.join(packageRoot, "app", "javascript", "rails_fields_kit", "index.js")).href)

  const explicitMapping = readRenderedOptionPayloadMapping(fakeElement({
    "data-controller": "rails-fields-kit--tom-select",
    "data-rails-fields-kit--tom-select-kind-value": "combobox",
    "data-rails-fields-kit--tom-select-value-field-value": "id",
    "data-rails-fields-kit--tom-select-label-field-value": "name",
    "data-rails-fields-kit--tom-select-search-field-value": "name, email , status",
    "data-rails-fields-kit--tom-select-option-description-field-value": "email",
    "data-rails-fields-kit--tom-select-option-badge-field-value": "role"
  }))

  assert.deepEqual(explicitMapping, {
    valueField: "id",
    labelField: "name",
    searchFields: ["name", "email", "status"],
    optionDescriptionField: "email",
    optionBadgeField: "role"
  })

  const defaultMapping = readRenderedOptionPayloadMapping(fakeElement({
    "data-controller": "rails-fields-kit--tom-select",
    "data-rails-fields-kit--tom-select-kind-value": "select"
  }))

  assert.deepEqual(defaultMapping, {
    valueField: "value",
    labelField: "text",
    searchFields: ["text"],
    optionDescriptionField: null,
    optionBadgeField: null
  })

  const emptyRichFields = readRenderedOptionPayloadMapping(fakeElement({
    "data-controller": "rails-fields-kit--tom-select",
    "data-rails-fields-kit--tom-select-kind-value": "autocomplete",
    "data-rails-fields-kit--tom-select-option-description-field-value": "",
    "data-rails-fields-kit--tom-select-option-badge-field-value": ""
  }))

  assert.equal(emptyRichFields.optionDescriptionField, null)
  assert.equal(emptyRichFields.optionBadgeField, null)

  assert.equal(readRenderedOptionPayloadMapping(fakeElement({})), null)
  assert.equal(readRenderedOptionPayloadMapping(null), null)

  console.log("rails_fields_kit rendered option payload mapping contract smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
