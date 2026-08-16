import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

async function withCsrfMeta(content, assertion) {
  const previousDocument = globalThis.document
  globalThis.document = {
    querySelector(selector) {
      assert.equal(selector, "meta[name='csrf-token']")
      return content === undefined ? null : { content }
    }
  }

  try {
    await assertion()
  } finally {
    if (previousDocument === undefined) {
      delete globalThis.document
    } else {
      globalThis.document = previousDocument
    }
  }
}

async function withFetchStub(handler, assertion) {
  const previousFetch = globalThis.fetch
  const requests = []

  globalThis.fetch = async (url, options) => {
    requests.push({ url, options })
    return handler(url, options)
  }

  try {
    await assertion(requests)
  } finally {
    if (previousFetch === undefined) {
      delete globalThis.fetch
    } else {
      globalThis.fetch = previousFetch
    }
  }
}

function buildCreateController(TomSelectController) {
  const events = []
  const controller = new TomSelectController()

  controller.connected = true
  controller.requestControllers = {}
  controller.requestTokens = {}
  controller.createUrlValue = "/customers"
  controller.createParamValue = "name"
  controller.createParamsValue = { account_id: 123, external_id: "lead-123" }
  controller.dispatch = (eventName, payload) => events.push({ eventName, payload })

  return { controller, events }
}

await withTomSelectControllerSandbox("rails-fields-kit-create-headers-", async ({ TomSelectController }) => {
  const controller = new TomSelectController()

  await withCsrfMeta("secure-token", async () => {
    assert.deepEqual(controller.createRequestHeaders(), {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": "secure-token"
    })
  })

  await withCsrfMeta(undefined, async () => {
    assert.deepEqual(controller.createRequestHeaders(), {
      Accept: "application/json",
      "Content-Type": "application/json"
    })
  })

  await withCsrfMeta("", async () => {
    assert.deepEqual(controller.createRequestHeaders(), {
      Accept: "application/json",
      "Content-Type": "application/json"
    })
  })

  await withCsrfMeta("secure-token", async () => {
    await withFetchStub(
      async () => ({
        ok: true,
        json: async () => ({ option: { value: "new-customer", text: "New Customer" } })
      }),
      async (requests) => {
        const { controller: createController, events } = buildCreateController(TomSelectController)
        const createdOption = await new Promise((resolve) => createController.createOption("New Customer", resolve))

        assert.equal(requests.length, 1)
        assert.equal(requests[0].url, "/customers")
        assert.equal(requests[0].options.method, "POST")
        assert.deepEqual(requests[0].options.headers, {
          Accept: "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": "secure-token"
        })
        assert.deepEqual(JSON.parse(requests[0].options.body), {
          account_id: 123,
          external_id: "lead-123",
          name: "New Customer"
        })
        assert.deepEqual(createdOption, { value: "new-customer", text: "New Customer" })
        assert.deepEqual(events.map((event) => event.eventName), ["create"])
        assert.deepEqual(events[0].payload.detail, {
          input: "New Customer",
          option: { value: "new-customer", text: "New Customer" }
        })
      }
    )
  })

  await withCsrfMeta(undefined, async () => {
    await withFetchStub(
      async () => ({
        ok: false,
        status: 422,
        json: async () => ({ errors: ["name is invalid"] })
      }),
      async (requests) => {
        const { controller: createController, events } = buildCreateController(TomSelectController)
        const createdOption = await new Promise((resolve) => createController.createOption("Invalid Customer", resolve))

        assert.equal(createdOption, false)
        assert.equal(requests.length, 1)
        assert.equal(requests[0].options.method, "POST")
        assert.deepEqual(JSON.parse(requests[0].options.body), {
          account_id: 123,
          external_id: "lead-123",
          name: "Invalid Customer"
        })
        assert.deepEqual(events.map((event) => event.eventName), ["create-error"])
        assert.equal(events[0].payload.detail.operation, "create")
        assert.equal(events[0].payload.detail.input, "Invalid Customer")
        assert.equal(events[0].payload.detail.status, 422)
        assert.deepEqual(events[0].payload.detail.payload, { errors: ["name is invalid"] })
      }
    )
  })

  await withCsrfMeta(undefined, async () => {
    const invalidPayloads = [
      {},
      null,
      { option: {} },
      { option: null },
      "not-an-option"
    ]

    for (const payload of invalidPayloads) {
      await withFetchStub(
        async () => ({
          ok: true,
          status: 200,
          json: async () => payload
        }),
        async () => {
          const { controller: createController, events } = buildCreateController(TomSelectController)
          const createdOption = await new Promise((resolve) => createController.createOption("Invalid success", resolve))

          assert.equal(createdOption, false)
          assert.deepEqual(events.map((event) => event.eventName), ["create-error"])
          assert.equal(events[0].payload.detail.operation, "create")
          assert.equal(events[0].payload.detail.input, "Invalid success")
          assert.equal(events[0].payload.detail.status, 200)
          assert.deepEqual(events[0].payload.detail.payload, payload)
          assert.match(events[0].payload.detail.error.message, /usable option object/)
        }
      )
    }
  })

  const customValueController = buildCreateController(TomSelectController).controller
  customValueController.valueFieldValue = "slug"
  assert.deepEqual(
    await customValueController.handleCreateResponse({ ok: true, status: 200, json: async () => ({ slug: 0 }) }),
    { slug: 0 }
  )
  assert.deepEqual(
    await customValueController.handleCreateResponse({ ok: true, status: 200, json: async () => ({ slug: false }) }),
    { slug: false }
  )

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

console.log("rails_fields_kit Tom Select create request contract smoke passed")
