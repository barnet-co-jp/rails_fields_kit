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

  it "exposes the opt-in error surface on request failures" do
    expect(source).to include("const surface = this.errorSurfaceElement()")
    expect(source).to include("this.markErrorSurface(surface, { operation, status })")
    expect(source).to include("surface")
  end

  it "clears the opt-in error surface when interaction recovers" do
    expect(source).to include("this.clearErrorSurface()")
    expect(source).to include("surface.hidden = true")
    expect(source).to include("surface.textContent = \"\"")
  end
end
