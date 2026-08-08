import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    kind: String,
    url: String,
    selectedUrl: String,
    createUrl: String,
    queryParams: Object,
    dependsOn: Object,
    clearOnDependencyChange: { type: Boolean, default: false },
    selectedQueryParams: Object,
    createParams: Object,
    create: Boolean,
    freeText: Boolean,
    placeholder: String,
    errorSurfaceId: String,
    queryParam: { type: String, default: "q" },
    selectedParam: { type: String, default: "id" },
    selectedMultipleParam: { type: String, default: "ids" },
    createParam: { type: String, default: "text" },
    valueField: { type: String, default: "value" },
    labelField: { type: String, default: "text" },
    displayField: String,
    labelFallback: { type: Boolean, default: true },
    searchField: { type: String, default: "text" },
    minLength: { type: Number, default: 0 },
    maxOptions: Number,
    maxItems: Number,
    loadThrottle: Number,
    delimiter: String,
    dropdownParent: String,
    preload: Boolean,
    openOnFocus: Boolean,
    closeAfterSelect: Boolean,
    hideSelected: Boolean,
    persist: Boolean,
    noResultsText: String,
    loadingText: String,
    createText: String,
    optionDescriptionField: String,
    optionBadgeField: String,
    optionMetadataFields: Array,
    lookupTextFieldId: String,
    lookupIdFieldId: String,
    clearLookupIdOnTextChange: { type: Boolean, default: true },
    plugins: Array,
    classNames: Object
  }

  connect() {
    this.connected = true
    this.requestControllers = {}
    this.requestTokens = {}
    this.dependencyListeners = []
    this.dependencyParams = this.currentDependencyParams()
    this.tomSelect = new TomSelect(this.element, this.options())
    this.bindTomSelectEvents()
    this.bindLookupEvents()
    this.bindDependencyEvents()
    this.clearErrorSurface()
    this.loadSelectedOptions()
  }

  disconnect() {
    this.connected = false
    this.unbindDependencyEvents()
    this.abortAllRequests()
    if (this.tomSelect) {
      this.tomSelect.destroy()
      this.tomSelect = null
    }
  }

  options() {
    const options = {
      create: this.createValue || this.freeTextValue,
      persist: this.hasPersistValue ? this.persistValue : false,
      placeholder: this.placeholderValue || this.element.getAttribute("placeholder") || undefined,
      plugins: this.pluginsValue.length > 0 ? this.pluginsValue : undefined,
      render: this.renderers()
    }

    if (this.hasClassNamesValue) options.classNames = this.classNamesValue
    if (this.hasMaxOptionsValue) options.maxOptions = this.maxOptionsValue
    if (this.hasMaxItemsValue) options.maxItems = this.maxItemsValue
    if (this.hasLoadThrottleValue) options.loadThrottle = this.loadThrottleValue
    if (this.hasDelimiterValue) options.delimiter = this.delimiterValue
    if (this.hasDropdownParentValue) options.dropdownParent = this.dropdownParentValue
    if (this.hasPreloadValue) options.preload = this.preloadValue
    if (this.hasOpenOnFocusValue) options.openOnFocus = this.openOnFocusValue
    if (this.hasCloseAfterSelectValue) options.closeAfterSelect = this.closeAfterSelectValue
    if (this.hasHideSelectedValue) options.hideSelected = this.hideSelectedValue

    if (this.hasUrlValue || this.hasSelectedUrlValue) {
      options.valueField = this.valueFieldValue
      options.labelField = this.labelFieldValue
      options.searchField = this.searchFields()
    }

    if (this.hasUrlValue) {
      options.shouldLoad = (query) => query.length >= this.minLengthValue
      options.load = (query, callback) => this.loadOptions(query, callback)
    }

    if (this.hasCreateUrlValue) {
      options.create = (input, callback) => this.createOption(input, callback)
    }

    return options
  }

  bindTomSelectEvents() {
    this.tomSelect.on("change", (value) => {
      this.clearErrorSurface()
      this.syncLookupSelection(value)
      this.dispatch("change", { detail: this.selectionDetail(value) })
    })
    this.tomSelect.on("item_add", (value, item) => {
      this.clearErrorSurface()
      this.dispatch("item-add", { detail: this.selectionDetail(value, { item }) })
    })
    this.tomSelect.on("item_remove", (value, item) => {
      this.clearErrorSurface()
      this.dispatch("item-remove", { detail: this.selectionDetail(value, { item }) })
    })
    this.tomSelect.on("clear", () => {
      this.clearErrorSurface()
      this.dispatch("clear", { detail: { values: this.selectedValues(), options: this.selectedOptions() } })
    })
  }

  bindLookupEvents() {
    if (this.kindValue !== "lookup") return

    this.tomSelect.on("type", (text) => {
      const textField = this.lookupTextField()
      if (textField) textField.value = text
      if (this.clearLookupIdOnTextChangeValue) {
        const idField = this.lookupIdField()
        if (idField) idField.value = ""
      }
    })
  }

  bindDependencyEvents() {
    this.unbindDependencyEvents()
    this.dependencyParams = this.currentDependencyParams()
    if (!this.hasDependsOnValue) return

    Object.entries(this.dependsOnValue).forEach(([key, selector]) => {
      if (!this.hasPresentValue(key) || !this.hasPresentValue(selector)) return

      const element = document.querySelector(selector)
      if (!element) return

      const handler = () => this.handleDependencyChange()
      ;["change", "input"].forEach((eventName) => {
        element.addEventListener(eventName, handler)
        this.dependencyListeners.push({ element, eventName, handler })
      })
    })
  }

  unbindDependencyEvents() {
    if (!this.dependencyListeners) return

    this.dependencyListeners.forEach(({ element, eventName, handler }) => {
      element.removeEventListener(eventName, handler)
    })
    this.dependencyListeners = []
  }

  handleDependencyChange() {
    const previousParams = this.dependencyParams || {}
    const params = this.currentDependencyParams()
    const changed = this.changedDependencyParams(previousParams, params)
    if (Object.keys(changed).length === 0) return

    this.dependencyParams = params
    this.abortRequest("load")
    this.clearRemoteOptions()

    if (this.clearOnDependencyChangeValue && this.tomSelect && typeof this.tomSelect.clear === "function") {
      this.tomSelect.clear(true)
    }

    this.reloadOpenDropdown()
    this.dispatch("dependency-change", { detail: { params, previousParams, changed } })
  }

  currentDependencyParams() {
    if (!this.hasDependsOnValue) return {}

    return Object.entries(this.dependsOnValue).reduce((params, [key, selector]) => {
      if (!this.hasPresentValue(key) || !this.hasPresentValue(selector)) return params

      const element = document.querySelector(selector)
      const value = this.dependencyElementValue(element)

      if (Array.isArray(value)) {
        const values = value.filter((item) => this.hasPresentValue(item))
        if (values.length > 0) params[key] = values
      } else if (this.hasPresentValue(value)) {
        params[key] = value
      }

      return params
    }, {})
  }

  dependencyElementValue(element) {
    if (!element) return null

    const tagName = element.tagName ? element.tagName.toLowerCase() : ""
    if (tagName === "input" && element.type === "checkbox") return element.checked ? element.value : null
    if (tagName === "select" && element.multiple) return Array.from(element.selectedOptions).map((option) => option.value)

    return element.value
  }

  changedDependencyParams(previousParams, params) {
    const keys = Array.from(new Set([...Object.keys(previousParams), ...Object.keys(params)]))

    return keys.reduce((changed, key) => {
      if (JSON.stringify(previousParams[key]) !== JSON.stringify(params[key])) {
        changed[key] = { previous: previousParams[key], current: params[key] }
      }

      return changed
    }, {})
  }

  remoteSearchParams() {
    return { ...this.queryParamsValue, ...(this.dependencyParams || {}) }
  }

  clearRemoteOptions() {
    if (!this.tomSelect || typeof this.tomSelect.clearOptions !== "function") return

    this.tomSelect.clearOptions()
  }

  reloadOpenDropdown() {
    if (!this.hasUrlValue || !this.tomSelect || !this.tomSelect.isOpen || typeof this.tomSelect.load !== "function") return

    this.tomSelect.load(this.tomSelect.lastQuery || "")
  }

  syncLookupSelection(value) {
    if (this.kindValue !== "lookup") return

    const option = this.optionForValue(value)
    const textField = this.lookupTextField()
    const idField = this.lookupIdField()
    if (textField) textField.value = option ? this.optionLabel(option) : this.element.value
    if (idField) idField.value = option ? this.displayValue(option[this.valueFieldValue]) : ""
  }

  lookupTextField() {
    return this.hasLookupTextFieldIdValue ? document.getElementById(this.lookupTextFieldIdValue) : null
  }

  lookupIdField() {
    return this.hasLookupIdFieldIdValue ? document.getElementById(this.lookupIdFieldIdValue) : null
  }

  renderers() {
    return {
      option: (data, escape) => this.optionTemplate(data, escape, "option"),
      item: (data, escape) => this.itemTemplate(data, escape),
      no_results: () => `<div class="no-results" role="status" aria-live="polite" aria-atomic="true">${this.escape(this.renderText(this.noResultsTextValue, "No results found"))}</div>`,
      loading: () => `<div class="loading" role="status" aria-live="polite" aria-atomic="true">${this.escape(this.renderText(this.loadingTextValue, "Loading..."))}</div>`,
      option_create: (data, escape) => `<div class="create">${escape(this.renderText(this.createTextValue, "Add"))} <strong>${escape(data.input)}</strong></div>`
    }
  }

  optionTemplate(data, escape, kind) {
    const label = escape(this.optionLabel(data))
    const description = this.hasOptionDescriptionFieldValue ? data[this.optionDescriptionFieldValue] : null
    const badge = this.hasOptionBadgeFieldValue ? data[this.optionBadgeFieldValue] : null
    const parts = [`<div class="rfk-${kind}">`]

    parts.push("<div class=\"rfk-option-main\">")
    parts.push(`<span class="rfk-option-label">${label}</span>`)
    if (this.hasPresentValue(badge)) parts.push(`<span class="rfk-option-badge">${escape(this.displayValue(badge))}</span>`)
    parts.push("</div>")
    if (this.hasPresentValue(description)) parts.push(`<div class="rfk-option-description">${escape(this.displayValue(description))}</div>`)
    this.metadataRows(data, escape).forEach((row) => parts.push(row))
    parts.push("</div>")

    return parts.join("")
  }

  metadataRows(data, escape) {
    if (!this.hasOptionMetadataFieldsValue) return []

    return this.optionMetadataFieldsValue.flatMap((definition) => {
      if (!definition || !this.hasPresentValue(definition.field)) return []
      const value = data[definition.field]
      if (!this.hasPresentValue(value)) return []

      let display = this.displayValue(value)
      if (definition.format === "currency") {
        const numericValue = Number(value)
        if (Number.isFinite(numericValue)) display = new Intl.NumberFormat(undefined, { style: "currency", currency: definition.currency || "JPY", maximumFractionDigits: 0 }).format(numericValue)
      }
      if (definition.truncate && display.length > definition.truncate) display = `${display.slice(0, definition.truncate)}…`
      const content = `${definition.label ? `${escape(definition.label)} ` : ""}${escape(display)}${definition.suffix ? escape(definition.suffix) : ""}`
      const modifier = definition.style === "badge" || definition.format === "badge" ? " rfk-option-metadata--badge" : ""
      return [`<div class="rfk-option-metadata${modifier}" data-rfk-metadata-field="${escape(definition.field)}">${content}</div>`]
    })
  }

  itemTemplate(data, escape) {
    const label = escape(this.optionLabel(data))

    return [
      `<span class="rfk-item-token">`,
      `<span class="rfk-item-label">${label}</span>`,
      `</span>`
    ].join("")
  }

  optionLabel(data) {
    const label = data[this.labelFieldValue]
    if (this.hasDisplayFieldValue && this.hasPresentValue(data[this.displayFieldValue])) return this.displayValue(data[this.displayFieldValue])
    if (this.hasPresentValue(label)) return this.displayValue(label)
    if (this.labelFallbackValue === false) return ""

    return this.displayValue(data[this.valueFieldValue])
  }

  searchFields() {
    return this.searchFieldValue.split(",").map((field) => field.trim()).filter(Boolean)
  }

  beginRequest(operation) {
    if (!this.requestControllers) this.requestControllers = {}
    if (!this.requestTokens) this.requestTokens = {}

    this.abortRequest(operation)

    const token = Symbol(operation)
    const controller = this.abortController()

    this.requestTokens[operation] = token
    if (controller) this.requestControllers[operation] = controller

    return { signal: controller ? controller.signal : null, token }
  }

  finishRequest(operation, token) {
    if (!this.requestTokens || this.requestTokens[operation] !== token) return

    delete this.requestTokens[operation]
    delete this.requestControllers[operation]
  }

  abortAllRequests() {
    ["load", "selected-load", "create"].forEach((operation) => this.abortRequest(operation))
  }

  abortRequest(operation) {
    if (!this.requestControllers || !this.requestTokens) return

    const controller = this.requestControllers[operation]
    if (controller) controller.abort()

    delete this.requestControllers[operation]
    delete this.requestTokens[operation]
  }

  requestIsCurrent(operation, token) {
    return this.connected && this.requestTokens && this.requestTokens[operation] === token
  }

  abortController() {
    return typeof AbortController === "function" ? new AbortController() : null
  }

  requestOptions(options, signal) {
    return signal ? { ...options, signal } : options
  }

  isAbortError(error) {
    return error && (error.name === "AbortError" || error.code === 20)
  }

  loadOptions(query, callback) {
    this.clearErrorSurface()
    const url = new URL(this.urlValue, window.location.origin)
    this.appendParams(url, this.remoteSearchParams())
    url.searchParams.set(this.queryParamValue, query)

    const { signal, token } = this.beginRequest("load")

    fetch(url.toString(), this.requestOptions({
      headers: { Accept: "application/json" }
    }, signal))
      .then((response) => this.handleLoadResponse(response))
      .then((json) => {
        if (!this.requestIsCurrent("load", token)) return

        const options = this.normalizeOptions(json)
        this.clearErrorSurface()
        this.dispatch("load", { detail: { query, options } })
        callback(options)
      })
      .catch((error) => {
        if (this.isAbortError(error) || !this.requestIsCurrent("load", token)) return

        this.dispatchRequestError("load-error", "load", { query }, error)
        callback()
      })
      .finally(() => this.finishRequest("load", token))
  }

  handleLoadResponse(response) {
    return response.json().catch(() => ({})).then((json) => {
      if (response.ok) {
        if (this.remoteSearchPayloadIsCollection(json)) return json

        const error = new Error("Rails Fields Kit remote search response must be an array or wrapped array")
        error.response = response
        error.payload = json
        throw error
      }

      const error = new Error("Rails Fields Kit remote search request failed")
      error.response = response
      error.payload = json
      throw error
    })
  }

  loadSelectedOptions() {
    if (!this.hasSelectedUrlValue || !this.tomSelect) return

    const values = this.selectedValuesNeedingOptions()
    if (values.length === 0) return

    this.clearErrorSurface()
    const url = new URL(this.selectedUrlValue, window.location.origin)
    this.appendParams(url, this.selectedQueryParamsValue)
    if (values.length === 1) {
      url.searchParams.set(this.selectedParamValue, values[0])
    } else {
      url.searchParams.set(this.selectedMultipleParamValue, values.join(","))
    }

    const { signal, token } = this.beginRequest("selected-load")

    fetch(url.toString(), this.requestOptions({
      headers: { Accept: "application/json" }
    }, signal))
      .then((response) => this.handleSelectedResponse(response))
      .then((json) => {
        if (!this.requestIsCurrent("selected-load", token)) return

        this.applySelectedOptions(json, values)
      })
      .catch((error) => {
        if (this.isAbortError(error) || !this.requestIsCurrent("selected-load", token)) return

        this.dispatchRequestError("selected-load-error", "selected-load", { values }, error)
      })
      .finally(() => this.finishRequest("selected-load", token))
  }

  handleSelectedResponse(response) {
    return response.json().catch(() => ({})).then((json) => {
      if (response.ok) return json

      const error = new Error("Rails Fields Kit selected preload request failed")
      error.response = response
      error.payload = json
      throw error
    })
  }

  selectedValuesNeedingOptions() {
    return this.selectedValues().filter((value) => this.hasPresentValue(value) && !this.tomSelect.options[value])
  }

  selectedValues() {
    const value = this.tomSelect.getValue()
    return Array.isArray(value) ? value : [value]
  }

  selectionDetail(value, extra = {}) {
    return {
      value,
      ...extra,
      values: this.selectedValues(),
      option: this.optionForValue(value),
      options: this.selectedOptions()
    }
  }

  selectedOptions() {
    return this.selectedValues().map((value) => this.optionForValue(value))
  }

  optionForValue(value) {
    if (Array.isArray(value) || !this.hasPresentValue(value) || !this.tomSelect || !this.tomSelect.options) return null

    return this.tomSelect.options[value] || null
  }

  applySelectedOptions(json, requestedValues = []) {
    const options = this.normalizeSelectedOptions(json).filter((option) => this.optionHasValue(option))
    const valueField = this.optionValueField()

    options.forEach((option) => {
      this.tomSelect.addOption(option)
      this.tomSelect.addItem(option[valueField], true)
    })
    this.tomSelect.refreshOptions(false)
    this.clearErrorSurface()
    this.dispatch("selected-load", { detail: { options, values: requestedValues } })
  }

  normalizeSelectedOptions(json) {
    if (Array.isArray(json)) return json
    if (json && Array.isArray(json.options)) return json.options
    if (json && Array.isArray(json.results)) return json.results
    if (json && this.hasOwnProperty(json, "option")) return [json.option]
    if (json) return [json]

    return []
  }

  createOption(input, callback) {
    this.clearErrorSurface()
    const { signal, token } = this.beginRequest("create")

    fetch(this.createUrlValue, this.requestOptions({
      method: "POST",
      headers: this.createRequestHeaders(),
      body: JSON.stringify({ ...this.createParamsValue, [this.createParamValue]: input })
    }, signal))
      .then((response) => this.handleCreateResponse(response))
      .then((json) => {
        if (!this.requestIsCurrent("create", token)) return

        const option = this.normalizeCreatedOption(json)
        this.clearErrorSurface()
        if (option) this.dispatch("create", { detail: { input, option } })
        callback(option)
      })
      .catch((error) => {
        if (this.isAbortError(error) || !this.requestIsCurrent("create", token)) return

        this.dispatchRequestError("create-error", "create", { input }, error)
        callback(false)
      })
      .finally(() => this.finishRequest("create", token))
  }

  createRequestHeaders() {
    const headers = {
      Accept: "application/json",
      "Content-Type": "application/json"
    }
    const csrfToken = this.csrfToken()

    if (csrfToken) headers["X-CSRF-Token"] = csrfToken

    return headers
  }

  handleCreateResponse(response) {
    return response.json().catch(() => ({})).then((json) => {
      if (response.ok) return json

      const error = new Error("Rails Fields Kit create request failed")
      error.response = response
      error.payload = json
      throw error
    })
  }

  dispatchRequestError(eventName, operation, context, error) {
    const response = error.response || null
    const payload = error.payload ?? null
    const status = response ? response.status : null
    const surface = this.errorSurfaceElement()

    this.markErrorSurface(surface, { operation, status })

    this.dispatch(eventName, {
      detail: {
        operation,
        ...context,
        error,
        response,
        payload,
        status,
        surface
      }
    })
  }

  errorSurfaceElement() {
    if (!this.hasErrorSurfaceIdValue) return null

    return document.getElementById(this.errorSurfaceIdValue)
  }

  markErrorSurface(surface, { operation, status }) {
    if (!surface) return

    surface.hidden = false
    surface.dataset.rfkErrorState = "error"
    surface.dataset.rfkErrorOperation = operation
    if (status === null || status === undefined) {
      delete surface.dataset.rfkErrorStatus
    } else {
      surface.dataset.rfkErrorStatus = String(status)
    }
  }

  clearErrorSurface() {
    const surface = this.errorSurfaceElement()
    if (!surface) return

    surface.hidden = true
    delete surface.dataset.rfkErrorState
    delete surface.dataset.rfkErrorOperation
    delete surface.dataset.rfkErrorStatus
    surface.textContent = ""
  }

  appendParams(url, params = {}) {
    Object.entries(params).forEach(([key, value]) => {
      if (Array.isArray(value)) {
        value.forEach((item) => url.searchParams.append(key, item))
      } else if (value !== null && value !== undefined) {
        url.searchParams.set(key, value)
      }
    })
  }

  remoteSearchPayloadIsCollection(json) {
    return Array.isArray(json) || (json && Array.isArray(json.options)) || (json && Array.isArray(json.results))
  }

  normalizeOptions(json) {
    if (Array.isArray(json)) return json
    if (json && Array.isArray(json.options)) return json.options
    if (json && Array.isArray(json.results)) return json.results

    return []
  }

  normalizeCreatedOption(json) {
    const option = json && this.hasOwnProperty(json, "option") ? json.option : json

    return this.optionHasValue(option) ? option : false
  }

  optionHasValue(option) {
    return Boolean(
      option &&
        typeof option === "object" &&
        !Array.isArray(option) &&
        this.hasPresentValue(option[this.optionValueField()])
    )
  }

  optionValueField() {
    return this.valueFieldValue || "value"
  }

  hasOwnProperty(object, property) {
    return Object.prototype.hasOwnProperty.call(object, property)
  }

  renderText(value, fallback) {
    return this.hasPresentValue(value) ? value : fallback
  }

  hasPresentValue(value) {
    return value !== null && value !== undefined && value !== ""
  }

  displayValue(value) {
    return this.hasPresentValue(value) ? String(value) : ""
  }

  csrfToken() {
    const element = document.querySelector("meta[name='csrf-token']")
    return element && element.content
  }

  escape(value) {
    const div = document.createElement("div")
    div.textContent = this.displayValue(value)
    return div.innerHTML
  }
}
