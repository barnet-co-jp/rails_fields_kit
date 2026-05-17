import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    kind: String,
    url: String,
    createUrl: String,
    create: Boolean,
    freeText: Boolean,
    placeholder: String,
    queryParam: { type: String, default: "q" },
    createParam: { type: String, default: "text" },
    valueField: { type: String, default: "value" },
    labelField: { type: String, default: "text" },
    searchField: { type: String, default: "text" },
    minLength: { type: Number, default: 0 },
    plugins: Array
  }

  connect() {
    this.tomSelect = new TomSelect(this.element, this.options())
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
      persist: false,
      placeholder: this.placeholderValue || this.element.getAttribute("placeholder") || undefined,
      plugins: this.pluginsValue.length > 0 ? this.pluginsValue : undefined
    }

    if (this.hasUrlValue) {
      options.valueField = this.valueFieldValue
      options.labelField = this.labelFieldValue
      options.searchField = this.searchFields()
      options.shouldLoad = (query) => query.length >= this.minLengthValue
      options.load = (query, callback) => this.loadOptions(query, callback)
    }

    if (this.hasCreateUrlValue) {
      options.create = (input, callback) => this.createOption(input, callback)
    }

    return options
  }

  searchFields() {
    return this.searchFieldValue.split(",").map((field) => field.trim()).filter(Boolean)
  }

  loadOptions(query, callback) {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set(this.queryParamValue, query)

    fetch(url.toString(), {
      headers: { Accept: "application/json" }
    })
      .then((response) => response.ok ? response.json() : [])
      .then((json) => callback(this.normalizeOptions(json)))
      .catch(() => callback())
  }

  createOption(input, callback) {
    fetch(this.createUrlValue, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      body: JSON.stringify({ [this.createParamValue]: input })
    })
      .then((response) => response.ok ? response.json() : null)
      .then((json) => callback(this.normalizeCreatedOption(json, input)))
      .catch(() => callback(this.fallbackOption(input)))
  }

  normalizeOptions(json) {
    if (Array.isArray(json)) return json
    if (json && Array.isArray(json.options)) return json.options
    if (json && Array.isArray(json.results)) return json.results

    return []
  }

  normalizeCreatedOption(json, input) {
    if (json) return json

    return this.fallbackOption(input)
  }

  fallbackOption(input) {
    return {
      [this.valueFieldValue]: input,
      [this.labelFieldValue]: input
    }
  }

  csrfToken() {
    const element = document.querySelector("meta[name='csrf-token']")
    return element && element.content
  }
}
