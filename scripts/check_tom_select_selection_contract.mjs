import assert from "node:assert/strict"
import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"

const TOM_SELECT_CONTROLLER = "rails-fields-kit--tom-select"
const repoRoot = process.cwd()

function element(attributes = {}, tomselect) {
  const field = {
    getAttribute(name) {
      return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
    }
  }

  if (tomselect !== undefined) field.tomselect = tomselect

  return field
}

function tomSelectWithValue(value) {
  return {
    getValue() {
      return value
    }
  }
}

async function writeStubPackage(sandboxRoot, packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\",\n  \"exports\": \"./index.js\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

async function withPackageRootSandbox(assertion) {
  const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-selection-contract-"))

  try {
    await writeStubPackage(
      sandboxRoot,
      "@hotwired/stimulus",
      "export class Controller {\n  static values = {}\n}\n"
    )
    await writeStubPackage(
      sandboxRoot,
      "tom-select",
      "export default class TomSelect {\n  constructor(element, options = {}) {\n    this.element = element\n    this.options = options\n  }\n\n  destroy() {}\n}\n"
    )

    const sourceRoot = path.join(repoRoot, "app", "javascript", "rails_fields_kit")
    const packageRoot = path.join(sandboxRoot, "rails_fields_kit")
    await cp(sourceRoot, packageRoot, { recursive: true })

    const packageRootModule = await import(pathToFileURL(path.join(packageRoot, "index.js")).href)
    await assertion(packageRootModule)
  } finally {
    await rm(sandboxRoot, { recursive: true, force: true })
  }
}

await withPackageRootSandbox(({ tomSelectSelectionContract }) => {
  assert.equal(
    tomSelectSelectionContract(null),
    null,
    "non-elements should not expose a selection contract"
  )

  assert.equal(
    tomSelectSelectionContract(element({ class: "unrelated" }, tomSelectWithValue("customer-1"))),
    null,
    "non Rails Fields Kit Tom Select elements should not expose a selection contract"
  )

  assert.equal(
    tomSelectSelectionContract(element({ "data-controller": TOM_SELECT_CONTROLLER })),
    null,
    "Rails Fields Kit Tom Select elements without an initialized Tom Select value should return null"
  )

  assert.deepEqual(
    tomSelectSelectionContract(element(
      { "data-controller": TOM_SELECT_CONTROLLER },
      tomSelectWithValue("customer-1")
    )),
    { values: ["customer-1"] },
    "single-value Tom Select selections should expose a values array"
  )

  assert.deepEqual(
    tomSelectSelectionContract(element(
      { "data-controller": TOM_SELECT_CONTROLLER },
      tomSelectWithValue(["tag-1", "tag-2"])
    )),
    { values: ["tag-1", "tag-2"] },
    "multiple Tom Select selections should preserve the values array"
  )

  assert.deepEqual(
    tomSelectSelectionContract(element(
      { "data-controller": TOM_SELECT_CONTROLLER },
      tomSelectWithValue("")
    )),
    { values: [""] },
    "single-value Tom Select clear state should keep the scalar empty string shape visible"
  )

  assert.deepEqual(
    tomSelectSelectionContract(element(
      { "data-controller": TOM_SELECT_CONTROLLER },
      tomSelectWithValue([])
    )),
    { values: [] },
    "multiple Tom Select clear state should keep the empty array shape visible"
  )
})

console.log("rails_fields_kit Tom Select selection contract smoke passed")
