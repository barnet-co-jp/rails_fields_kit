const SELECTED_URL_ATTRIBUTE = "data-rails-fields-kit--tom-select-selected-url-value"
const SELECTED_PARAM_ATTRIBUTE = "data-rails-fields-kit--tom-select-selected-param-value"
const SELECTED_MULTIPLE_PARAM_ATTRIBUTE = "data-rails-fields-kit--tom-select-selected-multiple-param-value"
const SELECTED_QUERY_PARAMS_ATTRIBUTE = "data-rails-fields-kit--tom-select-selected-query-params-value"

function readAttribute(element, attributeName) {
  if (!element || typeof element.getAttribute !== "function") return null

  const value = element.getAttribute(attributeName)
  return value === "" ? null : value
}

function readJsonObject(value) {
  if (!value) return {}

  try {
    const parsed = JSON.parse(value)
    return parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : {}
  } catch {
    return {}
  }
}

export function readRenderedSelectedPreloadConfig(element) {
  const selectedUrl = readAttribute(element, SELECTED_URL_ATTRIBUTE)
  if (!selectedUrl) return null

  return {
    selectedUrl,
    selectedParam: readAttribute(element, SELECTED_PARAM_ATTRIBUTE) || "id",
    selectedMultipleParam: readAttribute(element, SELECTED_MULTIPLE_PARAM_ATTRIBUTE) || "ids",
    selectedQueryParams: readJsonObject(readAttribute(element, SELECTED_QUERY_PARAMS_ATTRIBUTE))
  }
}
