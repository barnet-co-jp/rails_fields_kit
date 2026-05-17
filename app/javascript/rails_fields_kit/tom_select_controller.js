import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    kind: String,
    url: String,
    createUrl: String,
    create: Boolean,
    freeText: Boolean,
    placeholder: String
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
      placeholder: this.placeholderValue || this.element.getAttribute("placeholder") || undefined
    }

    if (this.hasUrlValue) {
      options.valueField = "value"
      options.labelField = "text"
      options.searchField = ["text"]
      options.load = (query, callback) => this.loadOptions(query, callback)
    }

    if (this.hasCreateUrlValue) {
      options.create = (input, callback) => this.createOption(input, callback)
    }

    return options
  }

  loadOptions(query, callback) {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("q", query)

    fetch(url.toString(), {
      headers: { Accept: "application/json" }
    })
      .then((response) => response.ok ? response.json() : [])
      .then((json) => callback(json))
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
      body: JSON.stringify({ text: input })
    })
      .then((response) => response.ok ? response.json() : null)
      .then((json) => callback(json || { value: input, text: input }))
      .catch(() => callback({ value: input, text: input }))
  }

  csrfToken() {
    const element = document.querySelector("meta[name='csrf-token']")
    return element && element.content
  }
}
