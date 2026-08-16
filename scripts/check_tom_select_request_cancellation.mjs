import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

function deferred() {
  let resolve
  let reject
  const promise = new Promise((promiseResolve, promiseReject) => {
    resolve = promiseResolve
    reject = promiseReject
  })

  return { promise, resolve, reject }
}

function jsonResponse(body, { ok = true, status = 200 } = {}) {
  return {
    ok,
    status,
    json: async () => body
  }
}

function abortError() {
  const error = new Error("The operation was aborted")
  error.name = "AbortError"
  return error
}

async function waitForControllerPromises() {
  await new Promise((resolve) => setTimeout(resolve, 0))
  await new Promise((resolve) => setTimeout(resolve, 0))
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

function deferredFetchRecorder(requests) {
  return (url, options = {}) => {
    const request = { url, options, deferred: deferred() }
    requests.push(request)
    return request.deferred.promise
  }
}

await withTomSelectControllerSandbox("rails-fields-kit-request-cancellation-", async ({ TomSelectController }) => {
  await withWindow(async () => {
    const { controller, dispatched } = buildController(TomSelectController)
    const callbacks = []
    const requests = []

    controller.urlValue = "/cities"

    await withFetch(deferredFetchRecorder(requests), async () => {
      controller.loadOptions("alpha", (options) => callbacks.push({ query: "alpha", options }))
      controller.loadOptions("beta", (options) => callbacks.push({ query: "beta", options }))

      assert.equal(requests.length, 2)
      assert.equal(requests[0].options.signal.aborted, true)
      assert.equal(requests[1].options.signal.aborted, false)

      requests[1].deferred.resolve(jsonResponse([{ value: "beta", text: "Beta" }]))
      await waitForControllerPromises()

      requests[0].deferred.resolve(jsonResponse([{ value: "alpha", text: "Alpha" }]))
      await waitForControllerPromises()
    })

    assert.deepEqual(callbacks, [{ query: "beta", options: [{ value: "beta", text: "Beta" }] }])
    assert.deepEqual(dispatched, [{ eventName: "load", detail: { query: "beta", options: [{ value: "beta", text: "Beta" }] } }])
  })

  await withWindow(async () => {
    const { controller, dispatched } = buildController(TomSelectController)
    const callbacks = []
    const requests = []

    controller.urlValue = "/cities"

    await withFetch(deferredFetchRecorder(requests), async () => {
      controller.loadOptions("stale", (options) => callbacks.push({ query: "stale", options }))
      controller.loadOptions("current", (options) => callbacks.push({ query: "current", options }))

      requests[0].deferred.reject(new Error("stale request failed"))
      requests[1].deferred.resolve(jsonResponse({ options: [{ value: "current", text: "Current" }] }))
      await waitForControllerPromises()
    })

    assert.deepEqual(callbacks, [{ query: "current", options: [{ value: "current", text: "Current" }] }])
    assert.deepEqual(dispatched, [{ eventName: "load", detail: { query: "current", options: [{ value: "current", text: "Current" }] } }])
  })

  await withWindow(async () => {
    const { controller, dispatched } = buildController(TomSelectController)
    const callbacks = []

    controller.urlValue = "/cities"

    await withFetch(async () => Promise.reject(abortError()), async () => {
      controller.loadOptions("aborted", (options) => callbacks.push(options))
      await waitForControllerPromises()
    })

    assert.deepEqual(callbacks, [])
    assert.deepEqual(dispatched, [])
  })

  await withWindow(async () => {
    const { controller, dispatched } = buildController(TomSelectController)
    const requests = []
    const addedOptions = []
    const addedItems = []
    let refreshed = null
    let destroyed = false

    controller.hasSelectedUrlValue = true
    controller.selectedUrlValue = "/selected"
    controller.tomSelect = {
      options: {},
      getValue: () => ["7"],
      addOption: (option) => addedOptions.push(option),
      addItem: (value, silent) => addedItems.push({ value, silent }),
      refreshOptions: (open) => { refreshed = open },
      destroy: () => { destroyed = true }
    }

    await withFetch(deferredFetchRecorder(requests), async () => {
      controller.loadSelectedOptions()
      assert.equal(requests.length, 1)

      controller.disconnect()
      assert.equal(requests[0].options.signal.aborted, true)
      assert.equal(destroyed, true)

      requests[0].deferred.resolve(jsonResponse({ options: [{ value: "7", text: "Seven" }] }))
      await waitForControllerPromises()
    })

    assert.deepEqual(addedOptions, [])
    assert.deepEqual(addedItems, [])
    assert.equal(refreshed, null)
    assert.deepEqual(dispatched, [])
  })

  await withWindow(async () => {
    const { controller, dispatched } = buildController(TomSelectController)
    const callbacks = []

    controller.urlValue = "/cities"

    await withFetch(async () => jsonResponse({ error: "Unavailable" }, { ok: false, status: 503 }), async () => {
      controller.loadOptions("latest-failure", (options) => callbacks.push(options))
      await waitForControllerPromises()
    })

    assert.deepEqual(callbacks, [undefined])
    assert.equal(dispatched.length, 1)
    assert.equal(dispatched[0].eventName, "load-error")
    assert.equal(dispatched[0].detail.operation, "load")
    assert.equal(dispatched[0].detail.query, "latest-failure")
    assert.equal(dispatched[0].detail.status, 503)
    assert.deepEqual(dispatched[0].detail.payload, { error: "Unavailable" })
  })
})

console.log("rails_fields_kit Tom Select request cancellation smoke passed")
