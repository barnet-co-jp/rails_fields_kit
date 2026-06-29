# frozen_string_literal: true

require "spec_helper"

RSpec.describe "request failure event recipes docs" do
  let(:events_path) { File.expand_path("../doc/events.md", __dir__) }
  let(:events) { File.read(events_path) }
  let(:recipe_section) { markdown_section(events, "## Copyable request-failure recipes") }

  it "keeps the host-app recipe wired to current request failure events" do
    expect(recipe_section).to include(
      "rails-fields-kit--tom-select:load-error->customers#remoteSearchFailed",
      "rails-fields-kit--tom-select:selected-load-error->customers#selectedPreloadFailed",
      "rails-fields-kit--tom-select:create-error->customers#createFailed",
      "rails-fields-kit--tom-select:load->customers#clearFeedback",
      "rails-fields-kit--tom-select:selected-load->customers#clearFeedback",
      "rails-fields-kit--tom-select:create->customers#clearFeedback",
      "rails-fields-kit--tom-select:change->customers#clearFeedback"
    )
  end

  it "keeps visible copy and mirrored UI responsibility in the host app" do
    expect(recipe_section).to include(
      "<div data-controller=\"customers\">",
      "error_surface: true",
      "<div data-customers-target=\"feedback\" role=\"status\" aria-live=\"polite\"></div>",
      "if (surface) surface.textContent = message",
      "if (this.hasFeedbackTarget)",
      "message copy, retry controls, analytics, and any extra UI state in the host app",
      "clear any UI outside `detail.surface` from the same success or follow-up hooks",
      "If the app mirrors the same message into another target, that mirror is app-owned state"
    )
  end

  it "does not promote a new request lifecycle or built-in feedback surface" do
    expect(recipe_section).to include(
      "It does not add a request-start event",
      "built-in loading UI",
      "built-in retry UI",
      "toast UI",
      "new payload shape"
    )

    expect(recipe_section).not_to include("rails-fields-kit--tom-select:request-start")
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
