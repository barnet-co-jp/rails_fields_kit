import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"
import assert from "node:assert/strict"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-error-surface-"))

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

function withDocument(surface, assertion) {
  const previousDocument = globalThis.document
  globalThis.document = {
    getElementById(id) {
      assert.equal(id, "product_category_error_surface")
      return surface
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

function buildController(ControllerClass) {
  const controller = new ControllerClass()
  controller.hasErrorSurfaceIdValue = true
  controller.errorSurfaceIdValue = "product_category_error_surface"
  return controller
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
  const controller = buildController(TomSelectController)
  const surface = {
    hidden: true,
    dataset: { rfkErrorStatus: "409" },
    textContent: "Previous error"
  }

  withDocument(surface, () => {
    controller.markErrorSurface(surface, { operation: "load", status: 422 })
    assert.equal(surface.hidden, false)
    assert.equal(surface.dataset.rfkErrorState, "error")
    assert.equal(surface.dataset.rfkErrorOperation, "load")
    assert.equal(surface.dataset.rfkErrorStatus, "422")

    controller.markErrorSurface(surface, { operation: "selected-load", status: null })
    assert.equal(surface.dataset.rfkErrorState, "error")
    assert.equal(surface.dataset.rfkErrorOperation, "selected-load")
    assert.equal(surface.dataset.rfkErrorStatus, undefined)

    surface.textContent = "Visible failure"
    controller.clearErrorSurface()
    assert.equal(surface.hidden, true)
    assert.equal(surface.dataset.rfkErrorState, undefined)
    assert.equal(surface.dataset.rfkErrorOperation, undefined)
    assert.equal(surface.dataset.rfkErrorStatus, undefined)
    assert.equal(surface.textContent, "")
  })

  console.log("rails_fields_kit Tom Select error surface smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
