# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "visual reference companion inventory" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:visual_references_path) { File.expand_path("../doc/visual_references.md", __dir__) }
  let(:visual_references) { File.read(visual_references_path) }
  let(:visual_reference_index) { File.read(File.expand_path("../doc/visual_reference_index.html", __dir__)) }

  it "keeps rich option companion review packaged and mapped" do
    expect(specification.files).to include("doc/tom_select_rich_option_review.html")

    expect(visual_references).to include(
      "[`tom_select_rich_option_review.html`](tom_select_rich_option_review.html)",
      "Tom Select rich option review",
      "label, description, and badge readability",
      "endpoint payload shape, option mapping behavior, search execution, production CSS, and authorization outside the static artifact"
    )
  end

  it "keeps allow_clear companion review map-only and packaged" do
    expect(specification.files).to include("doc/tom_select_plugin_clearable_review.html")

    expect(visual_references).to include(
      "[`tom_select_plugin_clearable_review.html`](tom_select_plugin_clearable_review.html)",
      "map-only companion lane",
      "single-select whole-field clear affordance",
      "plugin assets, styling, event payloads, selection mutation, and Tom Select lifecycle behavior outside Rails Fields Kit"
    )
  end

  it "keeps host feedback lifecycle companion review packaged and mapped" do
    expect(specification.files).to include("doc/tom_select_host_feedback_lifecycle_visual_reference.html")

    expect(visual_references).to include(
      "[`tom_select_host_feedback_lifecycle_visual_reference.html`](tom_select_host_feedback_lifecycle_visual_reference.html)",
      "event-driven host feedback lifecycle review",
      "host-owned visible feedback",
      "follow-up clearing cues",
      "retry UI, default copy, or request lifecycle behavior"
    )
  end

  it "keeps no-event boundary companion review map-only and packaged" do
    expect(specification.files).to include("doc/tom_select_no_event_boundary_review.html")

    expect(visual_references).to include(
      "[`tom_select_no_event_boundary_review.html`](tom_select_no_event_boundary_review.html)",
      "map-only companion artifact",
      "stale / aborted no-event states",
      "without promoting request-start / finish events, retry UI, production CSS, or request lifecycle behavior into Rails Fields Kit"
    )
  end

  it "keeps landed focused companions packaged, mapped, and behind the shared index route" do
    companions = {
      "doc/native_password_field_review.html" => {
        map_signals: [
          "[`native_password_field_review.html`](native_password_field_review.html)",
          "Map-only focused companion for the native password wrapper",
          "visibility toggles, strength meters, credential policy, authentication workflow, or production CSS"
        ],
        artifact_signal: "without adding visibility toggles, strength meters, credential policy, authentication workflow, or production styling"
      },
      "doc/native_date_time_color_review.html" => {
        map_signals: [
          "[`native_date_time_color_review.html`](native_date_time_color_review.html)",
          "Map-only focused companion for browser-native date, time, datetime-local, and color wrappers",
          "browser picker UI, timezone conversion, masking, formatting policy, or production CSS"
        ],
        artifact_signal: "browser picker UI, timezone conversion, masking, formatting policy, and production CSS stay outside this artifact"
      },
      "doc/tom_select_class_names_visual_boundary.html" => {
        map_signals: [
          "[`tom_select_class_names_visual_boundary.html`](tom_select_class_names_visual_boundary.html)",
          "Map-only focused companion for Rails Fields Kit wrapper hooks versus Tom Select internal generated-part class names",
          "production CSS, theme presets, dark mode, density policy, or DOM compatibility"
        ],
        artifact_signal: "without approving production CSS, theme presets, density, dark mode, or Tom Select DOM compatibility"
      }
    }

    expect(specification.files).to include(*companions.keys)

    companions.each do |path, signals|
      expect(visual_references).to include(*signals.fetch(:map_signals))
      expect(File.read(File.expand_path("../#{path}", __dir__))).to include(signals.fetch(:artifact_signal))
      expect(visual_reference_index).not_to include(path.delete_prefix("doc/"))
    end

    expect(visual_reference_index).to include(
      "Companion artifact discovery",
      "the one-screen index should stay limited to current primary routes",
      "visual_references.md#reference-map"
    )
  end
end
