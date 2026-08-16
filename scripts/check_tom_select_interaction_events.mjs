import assert from "node:assert/strict"
import { readFile } from "node:fs/promises"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

function jsonResponse(body, { ok = true, status = 200 } = {}) {
  return {
    ok,
    status,
    json: async () => body
  }
}

function withWindow(assertion) {
  const previousWindow = globalThis.window
  globalThis.window = { location: { origin: "https://example.test" } }

  try {
    return assertion()
  } finally {
    if (previousWindow === undefined) {
      delete globalThis.window
    } else {
      globalThis.window = previousWindow
    }
  }
}

async function withFetch(handler, assertion) {
  const previousFetch = globalThis.fetch
  globalThis.fetch = handler

  try {
    await assertion()
  } finally {
    if (previousFetch === undefined) {
      delete globalThis.fetch
    } else {
      globalThis.fetch = previousFetch
    }
  }
}

async function waitForControllerPromises() {
  await new Promise((resolve) => setTimeout(resolve, 0))
}

function buildController(ControllerClass) {
  const controller = new ControllerClass()
  const dispatched = []

  controller.connected = true
  controller.requestControllers = {}
  controller.requestTokens = {}
  controller.queryParamsValue = {}
  controller.selectedQueryParamsValue = {}
  controller.createParamsValue = {}
  controller.queryParamValue = "q"
  controller.selectedParamValue = "id"
  controller.selectedMultipleParamValue = "ids"
  controller.createParamValue = "text"
  controller.valueFieldValue = "value"
  controller.labelFieldValue = "text"
  controller.hasErrorSurfaceIdValue = false
  controller.clearErrorSurface = () => {}
  controller.dispatch = (eventName, payload) => {
    dispatched.push({ eventName, detail: payload.detail })
  }

  return { controller, dispatched }
}

const eventsDoc = await readFile("doc/events.md", "utf8")
const eventDetailSignals = [
  "Detail: `{ query, options }`",
  "Detail: `{ values, options }`",
  "Detail: `{ input, option }`",
  "Detail: `{ operation, query, error, response, payload, status, surface }`",
  "Detail: `{ operation, values, error, response, payload, status, surface }`",
  "Detail: `{ operation, input, error, response, payload, status, surface }`",
  "Detail: `{ value, values, option, options }`",
  "Detail: `{ value, item, values, option, options }`"
]

eventDetailSignals.forEach((signal) => assert.match(eventsDoc, new RegExp(signal.replace(/[{}]/g, "\\$&"))))

