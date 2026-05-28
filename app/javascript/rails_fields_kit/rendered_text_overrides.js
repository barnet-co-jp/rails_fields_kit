const KIND_ATTRIBUTE = "data-rails-fields-kit--tom-select-kind-value"
const NO_RESULTS_TEXT_ATTRIBUTE = "data-rails-fields-kit--tom-select-no-results-text-value"
const LOADING_TEXT_ATTRIBUTE = "data-rails-fields-kit--tom-select-loading-text-value"
const CREATE_TEXT_ATTRIBUTE = "data-rails-fields-kit--tom-select-create-text-value"

function readAttribute(element, attributeName) {
  if (!element || typeof element.getAttribute !== "function") return null

  const value = element.getAttribute(attributeName)
  return value === "" ? null : value
}

export function readRenderedTextOverrides(element) {
  if (!readAttribute(element, KIND_ATTRIBUTE)) return null

  return {
    noResultsText: readAttribute(element, NO_RESULTS_TEXT_ATTRIBUTE),
    loadingText: readAttribute(element, LOADING_TEXT_ATTRIBUTE),
    createText: readAttribute(element, CREATE_TEXT_ATTRIBUTE)
  }
}
