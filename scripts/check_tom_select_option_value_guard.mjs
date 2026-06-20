import assert from "node:assert/strict"
import { withTomSelectControllerSandbox } from "./tom_select_smoke_harness.mjs"

function buildController(ControllerClass) {
  const controller = new ControllerClass()
  controller.valueFieldValue = "id"
  controller.hasErrorSurfaceIdValue = false
  controller.tomSelect = {
    addedOptions: [],
    addedItems: [],
    refreshCalls: [],
    addOption(option) {
      this.addedOptions.push(option)
    },
    addItem(value, silent) {
      this.addedItems.push([value, silent])
    },
    refreshOptions(open) {
      this.refreshCalls.push(open)
    }
  }
  controller.dispatchedEvents = []
  controller.clearErrorSurface = () => {}
  controller.dispatch = (name, payload) => controller.dispatchedEvents.push([name, payload])
  return controller
}

await withTomSelectControllerSandbox("rails-fields-kit-option-value-guard-", ({ TomSelectController }) => {
  const selectedController = buildController(TomSelectController)

  selectedController.applySelectedOptions(
    {
      options: [
        { id: "valid-1", label: "Valid one" },
        { label: "Missing id" },
        { id: "", label: "Blank id" },
        { id: null, label: "Null id" },
        { id: "extra", label: "Extra selected preload option" },
        "not-an-option"
      ]
    },
    ["valid-1", "missing"]
  )

  assert.deepEqual(selectedController.tomSelect.addedOptions, [
    { id: "valid-1", label: "Valid one" },
    { id: "extra", label: "Extra selected preload option" }
  ])
  assert.deepEqual(selectedController.tomSelect.addedItems, [
    ["valid-1", true],
    ["extra", true]
  ])
  assert.deepEqual(selectedController.tomSelect.refreshCalls, [false])
  assert.deepEqual(selectedController.dispatchedEvents, [
    [
      "selected-load",
      {
        detail: {
          options: [
            { id: "valid-1", label: "Valid one" },
            { id: "extra", label: "Extra selected preload option" }
          ],
          values: ["valid-1", "missing"]
        }
      }
    ]
  ])

  const customSelectedController = buildController(TomSelectController)
  customSelectedController.valueFieldValue = "slug"
  customSelectedController.applySelectedOptions(
    {
      results: [
        { slug: 0, label: "Zero" },
        { slug: false, label: "False" },
        { slug: "extra", label: "Extra" }
      ]
    },
    ["0", "false"]
  )

  assert.deepEqual(customSelectedController.tomSelect.addedOptions, [
    { slug: 0, label: "Zero" },
    { slug: false, label: "False" },
    { slug: "extra", label: "Extra" }
  ])
  assert.deepEqual(customSelectedController.tomSelect.addedItems, [
    [0, true],
    [false, true],
    ["extra", true]
  ])
  assert.deepEqual(customSelectedController.dispatchedEvents, [
    [
      "selected-load",
      {
        detail: {
          options: [
            { slug: 0, label: "Zero" },
            { slug: false, label: "False" },
            { slug: "extra", label: "Extra" }
          ],
          values: ["0", "false"]
        }
      }
    ]
  ])

  assert.deepEqual(selectedController.normalizeSelectedOptions({ option: { id: "wrapped", label: "Wrapped" } }), [
    { id: "wrapped", label: "Wrapped" }
  ])
  assert.deepEqual(selectedController.normalizeSelectedOptions({ option: null }), [null])
  assert.deepEqual(selectedController.normalizeSelectedOptions({ results: [{ id: "result", label: "Result" }] }), [
    { id: "result", label: "Result" }
  ])

  const createController = buildController(TomSelectController)
  assert.deepEqual(createController.normalizeCreatedOption({ id: "created", label: "Created" }), {
    id: "created",
    label: "Created"
  })
  assert.deepEqual(createController.normalizeCreatedOption({ option: { id: "wrapped-created" } }), {
    id: "wrapped-created"
  })
  assert.equal(createController.normalizeCreatedOption({}), false)
  assert.equal(createController.normalizeCreatedOption({ option: {} }), false)
  assert.equal(createController.normalizeCreatedOption({ option: null }), false)
  assert.equal(createController.normalizeCreatedOption("created"), false)

  createController.valueFieldValue = "slug"
  assert.deepEqual(createController.normalizeCreatedOption({ slug: "custom-created", label: "Custom" }), {
    slug: "custom-created",
    label: "Custom"
  })
  assert.equal(createController.normalizeCreatedOption({ id: "wrong-field" }), false)

  assert.equal(createController.optionHasValue({ slug: 0 }), true)
  assert.equal(createController.optionHasValue({ slug: false }), true)
  assert.equal(createController.optionHasValue({ slug: "" }), false)
})

console.log("rails_fields_kit Tom Select option value guard smoke passed")
