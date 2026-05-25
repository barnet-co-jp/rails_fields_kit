# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select controller source" do
  let(:source) { File.read(File.expand_path("../../app/javascript/rails_fields_kit/tom_select_controller.js", __dir__)) }

  it "announces no-results state through a polite status region" do
    expect(source).to include('no_results: () => `<div class="no-results" role="status" aria-live="polite" aria-atomic="true">${this.escape(this.noResultsTextValue)}</div>`')
  end

  it "announces loading state through a polite status region" do
    expect(source).to include('loading: () => `<div class="loading" role="status" aria-live="polite" aria-atomic="true">${this.escape(this.loadingTextValue)}</div>`')
  end

  it "dispatches remote search success with query and options" do
    expect(source).to include('this.dispatch("load", { detail: { query, options } })')
  end

  it "appends fixed query params before adding the remote search query" do
    expect(source).to include('this.appendParams(url, this.queryParamsValue)')
    expect(source).to include('url.searchParams.set(this.queryParamValue, query)')
  end

  it "dispatches selected preload success with requested values and resolved options" do
    expect(source).to include('this.dispatch("selected-load", { detail: { options, values: requestedValues } })')
  end

  it "appends fixed selected preload params before selected id keys" do
    expect(source).to include('this.appendParams(url, this.selectedQueryParamsValue)')
    expect(source).to include('url.searchParams.set(this.selectedParamValue, values[0])')
    expect(source).to include('url.searchParams.set(this.selectedMultipleParamValue, values.join(","))')
  end

  it "forwards interaction events with stable detail keys" do
    expect(source).to include('this.dispatch("change", { detail: { value, values: this.selectedValues() } })')
    expect(source).to include('this.dispatch("item-add", { detail: { value, item, values: this.selectedValues() } })')
    expect(source).to include('this.dispatch("item-remove", { detail: { value, item, values: this.selectedValues() } })')
    expect(source).to include('this.dispatch("clear", { detail: { values: this.selectedValues() } })')
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
    expect(source).to include('status')
  end

  it "routes each request failure through its dedicated event and context" do
    expect(source).to include('this.dispatchRequestError("load-error", "load", { query }, error)')
    expect(source).to include('this.dispatchRequestError("selected-load-error", "selected-load", { values }, error)')
    expect(source).to include('this.dispatchRequestError("create-error", "create", { input }, error)')
  end
end