await withTomSelectControllerSandbox("rails-fields-kit-interaction-events-", async ({ TomSelectController }) => {
  const { controller, dispatched } = buildController(TomSelectController)
  const alphaOption = { value: "alpha", text: "Alpha", price_cents: 1200 }
  const betaOption = { value: "beta", text: "Beta", unit: "box" }
  const handlers = {}
  let selectedValue = ""

  controller.tomSelect = {
    options: {
      alpha: alphaOption,
      beta: betaOption
    },
    getValue: () => selectedValue,
    on: (eventName, handler) => {
      handlers[eventName] = handler
    }
  }

  controller.bindTomSelectEvents()

  selectedValue = ""
  handlers.clear()
  assert.deepEqual(dispatched.pop(), {
    eventName: "clear",
    detail: { values: [""], options: [null] }
  })

  selectedValue = []
  handlers.clear()
  assert.deepEqual(dispatched.pop(), {
    eventName: "clear",
    detail: { values: [], options: [] }
  })

  selectedValue = "alpha"
  handlers.change("alpha")
  assert.deepEqual(dispatched.pop(), {
    eventName: "change",
    detail: { value: "alpha", values: ["alpha"], option: alphaOption, options: [alphaOption] }
  })

  selectedValue = ["alpha", "beta"]
  handlers.change("alpha")
  assert.deepEqual(dispatched.pop(), {
    eventName: "change",
    detail: { value: "alpha", values: ["alpha", "beta"], option: alphaOption, options: [alphaOption, betaOption] }
  })

  selectedValue = ["alpha", "beta"]
  const betaItem = { dataset: { value: "beta" } }
  handlers.item_add("beta", betaItem)
  assert.deepEqual(dispatched.pop(), {
    eventName: "item-add",
    detail: { value: "beta", item: betaItem, values: ["alpha", "beta"], option: betaOption, options: [alphaOption, betaOption] }
  })

  selectedValue = "custom"
  handlers.change("custom")
  assert.deepEqual(dispatched.pop(), {
    eventName: "change",
    detail: { value: "custom", values: ["custom"], option: null, options: [null] }
  })

  const remoteOptions = [{ value: "tokyo", text: "Tokyo" }]
  controller.urlValue = "/cities"
  controller.queryParamsValue = { scope: "active" }
  const loadCallbacks = []
  let loadRequestUrl = null

  await withFetch(
    async (url) => {
      loadRequestUrl = url
      return jsonResponse({ options: remoteOptions })
    },
    async () => withWindow(async () => {
      controller.loadOptions("to", (options) => loadCallbacks.push(options))
      await waitForControllerPromises()
    })
  )

  const parsedLoadUrl = new URL(loadRequestUrl)
  assert.equal(parsedLoadUrl.pathname, "/cities")
  assert.equal(parsedLoadUrl.searchParams.get("scope"), "active")
  assert.equal(parsedLoadUrl.searchParams.get("q"), "to")
  assert.deepEqual(loadCallbacks, [remoteOptions])
  assert.deepEqual(dispatched.pop(), {
    eventName: "load",
    detail: { query: "to", options: remoteOptions }
  })

  const selectedOptions = [{ value: "7", text: "Seven" }]
  const addedOptions = []
  const addedItems = []
  let refreshed = false
  controller.tomSelect = {
    addOption: (option) => addedOptions.push(option),
    addItem: (value, silent) => addedItems.push({ value, silent }),
    refreshOptions: (open) => { refreshed = open }
  }

  controller.applySelectedOptions(selectedOptions, ["7"])
  assert.deepEqual(addedOptions, selectedOptions)
  assert.deepEqual(addedItems, [{ value: "7", silent: true }])
  assert.equal(refreshed, false)
  assert.deepEqual(dispatched.pop(), {
    eventName: "selected-load",
    detail: { options: selectedOptions, values: ["7"] }
  })

  addedOptions.length = 0
  addedItems.length = 0
  const responseOrderedOptions = [
    { value: "1", text: "One" },
    { value: "2", text: "Two" }
  ]
  controller.applySelectedOptions(responseOrderedOptions, ["2", "1"])
  assert.deepEqual(addedOptions, responseOrderedOptions)
  assert.deepEqual(addedItems, [
    { value: "1", silent: true },
    { value: "2", silent: true }
  ])
  assert.deepEqual(dispatched.pop(), {
    eventName: "selected-load",
    detail: { options: responseOrderedOptions, values: ["2", "1"] }
  })

  const createdOption = { value: "kyoto", text: "Kyoto" }
  controller.createUrlValue = "/cities"
  controller.createParamsValue = { source: "inline" }
  controller.createParamValue = "name"
  controller.createRequestHeaders = () => ({ Accept: "application/json", "Content-Type": "application/json" })
  const createCallbacks = []
  let createRequestBody = null

  await withFetch(
    async (_url, options) => {
      createRequestBody = JSON.parse(options.body)
      return jsonResponse({ option: createdOption })
    },
    async () => {
      controller.createOption("Kyoto", (option) => createCallbacks.push(option))
      await waitForControllerPromises()
    }
  )

  assert.deepEqual(createRequestBody, { source: "inline", name: "Kyoto" })
  assert.deepEqual(createCallbacks, [createdOption])
  assert.deepEqual(dispatched.pop(), {
    eventName: "create",
    detail: { input: "Kyoto", option: createdOption }
  })

  const error = new Error("Request failed")
  error.response = { status: 503 }
  error.payload = { error: "Unavailable" }

  controller.dispatchRequestError("load-error", "load", { query: "ky" }, error)
  const failure = dispatched.pop()
  assert.equal(failure.eventName, "load-error")
  assert.equal(failure.detail.operation, "load")
  assert.equal(failure.detail.query, "ky")
  assert.equal(failure.detail.error, error)
  assert.equal(failure.detail.response, error.response)
  assert.deepEqual(failure.detail.payload, { error: "Unavailable" })
  assert.equal(failure.detail.status, 503)
  assert.equal(failure.detail.surface, null)
})

console.log("rails_fields_kit Tom Select interaction and request event smoke passed")
