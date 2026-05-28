const CREATE_URL_ATTRIBUTE = "data-rails-fields-kit--tom-select-create-url-value"
const CREATE_PARAM_ATTRIBUTE = "data-rails-fields-kit--tom-select-create-param-value"
const CREATE_PARAMS_ATTRIBUTE = "data-rails-fields-kit--tom-select-create-params-value"

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

export function readRenderedCreateOnTheFlyConfig(element) {
  const createUrl = readAttribute(element, CREATE_URL_ATTRIBUTE)
  if (!createUrl) return null

  return {
    createUrl,
    createParam: readAttribute(element, CREATE_PARAM_ATTRIBUTE) || "text",
    createParams: readJsonObject(readAttribute(element, CREATE_PARAMS_ATTRIBUTE))
  }
}
