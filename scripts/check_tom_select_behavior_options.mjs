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
    hasClassNamesValue: false,
    hasMaxOptionsValue: false,
    hasMaxItemsValue: false,
    hasLoadThrottleValue: false,
    hasDelimiterValue: false,
    hasDropdownParentValue: false,
    hasPreloadValue: false,
    hasOpenOnFocusValue: false,
    hasCloseAfterSelectValue: false,
    hasHideSelectedValue: false,
    hasAddPrecedenceValue: false,
    hasCreateOnBlurValue: false,
    hasClearAfterSelectValue: false,
    hasUrlValue: false,
    hasSelectedUrlValue: false,
    hasCreateUrlValue: false
  }, overrides)
}

await withTomSelectControllerSandbox("rails-fields-kit-behavior-options-", ({ TomSelectController }) => {
  const defaultController = controllerWithBaseValues(TomSelectController)
  const defaultOptions = defaultController.options()

  assert.equal(Object.prototype.hasOwnProperty.call(defaultOptions, "addPrecedence"), false)
  assert.equal(Object.prototype.hasOwnProperty.call(defaultOptions, "createOnBlur"), false)
  assert.equal(Object.prototype.hasOwnProperty.call(defaultOptions, "clearAfterSelect"), false)

  const configuredController = controllerWithBaseValues(TomSelectController, {
    hasAddPrecedenceValue: true,
    addPrecedenceValue: true,
    hasCreateOnBlurValue: true,
    createOnBlurValue: true,
    hasClearAfterSelectValue: true,
    clearAfterSelectValue: true
  })
  const configuredOptions = configuredController.options()

  assert.equal(configuredOptions.addPrecedence, true)
  assert.equal(configuredOptions.createOnBlur, true)
  assert.equal(configuredOptions.clearAfterSelect, true)
})

console.log("rails_fields_kit Tom Select behavior options smoke passed")
