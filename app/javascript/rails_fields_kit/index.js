import TomSelectController from "./tom_select_controller.js"

const TOM_SELECT_CONTROLLER = "rails-fields-kit--tom-select"
const TEXT_OVERRIDE_ATTRIBUTES = {
  noResultsText: "data-rails-fields-kit--tom-select-no-results-text-value",
  loadingText: "data-rails-fields-kit--tom-select-loading-text-value",
  createText: "data-rails-fields-kit--tom-select-create-text-value"
}
const REQUEST_PARAM_ATTRIBUTES = {
  queryParams: "data-rails-fields-kit--tom-select-query-params-value",
  selectedQueryParams: "data-rails-fields-kit--tom-select-selected-query-params-value",
  createParams: "data-rails-fields-kit--tom-select-create-params-value"
}
const PLUGINS_ATTRIBUTE = "data-rails-fields-kit--tom-select-plugins-value"
const SELECTED_PRELOAD_ATTRIBUTES = {
  selectedUrl: "data-rails-fields-kit--tom-select-selected-url-value",
  selectedParam: "data-rails-fields-kit--tom-select-selected-param-value",
  selectedMultipleParam: "data-rails-fields-kit--tom-select-selected-multiple-param-value",
  selectedQueryParams: "data-rails-fields-kit--tom-select-selected-query-params-value"
}
const OPTION_PAYLOAD_MAPPING_ATTRIBUTES = {
  kind: "data-rails-fields-kit--tom-select-kind-value",
  valueField: "data-rails-fields-kit--tom-select-value-field-value",
  labelField: "data-rails-fields-kit--tom-select-label-field-value",
  searchField: "data-rails-fields-kit--tom-select-search-field-value",
  optionDescriptionField: "data-rails-fields-kit--tom-select-option-description-field-value",
  optionBadgeField: "data-rails-fields-kit--tom-select-option-badge-field-value"
}
const DEFAULT_SELECTED_PARAM = "id"
const DEFAULT_SELECTED_MULTIPLE_PARAM = "ids"
const DEFAULT_VALUE_FIELD = "value"
const DEFAULT_LABEL_FIELD = "text"
const DEFAULT_SEARCH_FIELD = "text"
const NATIVE_FIELD_TAGS = new Set(["input", "select", "textarea"])
const NATIVE_FIELD_WRAPPER_SELECTOR = ".rfk-field"
const NATIVE_FIELD_LABEL_SELECTOR = "label"
const NATIVE_FIELD_HINT_CLASS = "rfk-hint"
const NATIVE_FIELD_ERROR_CLASS = "rfk-error"

function hasTomSelectController(element) {
  const controllers = element?.getAttribute?.("data-controller")?.split(/\s+/) || []
  return controllers.includes(TOM_SELECT_CONTROLLER)
}

function textOverrideValue(element, attributeName) {
  return element.hasAttribute(attributeName) ? element.getAttribute(attributeName) : null
}

function hasAnyAttribute(element, attributes) {
  return Object.values(attributes).some((attributeName) => element.hasAttribute(attributeName))
}

function dataValue(element, attributeName) {
  return element.hasAttribute(attributeName) ? element.getAttribute(attributeName) : null
}

function objectDataValue(element, attributeName) {
  const value = dataValue(element, attributeName)
  if (value === null) return {}

  try {
    const parsedValue = JSON.parse(value)
    return parsedValue && typeof parsedValue === "object" && !Array.isArray(parsedValue) ? parsedValue : {}
  } catch {
    return {}
  }
}

function pluginValues(element) {
  if (!element.hasAttribute(PLUGINS_ATTRIBUTE)) return []

  try {
    const plugins = JSON.parse(element.getAttribute(PLUGINS_ATTRIBUTE))
    return Array.isArray(plugins) ? plugins : []
  } catch {
    return []
  }
}

function isNativeFormControl(element) {
  const tagName = element?.tagName?.toLowerCase?.()
  return NATIVE_FIELD_TAGS.has(tagName)
}

function describedByIdsFor(element) {
  return Array.from(new Set(
    (element.getAttribute("aria-describedby") || "")
      .split(/\s+/)
      .filter(Boolean)
  ))
}

function elementById(element, id) {
  return element.ownerDocument?.getElementById?.(id) || null
}

function hasClass(element, className) {
  return element?.classList?.contains?.(className) ||
    (element?.getAttribute?.("class") || "").split(/\s+/).includes(className)
}

function firstElementWithClass(elements, className) {
  return elements.find((element) => hasClass(element, className)) || null
}

function nativeFieldWrapper(element) {
  return element.closest?.(NATIVE_FIELD_WRAPPER_SELECTOR) || null
}

function cssEscape(value) {
  if (typeof CSS !== "undefined" && typeof CSS.escape === "function") return CSS.escape(String(value))

  return String(value).replace(/\\/g, "\\\\").replace(/"/g, "\\\"")
}

