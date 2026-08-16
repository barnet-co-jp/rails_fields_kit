# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select error events" do
  let(:controller_source) do
    File.read(File.expand_path("../../app/javascript/rails_fields_kit/tom_select_controller.js", __dir__))
  end

  let(:events_doc) do
    File.read(File.expand_path("../../doc/events.md", __dir__))
  end

  it "dispatches a shared error detail contract for each request type" do
    expect(controller_source).to include('this.dispatchRequestError("load-error", "load", { query }, error)')
    expect(controller_source).to include('this.dispatchRequestError("selected-load-error", "selected-load", { values }, error)')
    expect(controller_source).to include('this.dispatchRequestError("create-error", "create", { input }, error)')
  end

  it "includes response metadata and the opt-in surface in the shared error detail helper" do
    expect(controller_source).to include("const response = error.response || null")
    expect(controller_source).to include("const payload = error.payload ?? null")
    expect(controller_source).to include("const status = response ? response.status : null")
    expect(controller_source).to include("const surface = this.errorSurfaceElement()")
    expect(controller_source).to include("operation,")
    expect(controller_source).to include("response,")
    expect(controller_source).to include("payload,")
    expect(controller_source).to include("status,")
    expect(controller_source).to include("surface")
  end

  it "documents the normalized failure event detail shape" do
    expect(events_doc).to include("Common error detail fields:")
    expect(events_doc).to include("`operation`: request type (`load`, `selected-load`, `create`)")
    expect(events_doc).to include("`surface`: opt-in placeholder element when `error_surface: true` is enabled, otherwise `null`")
    expect(events_doc).to include("Detail: `{ operation, query, error, response, payload, status, surface }`")
    expect(events_doc).to include("Detail: `{ operation, values, error, response, payload, status, surface }`")
    expect(events_doc).to include("Detail: `{ operation, input, error, response, payload, status, surface }`")
  end
end