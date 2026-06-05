import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

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

await withTomSelectControllerSandbox("rails-fields-kit-create-headers-", ({ TomSelectController }) => {
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

  const wrappedOption = { value: "tokyo", text: "Tokyo" }
  assert.deepEqual(
    controller.normalizeCreatedOption({ option: wrappedOption }),
    wrappedOption
  )

  const rawOption = { value: "kyoto", text: "Kyoto", region: "kansai" }
  assert.deepEqual(controller.normalizeCreatedOption(rawOption), rawOption)

  assert.equal(controller.normalizeCreatedOption(null), false)
  assert.equal(controller.normalizeCreatedOption(undefined), false)
})

console.log("rails_fields_kit Tom Select create request header and response normalization smoke passed")
