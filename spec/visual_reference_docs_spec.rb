# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "visual reference documentation drift" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:repo_agents_path) { File.expand_path("../AGENTS.md", __dir__) }
  let(:repo_agents) { File.read(repo_agents_path) }
  let(:product_profile_path) { File.expand_path("../Product Profile.md", __dir__) }
  let(:product_profile) { File.read(product_profile_path) }
  let(:visual_references_path) { File.expand_path("../doc/visual_references.md", __dir__) }
  let(:visual_references) { File.read(visual_references_path) }
  let(:styling_boundary_path) { File.expand_path("../doc/styling_boundary.md", __dir__) }
  let(:styling_boundary) { File.read(styling_boundary_path) }
  let(:development_path) { File.expand_path("../doc/development.md", __dir__) }
  let(:development) { File.read(development_path) }
  let(:public_api_path) { File.expand_path("../doc/public_api.md", __dir__) }
  let(:public_api) { File.read(public_api_path) }

  it "keeps the root maintainer docs aligned with the maintained docs inventory" do
    expect(repo_agents).to include(
      "- `lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md`: generated host-app setup note",
      "- `doc/tom_select_visual_reference.html`: static visual reference for representative Tom Select-backed states",
      "- `doc/native_field_visual_reference.html`: static visual reference for representative native helper states",
      "sync `README.md`, `doc/setup.md`, `lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md`, and root inventory docs such as `Product Profile.md`",
      "sync `README.md`, `doc/field_helpers.md`, and any affected static visual reference together."
    )
    expect(product_profile).to include(
      "- `README.md`: public entrypoint and maintained docs map",
      "- `lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md`: generated host-app checklist that should stay pointed back to the maintained docs",
      "- `doc/visual_references.md`: maintained visual reference family map and scope notes",
      "- `doc/visual_reference_index.html`: one-screen reviewer entrypoint for the static visual reference family",
      "- `doc/tom_select_visual_reference.html` and `doc/native_field_visual_reference.html`: static visual references for representative Tom Select-backed and native helper states",
      "- `doc/tom_select_request_failure_visual_reference.html`: static visual reference for opt-in request-failure feedback and `error_surface: true` lanes"
    )
  end

  it "keeps the visual reference family map aligned with packaged static artifacts" do
    visual_reference_paths = [
      "doc/visual_reference_index.html",
      "doc/tom_select_visual_reference.html",
      "doc/tom_select_source_fallback_review.html",
      "doc/tom_select_turbo_reconnect_visual_reference.html",
      "doc/tom_select_request_failure_visual_reference.html",
      "doc/tom_select_error_surface_contract_visual_reference.html",
      "doc/tom_select_text_override_visual_reference.html",
      "doc/tom_select_disabled_option_visual_reference.html",
      "doc/native_field_visual_reference.html",
      "doc/native_accessibility_contract_visual_reference.html",
      "doc/configuration_wrapper_class_visual_reference.html",
      "doc/table_metadata_visual_reference.html",
      "doc/token_search_saved_search_visual_reference.html"
    ]

    expect(specification.files).to include("doc/visual_references.md", *visual_reference_paths)
    expect(product_profile).to include("- `doc/visual_references.md`: maintained visual reference family map and scope notes")

    visual_reference_paths.each do |path|
      link = path.delete_prefix("doc/")
      expect(product_profile).to include("`#{path}`")
      expect(visual_references).to include("[`#{link}`](#{link})")
    end
  end

  it "keeps the no-event boundary companion artifact map-only and packaged" do
    expect(specification.files).to include("doc/tom_select_no_event_boundary_review.html")
    expect(visual_references).to include(
      "[`tom_select_no_event_boundary_review.html`](tom_select_no_event_boundary_review.html)",
      "map-only companion artifact",
      "stale / aborted no-event states",
      "without promoting request-start / finish events, retry UI, production CSS, or request lifecycle behavior into Rails Fields Kit"
    )
  end

  it "keeps landed Tom Select companion artifacts map-only and packaged" do
    companion_artifacts = {
      "doc/tom_select_rich_option_review.html" => [
        "companion to the core Tom Select reference",
        "label, description, and badge readability",
        "endpoint payload shape, option mapping behavior, search execution, production CSS, and authorization outside"
      ],
      "doc/tom_select_host_feedback_lifecycle_visual_reference.html" => [
        "after the focused request-failure reference",
        "host-owned visible feedback",
        "retry UI, default copy, or request lifecycle behavior"
      ]
    }

    expect(specification.files).to include(*companion_artifacts.keys)

    companion_artifacts.each do |path, signals|
      link = path.delete_prefix("doc/")
      expect(visual_references).to include("[`#{link}`](#{link})")
      signals.each { |signal| expect(visual_references).to include(signal) }
    end
  end

  it "keeps styling boundary docs aligned with public and visual reference roles" do
    expect(specification.files).to include("doc/styling_boundary.md")
    expect(public_api).to include(
      "Rails Fields Kit owns the wrapper, hint, error, affix, and accessibility wiring around that input",
      "production CSS",
      "remain host-app responsibility"
    )
    expect(visual_references).to include(
      "[`styling_boundary.md`](styling_boundary.md) as the reader-facing source of truth for host-app CSS ownership and wrapper hook responsibilities",
      "[`configuration_wrapper_class_visual_reference.html`](configuration_wrapper_class_visual_reference.html) only as the rendered-state review lane",
      "rather than treating the visual artifact as production CSS approval"
    )
    expect(styling_boundary).to include(
      "reader-facing source of truth for wrapper classes and host-app CSS ownership",
      "## Current styling hooks",
      "`rfk-field`",
      "`rfk-control`",
      "Rails Fields Kit owns these pieces",
      "Host apps own these pieces",
      "Production CSS, CSS framework integration, theme tokens, dark mode, density, spacing, and responsive layout policy",
      "not a full helper markup inventory, design system catalog, CSS preset, visual approval checklist, or release evidence log"
    )
    expect(development).to include(
      "The styling boundary documentation drift spec keeps `doc/styling_boundary.md`, `doc/visual_references.md`, and `doc/public_api.md` aligned"
    )
  end
end
