import TomSelectController from "./tom_select_controller.js"

const TOM_SELECT_CONTROLLER = "rails-fields-kit--tom-select"
const TOM_SELECT_VALUE_PREFIX = "data-rails-fields-kit--tom-select"
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
  selectedParam: `${TOM_SELECT_VALUE_PREFIX}-selected-param-value`,
  selectedMultipleParam: `${TOM_SELECT_VALUE_PREFIX}-selected-multiple-param-value`,
  createParam: `${TOM_SELECT_VALUE_PREFIX}-create-param-value`,
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
const NATIVE_FIELD_TAGS = new Set(["input", "select", "textarea"])
const NATIVE_FIELD_WRAPPER_SELECTOR = ".rfk-field"
const NATIVE_FIELD_HINT_CLASS = "rfk-hint"
const NATIVE_FIELD_ERROR_CLASS = "rfk-error"

function hasTomSelectController(element) {
  const controllers = element?.getAttribute?.("data-controller")?.split(/\s+/) || []
  return controllers.includes(TOM_SELECT_CONTROLLER)
}

function textOverrideValue(element, attributeName) {
  return element.hasAttribute(attributeName) ? element.getAttribute(attributeName) : null
}

function requestContractValue(element, key) {
  const attributeName = REQUEST_CONTRACT_ATTRIBUTES[key]
  if (!element.hasAttribute(attributeName)) return REQUEST_CONTRACT_DEFAULTS[key] ?? null

  const value = element.getAttribute(attributeName)
  if (key !== "minLength") return value

  const parsedValue = Number(value)
  return Number.isFinite(parsedValue) ? parsedValue : REQUEST_CONTRACT_DEFAULTS.minLength
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
    selectedParam: requestContractValue(element, "selectedParam"),
    selectedMultipleParam: requestContractValue(element, "selectedMultipleParam"),
    createParam: requestContractValue(element, "createParam"),
    minLength: requestContractValue(element, "minLength"),
    errorSurfaceId: requestContractValue(element, "errorSurfaceId")
  }
}

export function nativeFieldAccessibilityContract(element) {
  if (!element || typeof element.getAttribute !== "function" || !isNativeFormControl(element)) return null

  const describedByIds = describedByIdsFor(element)
  const describedByElements = describedByIds
    .map((id) => elementById(element, id))
    .filter(Boolean)

  return {
    describedByIds,
    describedByElements,
    hintElement: firstElementWithClass(describedByElements, NATIVE_FIELD_HINT_CLASS),
    errorElement: firstElementWithClass(describedByElements, NATIVE_FIELD_ERROR_CLASS),
    wrapperElement: nativeFieldWrapper(element)
  }
}

export { TomSelectController }
export default TomSelectController
