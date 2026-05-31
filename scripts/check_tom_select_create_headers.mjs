import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"
import assert from "node:assert/strict"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-create-headers-"))

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

function withCsrfMeta(content, assertion) {
  const previousDocument = globalThis.document
  globalThis.document = {
    querySelector(selector) {
      assert.equal(selector, "meta[name='csrf-token']")
      return content === undefined ? null : { content }
    }
  }

  try {
    assertion()
  } finally {
    if (previousDocument === undefined) {
      delete globalThis.document
    } else {
      globalThis.document = previousDocument
    }
  }
}

try {
  await writeStubPackage(
    "@hotwired/stimulus",
    "export class Controller {\n  static values = {}\n}\n"
  )
  await writeStubPackage(
    "tom-select",
    "export default class TomSelect {\n  constructor(element, options = {}) {\n    this.element = element\n    this.options = options\n  }\n\n  destroy() {}\n}\n"
  )

  const controllerSource = path.join(repoRoot, "app", "javascript", "rails_fields_kit", "tom_select_controller.js")
  const controllerPath = path.join(sandboxRoot, "tom_select_controller.js")
  await cp(controllerSource, controllerPath)

  const { default: TomSelectController } = await import(pathToFileURL(controllerPath).href)
  const controller = new TomSelectController()

  withCsrfMeta("secure-token", () => {
    assert.deepEqual(controller.createRequestHeaders(), {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": "secure-token"
    })
  })

  withCsrfMeta(undefined, () => {
    assert.deepEqual(controller.createRequestHeaders(), {
      Accept: "application/json",
      "Content-Type": "application/json"
    })
  })

  withCsrfMeta("", () => {
    assert.deepEqual(controller.createRequestHeaders(), {
      Accept: "application/json",
      "Content-Type": "application/json"
    })
  })

  console.log("rails_fields_kit Tom Select create request header smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
