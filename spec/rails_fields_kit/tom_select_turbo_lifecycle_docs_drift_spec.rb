# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select Turbo lifecycle docs drift" do
  let(:setup_doc) { File.read(File.expand_path("../../doc/setup.md", __dir__)) }
  let(:lifecycle_doc) { File.read(File.expand_path("../../doc/tom_select_turbo_lifecycle.md", __dir__)) }
  let(:development_doc) { File.read(File.expand_path("../../doc/development.md", __dir__)) }

  it "keeps setup guidance aligned with Stimulus reconnect behavior" do
    expect(setup_doc).to include(
      "Stimulus `connect()`",
      "should not require a separate host-app `turbo:load` reinitializer",
      "normal `rfk_*` fields"
    )
  end

  it "keeps lifecycle cleanup and request guards visible" do
    expect(lifecycle_doc).to include(
      "`connect()` creates one Tom Select instance",
      "`disconnect()` marks the controller disconnected",
      "aborts in-flight remote requests",
      "destroys the Tom Select instance",
      "request abort and stale-response guards",
      "single Tom Select wrapper"
    )
  end

  it "keeps local and CI JavaScript checks aligned with lifecycle smoke coverage" do
    expect(development_doc).to include(
      "npm run check:js",
      "Tom Select Turbo lifecycle behavior",
      "Tom Select Turbo lifecycle smoke"
    )
  end
end
