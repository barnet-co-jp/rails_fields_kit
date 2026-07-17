# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select controller source" do
  let(:source) { File.read(File.expand_path("../../app/javascript/rails_fields_kit/tom_select_controller.js", __dir__)) }

  it "announces no-results state through a polite status region" do
    expect(source).to include('no_results: () => `<div class="no-results" role="status" aria-live="polite" aria-atomic="true">${this.escape(this.renderText(this.noResultsTextValue, "No results found"))}</div>`')
  end

  it "announces loading state through a polite status region" do
    expect(source).to include('loading: () => `<div class="loading" role="status" aria-live="polite" aria-atomic="true">${this.escape(this.renderText(this.loadingTextValue, "Loading..."))}</div>`')
  end

  it "escapes rich option renderer content before rendering it" do
    expect(source).to include("const label = escape(this.optionLabel(data))")
    expect(source).to include('if (this.hasPresentValue(badge)) parts.push(`<span class="rfk-option-badge">${escape(this.displayValue(badge))}</span>`)')
    expect(source).to include('if (this.hasPresentValue(description)) parts.push(`<div class="rfk-option-description">${escape(this.displayValue(description))}</div>`)')
    expect(source).to include('option_create: (data, escape) => `<div class="create">${escape(this.renderText(this.createTextValue, "Add"))} <strong>${escape(data.input)}</strong></div>`')
  end

  it "falls back missing render text values without overriding present values" do
    expect(source).to include("renderText(value, fallback) {")
    expect(source).to include("return this.hasPresentValue(value) ? value : fallback")
  end

  it "falls back missing option labels to the option value for display only" do
    expect(source).to include("optionLabel(data) {")
    expect(source).to include("const label = data[this.labelFieldValue]")
    expect(source).to include("if (this.hasPresentValue(label)) return this.displayValue(label)")
    expect(source).to include("return this.displayValue(data[this.valueFieldValue])")
    expect(source).to include('this.tomSelect.addItem(option[valueField], true)')
  end

  it "dispatches remote search success with query and options" do
    expect(source).to include('this.dispatch("load", { detail: { query, options } })')
  end

  it "keeps remote search empty collections distinct from invalid success payloads" do
    expect(source).to include("if (this.remoteSearchPayloadIsCollection(json)) return json")
    expect(source).to include('new Error("Rails Fields Kit remote search response must be an array or wrapped array")')
    expect(source).to include("remoteSearchPayloadIsCollection(json) {")
    expect(source).to include("Array.isArray(json) || (json && Array.isArray(json.options)) || (json && Array.isArray(json.results))")
  end

  it "appends fixed query params before adding the remote search query" do
    expect(source).to include('this.appendParams(url, this.queryParamsValue)')
    expect(source).to include('url.searchParams.set(this.queryParamValue, query)')
  end

  it "keeps fixed request params falsy-aware and array-friendly" do
    expect(source).to include("appendParams(url, params = {}) {")
    expect(source).to include("if (Array.isArray(value)) {")
    expect(source).to include("value.forEach((item) => url.searchParams.append(key, item))")
    expect(source).to include("} else if (value !== null && value !== undefined) {")
    expect(source).to include("url.searchParams.set(key, value)")
  end

  it "dispatches selected preload success with requested values and resolved options" do
    expect(source).to include('this.dispatch("selected-load", { detail: { options, values: requestedValues } })')
  end

  it "keeps selected preload success limited to usable option payloads" do
    expect(source).to include("const options = this.normalizeSelectedOptions(json).filter((option) => this.optionHasValue(option))")
    expect(source).to include("const valueField = this.optionValueField()")
    expect(source).to include('this.dispatch("selected-load", { detail: { options, values: requestedValues } })')
    expect(source).to include('this.dispatchRequestError("selected-load-error", "selected-load", { values }, error)')
  end

  it "uses the configured value field as the option value guard source" do
    expect(source).to include("optionHasValue(option) {")
    expect(source).to include("!Array.isArray(option)")
    expect(source).to include("this.hasPresentValue(option[this.optionValueField()])")
    expect(source).to include("optionValueField() {")
    expect(source).to include('return this.valueFieldValue || "value"')
    expect(source).to include("this.tomSelect.addItem(option[valueField], true)")
  end

  it "appends fixed selected preload params before selected id keys" do
    expect(source).to include('this.appendParams(url, this.selectedQueryParamsValue)')
    expect(source).to include('url.searchParams.set(this.selectedParamValue, values[0])')
    expect(source).to include('url.searchParams.set(this.selectedMultipleParamValue, values.join(","))')
  end

  it "forwards interaction events with stable detail keys" do
    expect(source).to include('this.dispatch("change", { detail: this.selectionDetail(value) })')
    expect(source).to include('this.dispatch("item-add", { detail: this.selectionDetail(value, { item }) })')
    expect(source).to include('this.dispatch("item-remove", { detail: this.selectionDetail(value, { item }) })')
    expect(source).to include('this.dispatch("clear", { detail: { values: this.selectedValues(), options: this.selectedOptions() } })')
    expect(source).to include("selectionDetail(value, extra = {}) {")
    expect(source).to include("option: this.optionForValue(value)")
    expect(source).to include("options: this.selectedOptions()")
  end

  it "dispatches a dedicated create success event with the input and option" do
    expect(source).to include('if (option) this.dispatch("create", { detail: { input, option } })')
  end

  it "merges fixed create params into the create request body" do
    expect(source).to include('body: JSON.stringify({ ...this.createParamsValue, [this.createParamValue]: input })')
  end

  it "keeps request error events on the shared detail shape" do
    expect(source).to include('detail: {')
    expect(source).to include('operation,')
    expect(source).to include('...context,')
    expect(source).to include('error,')
    expect(source).to include('response,')
    expect(source).to include('payload,')
    expect(source).to include('status,')
    expect(source).to include('surface')
  end

  it "routes each request failure through its dedicated event and context" do
    expect(source).to include('this.dispatchRequestError("load-error", "load", { query }, error)')
    expect(source).to include('this.dispatchRequestError("selected-load-error", "selected-load", { values }, error)')
    expect(source).to include('this.dispatchRequestError("create-error", "create", { input }, error)')
  end

  it "tracks request lifecycles so stale callbacks stay on the latest request" do
    expect(source).to include('const { signal, token } = this.beginRequest("load")')
    expect(source).to include('const { signal, token } = this.beginRequest("selected-load")')
    expect(source).to include('const { signal, token } = this.beginRequest("create")')
    expect(source).to include('if (this.isAbortError(error) || !this.requestIsCurrent("load", token)) return')
    expect(source).to include('if (this.isAbortError(error) || !this.requestIsCurrent("selected-load", token)) return')
    expect(source).to include('if (this.isAbortError(error) || !this.requestIsCurrent("create", token)) return')
    expect(source).to include('this.abortAllRequests()')
  end

  it "exposes the opt-in error surface on request failures" do
    expect(source).to include("const surface = this.errorSurfaceElement()")
    expect(source).to include("this.markErrorSurface(surface, { operation, status })")
  end

  it "clears the opt-in error surface when interaction recovers" do
    expect(source).to include("this.clearErrorSurface()")
    expect(source).to include("surface.hidden = true")
    expect(source).to include("surface.textContent = \"\"")
  end
end
