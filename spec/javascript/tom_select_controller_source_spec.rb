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
end
