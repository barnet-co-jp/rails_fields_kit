import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    kind: String,
    url: String,
    selectedUrl: String,
    createUrl: String,
    queryParams: Object,
    selectedQueryParams: Object,
    createParams: Object,
    create: Boolean,
    freeText: Boolean,
    placeholder: String,
    queryParam: { type: String, default: "q" },
    selectedParam: { type: String, default: "id" },
    selectedMultipleParam: { type: String, default: "ids" },
    createParam: { type: String, default: "text" },
    valueField: { type: String, default: "value" },
    labelField: { type: String, default: "text" },
    searchField: { type: String, default: "text" },
    minLength: { type: Number, default: 0 },
    maxOptions: Number,
    maxItems: Number,
    loadThrottle: Number,
    delimiter: String,
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
    plugins: Array
  }

  connect() {
    this.tomSelect = new TomSelect(this.element, this.options())
    this.bindTomSelectEvents()
    this.loadSelectedOptions()
  }

  disconnect() {
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

    if (this.hasMaxOptionsValue) options.maxOptions = this.maxOptionsValue
    if (this.hasMaxItemsValue) options.maxItems = this.maxItemsValue
    if (this.hasLoadThrottleValue) options.loadThrottle = this.loadThrottleValue
    if (this.hasDelimiterValue) options.delimiter = this.delimiterValue
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
      this.dispatch("change", { detail: { value, values: this.selectedValues() } })
    })
    this.tomSelect.on("item_add", (value, item) => {
      this.dispatch("item-add", { detail: { value, item, values: this.selectedValues() } })
    })
    this.tomSelect.on("item_remove", (value, item) => {
      this.dispatch("item-remove", { detail: { value, item, values: this.selectedValues() } })
    })
    this.tomSelect.on("clear", () => {
      this.dispatch("clear", { detail: { values: this.selectedValues() } })
    })
  }

  renderers() {
    return {
      option: (data, escape) => this.optionTemplate(data, escape, "option"),
      item: (data, escape) => this.optionTemplate(data, escape, "item"),
      no_results: () => `<div class="no-results" role="status" aria-live="polite" aria-atomic="true">${this.escape(this.noResultsTextValue)}</div>`,
      loading: () => `<div class="loading" role="status" aria-live="polite" aria-atomic="true">${this.escape(this.loadingTextValue)}</div>`,
      option_create: (data, escape) => `<div class="create">${escape(this.createTextValue)} <strong>${escape(data.input)}</strong></div>`
    }
  }

  optionTemplate(data, escape, kind) {
    const label = escape(data[this.labelFieldValue] || "")
    const description = this.hasOptionDescriptionFieldValue ? data[this.optionDescriptionFieldValue] : null
    const badge = this.hasOptionBadgeFieldValue ? data[this.optionBadgeFieldValue] : null
    const parts = [`<div class="rfk-${kind}">`]

    parts.push("<div class=\"rfk-option-main\">")
    parts.push(`<span class="rfk-option-label">${label}</span>`)
    if (badge) parts.push(`<span class="rfk-option-badge">${escape(badge)}</span>`)
    parts.push("</div>")
    if (description) parts.push(`<div class="rfk-option-description">${escape(description)}</div>`)
    parts.push("</div>")

    return parts.join("")
  }

  searchFields() {
    return this.searchFieldValue.split(",").map((field) => field.trim()).filter(Boolean)
  }

  loadOptions(query, callback) {
    const url = new URL(this.urlValue, window.location.origin)
    this.appendParams(url, this.queryParamsValue)
    url.searchParams.set(this.queryParamValue, query)

    fetch(url.toString(), {
      headers: { Accept: "application/json" }
    })
      .then((response) => this.handleLoadResponse(response))
      .then((json) => {
        const options = this.normalizeOptions(json)
        this.dispatch("load", { detail: { query, options } })
        callback(options)
      })
      .catch((error) => {
        this.dispatchRequestError("load-error", "load", { query }, error)
        callback()
      })
  }

  handleLoadResponse(response) {
    return response.json().catch(() => ({})).then((json) => {
      if (response.ok) return json

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

    const url = new URL(this.selectedUrlValue, window.location.origin)
    this.appendParams(url, this.selectedQueryParamsValue)
    if (values.length === 1) {
      url.searchParams.set(this.selectedParamValue, values[0])
    } else {
      url.searchParams.set(this.selectedMultipleParamValue, values.join(","))
    }

    fetch(url.toString(), {
      headers: { Accept: "application/json" }
    })
      .then((response) => this.handleSelectedResponse(response))
      .then((json) => this.applySelectedOptions(json, values))
      .catch((error) => {
        this.dispatchRequestError("selected-load-error", "selected-load", { values }, error)
      })
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
    return this.selectedValues().filter((value) => value && !this.tomSelect.options[value])
  }

  selectedValues() {
    const value = this.tomSelect.getValue()
    return Array.isArray(value) ? value : [value]
  }

  applySelectedOptions(json, requestedValues = []) {
    const options = this.normalizeSelectedOptions(json)
    options.forEach((option) => {
      this.tomSelect.addOption(option)
      this.tomSelect.addItem(option[this.valueFieldValue], true)
    })
    this.tomSelect.refreshOptions(false)
    this.dispatch("selected-load", { detail: { options, values: requestedValues } })
  }

  normalizeSelectedOptions(json) {
    if (Array.isArray(json)) return json
    if (json && Array.isArray(json.options)) return json.options
    if (json && Array.isArray(json.results)) return json.results
    if (json && json.option) return [json.option]
    if (json) return [json]

    return []
  }

  createOption(input, callback) {
    fetch(this.createUrlValue, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      body: JSON.stringify({ ...this.createParamsValue, [this.createParamValue]: input })
    })
      .then((response) => this.handleCreateResponse(response))
      .then((json) => callback(this.normalizeCreatedOption(json)))
      .catch((error) => {
        this.dispatchRequestError("create-error", "create", { input }, error)
        callback(false)
      })
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

    this.dispatch(eventName, {
      detail: {
        operation,
        ...context,
        error,
        response,
        payload,
        status
      }
    })
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

  normalizeOptions(json) {
    if (Array.isArray(json)) return json
    if (json && Array.isArray(json.options)) return json.options
    if (json && Array.isArray(json.results)) return json.results

    return []
  }

  normalizeCreatedOption(json) {
    if (json && json.option) return json.option
    if (json) return json

    return false
  }

  csrfToken() {
    const element = document.querySelector("meta[name='csrf-token']")
    return element && element.content
  }

  escape(value) {
    const div = document.createElement("div")
    div.textContent = value || ""
    return div.innerHTML
  }
}
