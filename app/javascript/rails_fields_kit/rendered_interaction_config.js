const KIND_ATTRIBUTE = "data-rails-fields-kit--tom-select-kind-value"
const MAX_OPTIONS_ATTRIBUTE = "data-rails-fields-kit--tom-select-max-options-value"
const MAX_ITEMS_ATTRIBUTE = "data-rails-fields-kit--tom-select-max-items-value"
const LOAD_THROTTLE_ATTRIBUTE = "data-rails-fields-kit--tom-select-load-throttle-value"
const DELIMITER_ATTRIBUTE = "data-rails-fields-kit--tom-select-delimiter-value"
const PRELOAD_ATTRIBUTE = "data-rails-fields-kit--tom-select-preload-value"
const OPEN_ON_FOCUS_ATTRIBUTE = "data-rails-fields-kit--tom-select-open-on-focus-value"
const CLOSE_AFTER_SELECT_ATTRIBUTE = "data-rails-fields-kit--tom-select-close-after-select-value"
const HIDE_SELECTED_ATTRIBUTE = "data-rails-fields-kit--tom-select-hide-selected-value"
const PERSIST_ATTRIBUTE = "data-rails-fields-kit--tom-select-persist-value"

function readAttribute(element, attributeName) {
  if (!element || typeof element.getAttribute !== "function") return null

  const value = element.getAttribute(attributeName)
  return value === "" ? null : value
}

function readBooleanAttribute(element, attributeName) {
  const value = readAttribute(element, attributeName)
  if (value === null) return null

  return value === "true"
}

function readNumberAttribute(element, attributeName) {
  const value = readAttribute(element, attributeName)
  if (value === null) return null

  const number = Number(value)
  return Number.isFinite(number) ? number : null
}

export function readRenderedInteractionConfig(element) {
  if (!readAttribute(element, KIND_ATTRIBUTE)) return null

  return {
    maxOptions: readNumberAttribute(element, MAX_OPTIONS_ATTRIBUTE),
    maxItems: readNumberAttribute(element, MAX_ITEMS_ATTRIBUTE),
    loadThrottle: readNumberAttribute(element, LOAD_THROTTLE_ATTRIBUTE),
    delimiter: readAttribute(element, DELIMITER_ATTRIBUTE),
    preload: readBooleanAttribute(element, PRELOAD_ATTRIBUTE),
    openOnFocus: readBooleanAttribute(element, OPEN_ON_FOCUS_ATTRIBUTE),
    closeAfterSelect: readBooleanAttribute(element, CLOSE_AFTER_SELECT_ATTRIBUTE),
    hideSelected: readBooleanAttribute(element, HIDE_SELECTED_ATTRIBUTE),
    persist: readBooleanAttribute(element, PERSIST_ATTRIBUTE) ?? false
  }
}
