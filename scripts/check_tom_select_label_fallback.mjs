import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
}

function buildController(ControllerClass) {
  const controller = new ControllerClass()
  controller.labelFieldValue = "label"
  controller.valueFieldValue = "id"
  controller.hasOptionDescriptionFieldValue = false
  controller.hasOptionBadgeFieldValue = false
  return controller
}

function labelFromMarkup(markup) {
  const match = markup.match(/<span class="rfk-option-label">([\s\S]*?)<\/span>/)
  assert.ok(match, `expected option label span in ${markup}`)
  return match[1]
}

await withTomSelectControllerSandbox("rails-fields-kit-label-fallback-", ({ TomSelectController }) => {
  const controller = buildController(TomSelectController)
  const renderLabel = (option) => labelFromMarkup(controller.optionTemplate(option, escapeHtml, "option"))

  assert.equal(renderLabel({ id: "value-1", label: "Visible label" }), "Visible label")
  assert.equal(renderLabel({ id: "value-2" }), "value-2")
  assert.equal(renderLabel({ id: "value-3", label: "" }), "value-3")
  assert.equal(renderLabel({ id: "value-4", label: null }), "value-4")
  assert.equal(renderLabel({ id: "value-5", label: 0 }), "0")
  assert.equal(renderLabel({ id: "value-6", label: false }), "false")
  assert.equal(renderLabel({ id: "<value-7>", label: undefined }), "&lt;value-7&gt;")
})

console.log("rails_fields_kit Tom Select label fallback smoke passed")
