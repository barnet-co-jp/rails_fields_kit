import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;")
}

function buildController(ControllerClass) {
  const controller = new ControllerClass()
  controller.labelFieldValue = "text"
  controller.valueFieldValue = "value"
  controller.hasOptionDescriptionFieldValue = false
  controller.hasOptionBadgeFieldValue = false
  return controller
}

await withTomSelectControllerSandbox("rails-fields-kit-label-fallback-", ({ TomSelectController }) => {
  const controller = buildController(TomSelectController)

  assert.equal(controller.optionLabel({ text: "Published label", value: "published" }), "Published label")
  assert.equal(controller.optionLabel({ value: "archived" }), "archived")
  assert.equal(controller.optionLabel({ text: null, value: "draft" }), "draft")
  assert.equal(controller.optionLabel({ text: "", value: "empty-label" }), "empty-label")
  assert.equal(controller.optionLabel({ text: 0, value: "zero-value" }), "0")
  assert.equal(controller.optionLabel({ text: false, value: "false-value" }), "false")

  const labelledMarkup = controller.optionTemplate({ text: "<Visible>", value: "remote-1" }, escapeHtml, "option")
  assert.match(labelledMarkup, /<span class="rfk-option-label">&lt;Visible&gt;<\/span>/)

  const fallbackMarkup = controller.optionTemplate({ value: "remote-2" }, escapeHtml, "item")
  assert.match(fallbackMarkup, /<span class="rfk-option-label">remote-2<\/span>/)
})

console.log("rails_fields_kit Tom Select label fallback smoke passed")
