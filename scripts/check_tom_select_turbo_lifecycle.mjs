import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

await withTomSelectControllerSandbox("rails-fields-kit-turbo-lifecycle-", ({ TomSelectController }) => {
  const source = TomSelectController.toString()

  assert.doesNotMatch(source, /turbo:load/)

  const controller = new TomSelectController()
  const abortedOperations = []
  let destroyed = 0

  controller.connected = true
  controller.requestControllers = {
    load: { abort: () => { abortedOperations.push("load") } },
    "selected-load": { abort: () => { abortedOperations.push("selected-load") } },
    create: { abort: () => { abortedOperations.push("create") } }
  }
  controller.requestTokens = {
    load: Symbol("load"),
    "selected-load": Symbol("selected-load"),
    create: Symbol("create")
  }
  controller.tomSelect = { destroy: () => { destroyed += 1 } }

  controller.disconnect()

  assert.equal(controller.connected, false)
  assert.deepEqual(abortedOperations.sort(), ["create", "load", "selected-load"])
  assert.deepEqual(controller.requestControllers, {})
  assert.deepEqual(controller.requestTokens, {})
  assert.equal(destroyed, 1)
  assert.equal(controller.tomSelect, null)

  controller.disconnect()

  assert.equal(destroyed, 1)
  assert.equal(controller.tomSelect, null)
})

console.log("rails_fields_kit Tom Select Turbo lifecycle smoke passed")