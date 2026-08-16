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
  controller.labelFieldValue = "text"
  controller.valueFieldValue = "value"
  controller.labelFallbackValue = true
  controller.hasOptionDescriptionFieldValue = true
  controller.optionDescriptionFieldValue = "description"
  controller.hasOptionBadgeFieldValue = true
  controller.optionBadgeFieldValue = "badge"
  return controller
}

await withTomSelectControllerSandbox("rails-fields-kit-item-renderer-", ({ TomSelectController }) => {
  const controller = buildController(TomSelectController)
  const renderers = controller.renderers()
  const option = {
    value: "alpha",
    text: "Alpha & Beta",
    description: "Verbose helper text",
    badge: "Current"
  }

  assert.equal(
    renderers.item(option, escapeHtml),
    '<span class="rfk-item-token"><span class="rfk-item-label">Alpha &amp; Beta</span></span>'
  )
  assert.doesNotMatch(renderers.item(option, escapeHtml), /rfk-option-(main|description|badge)/)

  assert.match(renderers.option(option, escapeHtml), /rfk-option-main/)
  assert.match(renderers.option(option, escapeHtml), /rfk-option-description/)
  assert.match(renderers.option(option, escapeHtml), /rfk-option-badge/)
})

console.log("rails_fields_kit Tom Select item renderer smoke passed")
