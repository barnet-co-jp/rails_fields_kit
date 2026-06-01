import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

await withTomSelectControllerSandbox("rails-fields-kit-turbo-lifecycle-", ({ TomSelectController }) => {
  const source = TomSelectController.toString()

  assert.match(source, /disconnect\(\)\s*{[\s\S]*this\.connected = false/)
  assert.match(source, /disconnect\(\)\s*{[\s\S]*this\.abortAllRequests\(\)/)
  assert.match(source, /disconnect\(\)\s*{[\s\S]*this\.tomSelect\.destroy\(\)/)
  assert.match(source, /disconnect\(\)\s*{[\s\S]*this\.tomSelect = null/)
  assert.doesNotMatch(source, /turbo:load/)

  const controller = new TomSelectController()
  let aborted = 0
  let destroyed = 0
  controller.connected = true
  controller.abortAllRequests = () => { aborted += 1 }
  controller.tomSelect = { destroy: () => { destroyed += 1 } }

  controller.disconnect()

  assert.equal(controller.connected, false)
  assert.equal(aborted, 1)
  assert.equal(destroyed, 1)
  assert.equal(controller.tomSelect, null)
})

console.log("rails_fields_kit Tom Select Turbo lifecycle smoke passed")
