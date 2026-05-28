const KIND_ATTRIBUTE = "data-rails-fields-kit--tom-select-kind-value"
const VALUE_FIELD_ATTRIBUTE = "data-rails-fields-kit--tom-select-value-field-value"
const LABEL_FIELD_ATTRIBUTE = "data-rails-fields-kit--tom-select-label-field-value"
const SEARCH_FIELD_ATTRIBUTE = "data-rails-fields-kit--tom-select-search-field-value"
const OPTION_DESCRIPTION_FIELD_ATTRIBUTE = "data-rails-fields-kit--tom-select-option-description-field-value"
const OPTION_BADGE_FIELD_ATTRIBUTE = "data-rails-fields-kit--tom-select-option-badge-field-value"

function readAttribute(element, attributeName) {
  if (!element || typeof element.getAttribute !== "function") return null

  const value = element.getAttribute(attributeName)
  return value === "" ? null : value
}

function readSearchFields(element) {
  const value = readAttribute(element, SEARCH_FIELD_ATTRIBUTE)
  if (!value) return ["text"]

  return value.split(",").map((field) => field.trim()).filter(Boolean)
}

export function readRenderedOptionPayloadMapping(element) {
  if (!readAttribute(element, KIND_ATTRIBUTE)) return null

  return {
    valueField: readAttribute(element, VALUE_FIELD_ATTRIBUTE) || "value",
    labelField: readAttribute(element, LABEL_FIELD_ATTRIBUTE) || "text",
    searchFields: readSearchFields(element),
    optionDescriptionField: readAttribute(element, OPTION_DESCRIPTION_FIELD_ATTRIBUTE),
    optionBadgeField: readAttribute(element, OPTION_BADGE_FIELD_ATTRIBUTE)
  }
}