function nativeFieldLabel(element, wrapperElement = nativeFieldWrapper(element)) {
  const id = element.getAttribute("id")

  if (id) {
    const labelElement = element.ownerDocument?.querySelector?.(`label[for="${cssEscape(id)}"]`) || null
    if (labelElement) return labelElement
  }

  return wrapperElement?.querySelector?.(NATIVE_FIELD_LABEL_SELECTOR) || null
}

function hasRenderedTomSelectContract(element) {
  if (!element || typeof element.getAttribute !== "function" || typeof element.hasAttribute !== "function") return false

  return hasTomSelectController(element) || dataValue(element, OPTION_PAYLOAD_MAPPING_ATTRIBUTES.kind) !== null
}

function splitSearchFields(value) {
  return value.split(",").map((field) => field.trim()).filter(Boolean)
}

export function tomSelectTextOverrideContract(element) {
  if (!element || typeof element.getAttribute !== "function") return null

  const contract = Object.fromEntries(
    Object.entries(TEXT_OVERRIDE_ATTRIBUTES).map(([key, attributeName]) => [
      key,
      textOverrideValue(element, attributeName)
    ])
  )

  if (!hasTomSelectController(element) && Object.values(contract).every((value) => value === null)) return null

  return contract
}

export function tomSelectRequestParamsContract(element) {
  if (!element || typeof element.getAttribute !== "function" || typeof element.hasAttribute !== "function") return null
  if (!hasTomSelectController(element) && !hasAnyAttribute(element, REQUEST_PARAM_ATTRIBUTES)) return null

  return Object.fromEntries(
    Object.entries(REQUEST_PARAM_ATTRIBUTES).map(([key, attributeName]) => [
      key,
      objectDataValue(element, attributeName)
    ])
  )
}

export function tomSelectPluginContract(element) {
  if (!element || typeof element.getAttribute !== "function" || typeof element.hasAttribute !== "function") return null
  if (!hasTomSelectController(element) && !element.hasAttribute(PLUGINS_ATTRIBUTE)) return null

  const plugins = pluginValues(element)

  return {
    plugins,
    hasClearButton: plugins.includes("clear_button"),
    hasRemoveButton: plugins.includes("remove_button")
  }
}

export function readRenderedSelectedPreloadConfig(element) {
  if (!element || typeof element.getAttribute !== "function") return null

  const selectedUrl = dataValue(element, SELECTED_PRELOAD_ATTRIBUTES.selectedUrl)
  if (!selectedUrl) return null

  return {
    selectedUrl,
    selectedParam: dataValue(element, SELECTED_PRELOAD_ATTRIBUTES.selectedParam) || DEFAULT_SELECTED_PARAM,
    selectedMultipleParam: dataValue(element, SELECTED_PRELOAD_ATTRIBUTES.selectedMultipleParam) || DEFAULT_SELECTED_MULTIPLE_PARAM,
    selectedQueryParams: objectDataValue(element, SELECTED_PRELOAD_ATTRIBUTES.selectedQueryParams)
  }
}

export function readRenderedOptionPayloadMapping(element) {
  if (!hasRenderedTomSelectContract(element)) return null

  const searchField = dataValue(element, OPTION_PAYLOAD_MAPPING_ATTRIBUTES.searchField) || DEFAULT_SEARCH_FIELD

  return {
    valueField: dataValue(element, OPTION_PAYLOAD_MAPPING_ATTRIBUTES.valueField) || DEFAULT_VALUE_FIELD,
    labelField: dataValue(element, OPTION_PAYLOAD_MAPPING_ATTRIBUTES.labelField) || DEFAULT_LABEL_FIELD,
    searchFields: splitSearchFields(searchField),
    optionDescriptionField: dataValue(element, OPTION_PAYLOAD_MAPPING_ATTRIBUTES.optionDescriptionField) || null,
    optionBadgeField: dataValue(element, OPTION_PAYLOAD_MAPPING_ATTRIBUTES.optionBadgeField) || null
  }
}

export function nativeFieldAccessibilityContract(element) {
  if (!element || typeof element.getAttribute !== "function" || !isNativeFormControl(element)) return null

  const describedByIds = describedByIdsFor(element)
  const describedByElements = describedByIds
    .map((id) => elementById(element, id))
    .filter(Boolean)
  const wrapperElement = nativeFieldWrapper(element)

  return {
    describedByIds,
    describedByElements,
    labelElement: nativeFieldLabel(element, wrapperElement),
    hintElement: firstElementWithClass(describedByElements, NATIVE_FIELD_HINT_CLASS),
    errorElement: firstElementWithClass(describedByElements, NATIVE_FIELD_ERROR_CLASS),
    wrapperElement
  }
}

export { TomSelectController }
export default TomSelectController
