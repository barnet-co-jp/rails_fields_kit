import assert from "node:assert/strict"
import { cp, mkdir, mkdtemp, rm, writeFile } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-field-kind-contract-"))

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

class FakeElement {
  constructor(attributes = {}) {
    this.attributes = attributes
  }

  getAttribute(name) {
    return Object.hasOwn(this.attributes, name) ? this.attributes[name] : null
  }

  hasAttribute(name) {
    return Object.hasOwn(this.attributes, name)
  }
}

try {
  const packageSourceRoot = path.join(sandboxRoot, "app", "javascript", "rails_fields_kit")

  await mkdir(packageSourceRoot, { recursive: true })
  await cp(
    path.join(repoRoot, "app", "javascript", "rails_fields_kit"),
    packageSourceRoot,
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

  const { tomSelectFieldKindContract } = await import(pathToFileURL(path.join(packageSourceRoot, "index.js")).href)

  assert.deepEqual(
    tomSelectFieldKindContract(new FakeElement({
      "data-controller": "other rails-fields-kit--tom-select",
      "data-rails-fields-kit--tom-select-kind-value": "grouped_select"
    })),
    {
      controller: "rails-fields-kit--tom-select",
      kind: "grouped_select"
    },
    "field kind contract reader should expose the rendered helper kind for Rails Fields Kit Tom Select fields"
  )

  assert.equal(
    tomSelectFieldKindContract(new FakeElement({
      "data-controller": "rails-fields-kit--tom-select"
    })),
    null,
    "field kind contract reader should return null when the rendered kind value is absent"
  )

  assert.equal(
    tomSelectFieldKindContract(new FakeElement({
      "data-controller": "other",
      "data-rails-fields-kit--tom-select-kind-value": "select"
    })),
    null,
    "field kind contract reader should ignore non-Rails Fields Kit Tom Select elements"
  )

  assert.equal(
    tomSelectFieldKindContract(null),
    null,
    "field kind contract reader should ignore missing elements"
  )

  console.log("rails_fields_kit Tom Select field kind contract smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
