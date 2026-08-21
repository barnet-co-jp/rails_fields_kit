import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

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

await withTomSelectControllerSandbox("rails-fields-kit-error-surface-", ({ TomSelectController }) => {
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
})

console.log("rails_fields_kit Tom Select error surface smoke passed")
