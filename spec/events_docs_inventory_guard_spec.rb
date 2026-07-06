# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "events docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:development) { read_doc("doc/development.md") }
  let(:events) { read_doc("doc/events.md") }

  it "keeps the request-failure error surface recipe packaged without promoting feedback UI ownership" do
    expect(specification.files).to include("doc/events.md")

    expect(public_api).to include(
      "Tom Select-backed `rfk_*` helpers also support opt-in `error_surface:`",
      "request-failure events described in [`events.md`](events.md) can include that placeholder as `detail.surface`",
      "visible error copy and retry UI remain host-app responsibility"
    )

    expect(development).to include(
      "request lifecycle and event payloads",
      "error-surface metadata",
      "rendered text and option semantics checks"
    )

    expect(events).to include(
      "When a field is rendered with `error_surface: true`, the controller also includes `detail.surface` on request-failure events",
      "pass an explicit `error_surface_html: { id: \"...\" }` for each field instance",
      "data-rfk-error-state=\"error\"",
      "data-rfk-error-operation=\"load\", `\"selected-load\"`, or `\"create\"`",
      "data-rfk-error-status` when an HTTP status is available",
      "They do not make Rails Fields Kit responsible for visible message text, retry UI, loading UI, or endpoint policy",
      "This recipe intentionally uses only the current `load-error`, `selected-load-error`, and `create-error` hooks",
      "It does not add a request-start event, built-in loading UI, built-in retry UI, toast UI, or a new payload shape",
      "Keep the field helper responsible for wiring the existing events, and keep message copy, retry controls, analytics, and any extra UI state in the host app"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
