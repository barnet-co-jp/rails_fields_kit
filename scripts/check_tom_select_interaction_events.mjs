import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

await withTomSelectControllerSandbox("rails-fields-kit-interaction-events-", ({ TomSelectController }) => {
  const controller = new TomSelectController()
  const handlers = {}
  const dispatched = []
  let selectedValue = ""

  controller.tomSelect = {
    getValue: () => selectedValue,
    on: (eventName, handler) => {
      handlers[eventName] = handler
    }
  }
  controller.clearErrorSurface = () => {}
  controller.dispatch = (eventName, payload) => {
    dispatched.push({ eventName, detail: payload.detail })
  }

  controller.bindTomSelectEvents()

  selectedValue = ""
  handlers.clear()
  assert.deepEqual(dispatched.pop(), {
    eventName: "clear",
    detail: { values: [""] }
  })

  selectedValue = []
  handlers.clear()
  assert.deepEqual(dispatched.pop(), {
    eventName: "clear",
    detail: { values: [] }
  })

  selectedValue = ["alpha", "beta"]
  handlers.change("alpha")
  assert.deepEqual(dispatched.pop(), {
    eventName: "change",
    detail: { value: "alpha", values: ["alpha", "beta"] }
  })
})

console.log("rails_fields_kit Tom Select interaction event smoke passed")
