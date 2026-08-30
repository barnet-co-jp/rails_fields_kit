# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select FOUC documentation" do
  let(:doc) { File.read(File.expand_path("../doc/styling_boundary.md", __dir__)) }

  it "documents the opt-in host selector and its JavaScript failure trade-off" do
    expect(doc).to include('[data-controller~="rails-fields-kit--tom-select"]:not(.ts-hidden)')
    expect(doc).to include("visibility: hidden")
    expect(doc).to include("original control never receives `ts-hidden` and therefore remains hidden")
  end

  it "keeps FOUC suppression separate from lookup value and label semantics" do
    expect(doc).to include("Do not suppress the lookup flash by replacing the lookup host control's initial value with its display label")
    expect(doc).to include("FOUC suppression is a presentation concern and should not change the value/label contract")
  end
end
