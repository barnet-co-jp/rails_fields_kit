import assert from "node:assert/strict"
import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"

const TOM_SELECT_CONTROLLER = "rails-fields-kit--tom-select"
const TOM_SELECT_VALUE_PREFIX = "data-rails-fields-kit--tom-select"
const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-option-payload-mapping-"))

function elementWithAttributes(attributes) {
  return {
    getAttribute(name) {
      return Object.hasOwn(attributes, name) ? attributes[name] : null
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

  await writeStubPackage(
    "@hotwired/stimulus",
    "export class Controller {\n  static values = {}\n}\n"
  )
  await writeStubPackage(
    "tom-select",
    "export default class TomSelect {\n  constructor(element, options = {}) {\n    this.element = element\n    this.options = options\n  }\n\n  destroy() {}\n}\n"
  )

  const { readRenderedOptionPayloadMapping } = await import(pathToFileURL(path.join(packageRoot, "app", "javascript", "rails_fields_kit", "index.js")).href)

  const explicitMappingElement = elementWithAttributes({
    "data-controller": TOM_SELECT_CONTROLLER,
    [`${TOM_SELECT_VALUE_PREFIX}-value-field-value`]: "uuid",
    [`${TOM_SELECT_VALUE_PREFIX}-label-field-value`]: "display_name",
    [`${TOM_SELECT_VALUE_PREFIX}-search-field-value`]: "display_name, code , description, ",
    [`${TOM_SELECT_VALUE_PREFIX}-option-description-field-value`]: "description",
    [`${TOM_SELECT_VALUE_PREFIX}-option-badge-field-value`]: "status"
  })
  assert.deepEqual(readRenderedOptionPayloadMapping(explicitMappingElement), {
    valueField: "uuid",
    labelField: "display_name",
    searchFields: ["display_name", "code", "description"],
    optionDescriptionField: "description",
    optionBadgeField: "status"
  })

  const defaultMappingElement = elementWithAttributes({
    "data-controller": TOM_SELECT_CONTROLLER
  })
  assert.deepEqual(readRenderedOptionPayloadMapping(defaultMappingElement), {
    valueField: "value",
    labelField: "text",
    searchFields: ["text"],
    optionDescriptionField: null,
    optionBadgeField: null
  })

  const kindOnlyElement = elementWithAttributes({
    [`${TOM_SELECT_VALUE_PREFIX}-kind-value`]: "select"
  })
  assert.deepEqual(readRenderedOptionPayloadMapping(kindOnlyElement), {
    valueField: "value",
    labelField: "text",
    searchFields: ["text"],
    optionDescriptionField: null,
    optionBadgeField: null
  })

  assert.equal(readRenderedOptionPayloadMapping(elementWithAttributes({ class: "unrelated" })), null)
  assert.equal(readRenderedOptionPayloadMapping(null), null)

  console.log("rails_fields_kit option payload mapping contract smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
