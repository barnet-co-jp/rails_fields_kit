import TomSelectController from "./tom_select_controller.js"

const TOM_SELECT_CONTROLLER = "rails-fields-kit--tom-select"
const TEXT_OVERRIDE_ATTRIBUTES = {
  noResultsText: "data-rails-fields-kit--tom-select-no-results-text-value",
  loadingText: "data-rails-fields-kit--tom-select-loading-text-value",
  createText: "data-rails-fields-kit--tom-select-create-text-value"
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

function nativeFieldRenderedState(element) {
  return {
    required: element.required === true || element.hasAttribute("required"),
    disabled: element.disabled === true || element.hasAttribute("disabled"),
    readonly: element.readOnly === true || element.hasAttribute("readonly")
  }
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
    wrapperElement: nativeFieldWrapper(element),
    ...nativeFieldRenderedState(element)
  }
}

export { TomSelectController }
export default TomSelectController
