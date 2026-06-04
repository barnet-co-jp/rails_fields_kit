import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

await withTomSelectControllerSandbox("rails-fields-kit-query-params-", ({ TomSelectController }) => {
  const controller = new TomSelectController()

  const searchUrl = new URL("https://example.test/customers?scope=initial&facet=existing")
  controller.appendParams(searchUrl, {
    account_id: 42,
    scope: "active",
    facet: ["vip", "recent"],
    mixed: ["kept", null, undefined, ""],
    empty: null,
    missing: undefined
  })

  assert.equal(searchUrl.searchParams.get("account_id"), "42")
  assert.equal(searchUrl.searchParams.get("scope"), "active")
  assert.deepEqual(searchUrl.searchParams.getAll("facet"), ["existing", "vip", "recent"])
  assert.deepEqual(searchUrl.searchParams.getAll("mixed"), ["kept", "null", "undefined", ""])
  assert.equal(searchUrl.searchParams.has("empty"), false)
  assert.equal(searchUrl.searchParams.has("missing"), false)

  const selectedUrl = new URL("https://example.test/customers/selected")
  controller.appendParams(selectedUrl, {
    tenant: "primary",
    "role_ids[]": [1, 2]
  })

  assert.equal(selectedUrl.searchParams.get("tenant"), "primary")
  assert.deepEqual(selectedUrl.searchParams.getAll("role_ids[]"), ["1", "2"])
})

console.log("rails_fields_kit Tom Select fixed query params smoke passed")
