import TomSelectController from "./tom_select_controller.js"

const TOM_SELECT_CONTROLLER = "rails-fields-kit--tom-select"
const TOM_SELECT_VALUE_PREFIX = "data-rails-fields-kit--tom-select"
const FIELD_KIND_ATTRIBUTE = `${TOM_SELECT_VALUE_PREFIX}-kind-value`
const TEXT_OVERRIDE_ATTRIBUTES = {
  noResultsText: "data-rails-fields-kit--tom-select-no-results-text-value",
  loadingText: "data-rails-fields-kit--tom-select-loading-text-value",
  createText: "data-rails-fields-kit--tom-select-create-text-value"
}
const REQUEST_CONTRACT_ATTRIBUTES = {
  url: `${TOM_SELECT_VALUE_PREFIX}-url-value`,
  selectedUrl: `${TOM_SELECT_VALUE_PREFIX}-selected-url-value`,
  createUrl: `${TOM_SELECT_VALUE_PREFIX}-create-url-value`,
  queryParam: `${TOM_SELECT_VALUE_PREFIX}-query-param-value`,
  queryParams: `${TOM_SELECT_VALUE_PREFIX}-query-params-value`,
  selectedParam: `${TOM_SELECT_VALUE_PREFIX}-selected-param-value`,
  selectedMultipleParam: `${TOM_SELECT_VALUE_PREFIX}-selected-multiple-param-value`,
  createParam: `${TOM_SELECT_VALUE_PREFIX}-create-param-value`,
  createParams: `${TOM_SELECT_VALUE_PREFIX}-create-params-value`,
  minLength: `${TOM_SELECT_VALUE_PREFIX}-min-length-value`,
  errorSurfaceId: `${TOM_SELECT_VALUE_PREFIX}-error-surface-id-value`
}
const REQUEST_CONTRACT_DEFAULTS = {
  queryParam: "q",
  selectedParam: "id",
  selectedMultipleParam: "ids",
  createParam: "text",
  minLength: 0
}
const PLUGINS_ATTRIBUTE = "data-rails-fields-kit--tom-select-plugins-value"
const SELECTED_PRELOAD_ATTRIBUTES = {
  selectedUrl: "data-rails-fields-kit--tom-select-selected-url-value",
  selectedParam: "data-rails-fields-kit--tom-select-selected-param-value",
  selectedMultipleParam: "data-rails-fields-kit--tom-select-selected-multiple-param-value",
  selectedQueryParams: "data-rails-fields-kit--tom-select-selected-query-params-value"
}
const DEFAULT_SELECTED_PARAM = "id"
const DEFAULT_SELECTED_MULTIPLE_PARAM = "ids"
const NATIVE_FIELD_TAGS = new Set(["input", "select", "textarea"])
const NATIVE_FIELD_WRAPPER_SELECTOR = ".rfk-field"
const NATIVE_FIELD_LABEL_SELECTOR = "label"
const NATIVE_FIELD_HINT_CLASS = "rfk-hint"
const NATIVE_FIELD_ERROR_CLASS = "rfk-error"
const NATIVE_FIELD_PREFIX_CLASS = "rfk-prefix"
const NATIVE_FIELD_SUFFIX_CLASS = "rfk-suffix"

function hasTomSelectController(element) {
  const controllers = element?.getAttribute?.("data-controller")?.split(/\s+/) || []
  return controllers.includes(TOM_SELECT_CONTROLLER)
}

function textOverrideValue(element, attributeName) {
  return element.hasAttribute(attributeName) ? element.getAttribute(attributeName) : null
}

function selectedValuesFrom(element) {
  const value = element.tomselect?.getValue?.()
  if (value === undefined) return null

  return Array.isArray(value) ? [...value] : [value]
}

function dataValue(element, attributeName) {
  return element.hasAttribute(attributeName) ? element.getAttribute(attributeName) : null
}

function requestContractValue(element, key) {
  const value = dataValue(element, REQUEST_CONTRACT_ATTRIBUTES[key])
  if (value === null) return REQUEST_CONTRACT_DEFAULTS[key] ?? null
  if (key !== "minLength") return value

  const parsedValue = Number(value)
  return Number.isFinite(parsedValue) ? parsedValue : REQUEST_CONTRACT_DEFAULTS.minLength
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

function nativeFieldAffix(wrapperElement, className) {
  return wrapperElement?.querySelector?.(`.${className}`) || null
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

export function tomSelectRequestContract(element) {
  if (!element || typeof element.getAttribute !== "function" || !hasTomSelectController(element)) return null

  const url = requestContractValue(element, "url")
  const selectedUrl = requestContractValue(element, "selectedUrl")
  const createUrl = requestContractValue(element, "createUrl")

  return {
    controller: TOM_SELECT_CONTROLLER,
    hasRemoteSearch: Boolean(url),
    hasSelectedPreload: Boolean(selectedUrl),
    hasCreateEndpoint: Boolean(createUrl),
    url,
    selectedUrl,
    createUrl,
    queryParam: requestContractValue(element, "queryParam"),
    queryParams: objectDataValue(element, REQUEST_CONTRACT_ATTRIBUTES.queryParams),
    selectedParam: requestContractValue(element, "selectedParam"),
    selectedMultipleParam: requestContractValue(element, "selectedMultipleParam"),
    createParam: requestContractValue(element, "createParam"),
    createParams: objectDataValue(element, REQUEST_CONTRACT_ATTRIBUTES.createParams),
    minLength: requestContractValue(element, "minLength"),
    errorSurfaceId: requestContractValue(element, "errorSurfaceId")
  }
}

export function tomSelectFieldKindContract(element) {
  if (!element || typeof element.getAttribute !== "function" || !hasTomSelectController(element)) return null

  const kind = dataValue(element, FIELD_KIND_ATTRIBUTE)
  if (!kind) return null

  return {
    controller: TOM_SELECT_CONTROLLER,
    kind
  }
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

export function tomSelectSelectionContract(element) {
  if (!element || typeof element.getAttribute !== "function" || !hasTomSelectController(element)) return null

  const values = selectedValuesFrom(element)
  if (!values) return null

  return { values }
}

export function readRenderedErrorSurface(element) {
  if (!element || typeof element.getAttribute !== "function" || typeof element.hasAttribute !== "function") return null

  const surfaceId = dataValue(element, REQUEST_CONTRACT_ATTRIBUTES.errorSurfaceId)
  if (!surfaceId) return null

  return element.ownerDocument?.getElementById?.(surfaceId) || null
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
    prefixElement: nativeFieldAffix(wrapperElement, NATIVE_FIELD_PREFIX_CLASS),
    suffixElement: nativeFieldAffix(wrapperElement, NATIVE_FIELD_SUFFIX_CLASS),
    wrapperElement
  }
}

export { TomSelectController }
export default TomSelectController
