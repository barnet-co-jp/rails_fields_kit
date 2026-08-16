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
    hasUrlValue: false,
    hasSelectedUrlValue: false,
    hasCreateUrlValue: false
  }, overrides)
}

await withTomSelectControllerSandbox("rails-fields-kit-dropdown-parent-", ({ TomSelectController }) => {
  const defaultController = controllerWithBaseValues(TomSelectController)

  assert.equal(
    Object.prototype.hasOwnProperty.call(defaultController.options(), "dropdownParent"),
    false,
    "dropdownParent should be omitted unless the rendered data value is present"
  )

  const portalController = controllerWithBaseValues(TomSelectController, {
    hasDropdownParentValue: true,
    dropdownParentValue: "body"
  })

  assert.equal(
    portalController.options().dropdownParent,
    "body",
    "dropdownParent should be passed through to Tom Select options"
  )
})

console.log("rails_fields_kit Tom Select dropdown parent smoke passed")
