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
    hasUrlValue: false,
    hasSelectedUrlValue: false,
    hasCreateUrlValue: false
  }, overrides)
}

await withTomSelectControllerSandbox("rails-fields-kit-class-names-", ({ TomSelectController }) => {
  const defaultController = controllerWithBaseValues(TomSelectController)

  assert.equal(
    Object.prototype.hasOwnProperty.call(defaultController.options(), "classNames"),
    false,
    "classNames should be omitted unless the rendered data value is present"
  )

  const customController = controllerWithBaseValues(TomSelectController, {
    hasClassNamesValue: true,
    classNamesValue: {
      control: "ts-control host-control",
      dropdown: "ts-dropdown host-dropdown",
      option: "ts-option host-option"
    }
  })

  assert.deepEqual(
    customController.options().classNames,
    {
      control: "ts-control host-control",
      dropdown: "ts-dropdown host-dropdown",
      option: "ts-option host-option"
    },
    "rendered classNames should be passed through to Tom Select options"
  )
})

console.log("rails_fields_kit Tom Select classNames smoke passed")
