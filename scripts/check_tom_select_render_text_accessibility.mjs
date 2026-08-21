import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
}

function withEscapeDocument(assertion) {
  const previousDocument = globalThis.document
  globalThis.document = {
    createElement() {
      return {
        text: "",
        set textContent(value) {
          this.text = String(value)
        },
        get innerHTML() {
          return escapeHtml(this.text)
        }
      }
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

function buildController(ControllerClass, values = {}) {
  const controller = new ControllerClass()
  controller.noResultsTextValue = values.noResultsText
  controller.loadingTextValue = values.loadingText
  controller.createTextValue = values.createText
  return controller
}

await withTomSelectControllerSandbox("rails-fields-kit-render-text-a11y-", ({ TomSelectController }) => {
  withEscapeDocument(() => {
    const controller = buildController(TomSelectController, {
      noResultsText: "No matching accounts",
      loadingText: "Searching accounts",
      createText: "Create account"
    })
    const renderers = controller.renderers()

    const noResults = renderers.no_results()
    assert.match(noResults, /class="no-results"/)
    assert.match(noResults, /role="status"/)
    assert.match(noResults, /aria-live="polite"/)
    assert.match(noResults, /aria-atomic="true"/)
    assert.match(noResults, />No matching accounts<\/div>$/)

    const loading = renderers.loading()
    assert.match(loading, /class="loading"/)
    assert.match(loading, /role="status"/)
    assert.match(loading, /aria-live="polite"/)
    assert.match(loading, /aria-atomic="true"/)
    assert.match(loading, />Searching accounts<\/div>$/)

    const create = renderers.option_create({ input: "Acme <East>" }, escapeHtml)
    assert.equal(create, '<div class="create">Create account <strong>Acme &lt;East&gt;</strong></div>')
    assert.doesNotMatch(create, /role="status"|aria-live|aria-atomic/)
  })
})

console.log("rails_fields_kit Tom Select render text accessibility smoke passed")
