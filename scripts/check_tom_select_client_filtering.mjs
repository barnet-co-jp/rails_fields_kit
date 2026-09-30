import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

function controllerWithBaseValues(TomSelectController, overrides = {}) {
  return Object.assign(new TomSelectController(), {
    element: { getAttribute: () => null },
    createValue: false,
    freeTextValue: false,
    hasPersistValue: false,
    placeholderValue: "",
    pluginsValue: [],
    hasMaxOptionsValue: false,
    hasMaxItemsValue: false,
    hasLoadThrottleValue: false,
    hasDelimiterValue: false,
    hasDropdownParentValue: false,
    hasPreloadValue: false,
    hasOpenOnFocusValue: false,
    hasCloseAfterSelectValue: false,
    hasHideSelectedValue: false,
    hasUrlValue: true,
    urlValue: "/items",
    hasSelectedUrlValue: false,
    hasCreateUrlValue: false,
    valueFieldValue: "value",
    labelFieldValue: "text",
    searchFieldValue: "text",
    minLengthValue: 0
  }, overrides)
}

function jsonResponse(body) {
  return { ok: true, status: 200, json: async () => body }
}

async function waitForControllerPromises() {
  await new Promise((resolve) => setTimeout(resolve, 0))
  await new Promise((resolve) => setTimeout(resolve, 0))
}

async function withRemoteEnvironment(body, assertion) {
  const previousWindow = globalThis.window
  const previousFetch = globalThis.fetch
  globalThis.window = { location: { origin: "https://example.test" } }
  globalThis.fetch = async () => jsonResponse(body)

  try {
    await assertion()
  } finally {
    if (previousWindow === undefined) delete globalThis.window
    else globalThis.window = previousWindow
    if (previousFetch === undefined) delete globalThis.fetch
    else globalThis.fetch = previousFetch
  }
}

function prepareLoad(controller, calls) {
  Object.assign(controller, {
    connected: true,
    requestControllers: {},
    requestTokens: {},
    queryParamsValue: {},
    queryParamValue: "q",
    clearErrorSurface: () => {},
    dispatch: (eventName) => calls.push(`dispatch:${eventName}`),
    tomSelect: { clearOptions: () => calls.push("clearOptions") }
  })
}

await withTomSelectControllerSandbox("rails-fields-kit-client-filtering-", async ({ TomSelectController }) => {
  const defaultController = controllerWithBaseValues(TomSelectController)
  assert.equal(
    Object.prototype.hasOwnProperty.call(defaultController.options(), "score"),
    false,
    "remote fields should keep Tom Select's client-side scoring unless client_filtering: false is rendered"
  )

  const serverFilteredController = controllerWithBaseValues(TomSelectController, { clientFilteringValue: false })
  const score = serverFilteredController.options().score
  assert.equal(typeof score, "function", "client_filtering: false should pass a Tom Select score factory")
  assert.equal(score("ぼると")({ text: "LOCAL-0008 — 検証用ボルト" }), 1, "every loaded option should stay visible")

  const staticController = controllerWithBaseValues(TomSelectController, { hasUrlValue: false, clientFilteringValue: false })
  assert.equal(
    Object.prototype.hasOwnProperty.call(staticController.options(), "score"),
    false,
    "client_filtering: false should not change static collections"
  )

  const loads = [
    { overrides: {}, expected: ["dispatch:load", "callback"] },
    { overrides: { clientFilteringValue: false }, expected: ["dispatch:load", "clearOptions", "callback"] }
  ]

  for (const { overrides, expected } of loads) {
    const controller = controllerWithBaseValues(TomSelectController, overrides)
    const calls = []
    prepareLoad(controller, calls)

    await withRemoteEnvironment([{ value: "8", text: "LOCAL-0008 — 検証用ボルト" }], async () => {
      controller.loadOptions("ぼると", () => calls.push("callback"))
      await waitForControllerPromises()
    })

    assert.deepEqual(calls, expected)
  }
})

console.log("rails_fields_kit Tom Select client filtering smoke passed")
