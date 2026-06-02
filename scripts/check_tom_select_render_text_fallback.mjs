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

await withTomSelectControllerSandbox("rails-fields-kit-render-text-fallback-", ({ TomSelectController }) => {
  withEscapeDocument(() => {
    const fallbackController = buildController(TomSelectController)
    const fallbackRenderers = fallbackController.renderers()

    assert.equal(
      fallbackRenderers.no_results(),
      '<div class="no-results" role="status" aria-live="polite" aria-atomic="true">No results found</div>'
    )
    assert.equal(
      fallbackRenderers.loading(),
      '<div class="loading" role="status" aria-live="polite" aria-atomic="true">Loading...</div>'
    )
    assert.equal(
      fallbackRenderers.option_create({ input: "Acme" }, escapeHtml),
      '<div class="create">Add <strong>Acme</strong></div>'
    )

    const blankController = buildController(TomSelectController, {
      noResultsText: "",
      loadingText: "",
      createText: ""
    })
    const blankRenderers = blankController.renderers()

    assert.match(blankRenderers.no_results(), />No results found<\/div>$/)
    assert.match(blankRenderers.loading(), />Loading\.\.\.<\/div>$/)
    assert.equal(blankRenderers.option_create({ input: "Beta" }, escapeHtml), '<div class="create">Add <strong>Beta</strong></div>')

    const explicitController = buildController(TomSelectController, {
      noResultsText: "Nothing <here>",
      loadingText: "Fetching & waiting",
      createText: "Create <tag>"
    })
    const explicitRenderers = explicitController.renderers()

    assert.match(explicitRenderers.no_results(), />Nothing &lt;here&gt;<\/div>$/)
    assert.match(explicitRenderers.loading(), />Fetching &amp; waiting<\/div>$/)
    assert.equal(
      explicitRenderers.option_create({ input: "<script>" }, escapeHtml),
      '<div class="create">Create &lt;tag&gt; <strong>&lt;script&gt;</strong></div>'
    )
  })
})

console.log("rails_fields_kit Tom Select render text fallback smoke passed")
