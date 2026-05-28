const URL_ATTRIBUTE = "data-rails-fields-kit--tom-select-url-value"
const QUERY_PARAM_ATTRIBUTE = "data-rails-fields-kit--tom-select-query-param-value"
const QUERY_PARAMS_ATTRIBUTE = "data-rails-fields-kit--tom-select-query-params-value"

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

export function readRenderedRemoteSearchConfig(element) {
  const url = readAttribute(element, URL_ATTRIBUTE)
  if (!url) return null

  return {
    url,
    queryParam: readAttribute(element, QUERY_PARAM_ATTRIBUTE) || "q",
    queryParams: readJsonObject(readAttribute(element, QUERY_PARAMS_ATTRIBUTE))
  }
}
