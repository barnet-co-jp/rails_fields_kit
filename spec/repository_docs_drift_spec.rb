# frozen_string_literal: true

require "json"
require "spec_helper"

RSpec.describe "repository docs drift guards" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:configuration_source) { read_repo_file("lib/rails_fields_kit/configuration.rb") }
  let(:searchable_source) { read_repo_file("lib/rails_fields_kit/searchable.rb") }
  let(:configuration_doc) { read_repo_file("doc/configuration.md") }
  let(:configuration_profiles) { read_repo_file("doc/configuration_profiles.md") }
  let(:controller_helpers_doc) { read_repo_file("doc/controller_helpers.md") }
  let(:events_doc) { read_repo_file("doc/events.md") }
  let(:support_boundary) { read_repo_file("doc/support_boundary.md") }
  let(:development_doc) { read_repo_file("doc/development.md") }
  let(:readme) { read_repo_file("README.md") }
  let(:roadmap) { read_repo_file("ROADMAP.md") }
  let(:public_api_doc) { read_repo_file("doc/public_api.md") }
  let(:datalist_boundary) { read_repo_file("doc/datalist_boundary.md") }
  let(:mention_boundary) { read_repo_file("doc/mention_field_boundary.md") }
  let(:visual_references_doc) { read_repo_file("doc/visual_references.md") }
  let(:gemspec) { read_repo_file("rails_fields_kit.gemspec") }
  let(:package_metadata) { JSON.parse(read_repo_file("package.json")) }
  let(:ci_workflow) { read_repo_file(".github/workflows/ci.yml") }

  it "keeps support boundary docs aligned with gem, package, and CI version signals" do
    ruby_requirement = gemspec.match(/spec\.required_ruby_version = "([^"]+)"/)[1]
    rails_requirements = gemspec.match(/spec\.add_dependency "rails", "([^"]+)", "([^"]+)"/).captures
    node_boundary = package_metadata.fetch("engines").fetch("node")
    workflow_node_versions = ci_workflow.match(/node-version:\s+\[([^\]]+)\]/)[1].scan(/"([^"]+)"/).flatten
    expected_node_versions = node_boundary.scan(/\d+/).uniq
    rails_matrix_rows = ci_workflow.scan(/rails: "([^"]+)"\n\s+ruby-version: "([^"]+)"\n\s+gemfile: ([^\n]+)/)
    expected_rails_matrix_rows = [
      ["7.0", "3.1", "gemfiles/rails_7_0.gemfile"],
      ["8.0", "3.3", "gemfiles/rails_8_0.gemfile"]
    ]

    expect(support_boundary).to include("- Ruby: `#{ruby_requirement}`")
    expect(support_boundary).to include("- Rails: `#{rails_requirements[0]}`, `#{rails_requirements[1]}`")
    expect(support_boundary).to include("The package metadata boundary is Node #{node_boundary}")
    expect(development_doc).to include("The package metadata boundary is Node #{node_boundary}")
    expect(workflow_node_versions).to eq(expected_node_versions)
    expect(rails_matrix_rows).to eq(expected_rails_matrix_rows)

    rails_matrix_rows.each do |rails_version, ruby_version, gemfile|
      expect(support_boundary).to include("| #{rails_version} | #{ruby_version} | `#{gemfile}` |")
      expect(development_doc).to include(
        "Rails #{rails_version} on Ruby #{ruby_version}",
        "BUNDLE_GEMFILE=#{gemfile} bundle exec rspec"
      )
    end

    expect(development_doc).to include(
      "support_boundary.md",
      "rails_fields_kit.gemspec",
      "package.json",
      ".github/workflows/ci.yml"
    )
    expect(support_boundary).to include(
      "representative CI coverage, not a separate host-app setup step or a full Rails/Ruby support matrix",
      "not a Tom Select runtime support policy for host applications"
    )
  end

  it "keeps configuration profile examples on current initializer keys without promoting profiles to API" do
    configuration_keys = configuration_source.match(/attr_accessor(?<body>.*?)\n\n/m)[:body].scan(/:([a-z_]+)/).flatten
    profile_keys = configuration_profiles.scan(/config\.([a-z_]+)\s*=/).flatten.uniq

    expect(profile_keys).not_to be_empty
    expect(profile_keys - configuration_keys).to eq([])

    profile_keys.each do |configuration_key|
      expect(configuration_doc).to include("`#{configuration_key}`")
    end

    expect(configuration_doc).to include(
      "[`configuration_profiles.md`](configuration_profiles.md)",
      "docs-only patterns, not named profiles, preset APIs, generator options, or design system policy owned by the gem"
    )
    expect(configuration_profiles).to include(
      "does not ship named initializer profiles",
      "starting points for app-owned configuration",
      "not presets, modes, or design system policy owned by the gem",
      "avoid a Ruby profile API, generator option, or preset registry"
    )
  end

  it "keeps controller helper keyword options represented in controller helper docs" do
    signature = searchable_source.match(/def rfk_search_with\((?<signature>[^\n]+)\)/)[:signature]
    documented_options = controller_helpers_doc
      .match(/### Common options\n\n(?<section>.*?)(?:\n### |\n## )/m)[:section]
      .scan(/`([a-z_]+):`/)
      .flatten

    expected_common_options = %w[
      action model value label search query_param limit minimum_query_length scope order distinct wrap
    ]

    expect(signature.scan(/([a-z_]+):/).flatten).to include(*expected_common_options)
    expect(documented_options).to include(*expected_common_options)
    expect(controller_helpers_doc).to include(
      "minimum_query_length: 1",
      "minimum_query_length:` endpoint-side minimum query length",
      "FormBuilder's field-level `min_length:` is a browser-side loading hint",
      "endpoint-side relation helpers, not request-parameter sanitizers"
    )
    expect(development_doc).to include(
      "remote request option documentation drift spec",
      "controller helper keyword options"
    )
  end

  it "keeps controller helper workflow chooser and option alignment boundaries visible" do
    workflow_chooser = markdown_top_level_section(controller_helpers_doc, "## Remote workflow chooser")

    expect(workflow_chooser).to include(
      "Remote search",
      "Selected preload",
      "Create-on-the-fly",
      "Token suggestions",
      "Rails Fields Kit formats option JSON and wires the rendered field to the endpoint",
      "host app still owns authentication, authorization, tenant scoping, query parsing, result execution, and persistence policy",
      "Scan by workflow first, then match the rendered field option to the controller helper",
      "field-helper chooser"
    )

    expect(workflow_chooser).to include(
      "selected_param: \"customer_id\"",
      "rfk_find_with id_param: :customer_id",
      "create_param: \"name\"",
      "rfk_create_with create_param: \"name\"",
      "If a field also uses `create_params:`, read those values as outgoing create JSON body fields",
      "permitted_attributes:` or trusted server-owned values through `assign:`",
      "[`field_helpers.md`](field_helpers.md)",
      "this page focuses on endpoint responsibilities"
    )
  end

  it "keeps request-failure recipes and host feedback boundaries represented in docs" do
    request_failure_recipe = markdown_top_level_section(events_doc, "## Copyable request-failure recipes")
    choosing_the_right_hook = markdown_top_level_section(events_doc, "## Choosing the right hook")
    visual_feedback_lanes = markdown_section(visual_references_doc, "### Request-failure and host-feedback lanes")
    field_helpers_doc = read_repo_file("doc/field_helpers.md")
    shared_feedback_options = markdown_section(field_helpers_doc, "### Shared request-failure feedback options")
    styling_boundary = read_repo_file("doc/styling_boundary.md")

    expect(events_doc).to include(
      "When a field is rendered with `error_surface: true`, the controller also includes `detail.surface` on request-failure events",
      "visible message text, retry UI, loading UI, or endpoint policy",
      "Rails Fields Kit does not dispatch a separate request-start event or render built-in loading, retry, or fallback UI"
    )

    expect(request_failure_recipe).to include(
      "rails-fields-kit--tom-select:load-error->customers#remoteSearchFailed",
      "rails-fields-kit--tom-select:selected-load-error->customers#selectedPreloadFailed",
      "rails-fields-kit--tom-select:create-error->customers#createFailed",
      "current `load-error`, `selected-load-error`, and `create-error` hooks",
      "It does not add a request-start event, built-in loading UI, built-in retry UI, toast UI, or a new payload shape",
      "message copy, retry controls, analytics, and any extra UI state in the host app"
    )

    expect(choosing_the_right_hook).to include(
      "Use `load-error`, `selected-load-error`, or `create-error` when the app wants visible error UI, retry UI, or logging",
      "Use `detail.surface` with `error_surface: true` when the app wants a stable placeholder next to the field without replacing the controller",
      "Keep visible feedback in the host app. Rails Fields Kit only dispatches the events."
    )

    expect(field_helpers_doc).to include(
      "### Shared request-failure feedback options",
      "Request-failure feedback for any Tom Select-backed helper",
      "Keep the chosen helper and opt into `error_surface:`.",
      "[Shared request-failure feedback options](#shared-request-failure-feedback-options)"
    )
    expect(shared_feedback_options).to include(
      "exposes the element as `event.detail.surface` on request-failure events documented in [`events.md`](events.md)",
      "[`tom_select_request_failure_visual_reference.html`](tom_select_request_failure_visual_reference.html)",
      "[`tom_select_host_feedback_lifecycle_visual_reference.html`](tom_select_host_feedback_lifecycle_visual_reference.html)",
      "they do not add built-in retry UI, default copy, request lifecycle timing, or production CSS to Rails Fields Kit"
    )
    expect(styling_boundary).to include(
      "Request-failure placeholders use `rfk-tom-select-error-surface`",
      "visible copy, reveal timing, retry UI, and styling remain host-app responsibilities"
    )

    expect(visual_feedback_lanes).to include(
      "tom_select_request_failure_visual_reference.html",
      "tom_select_host_feedback_lifecycle_visual_reference.html",
      "keeping retry copy, reveal timing, and request lifecycle behavior with the host app",
      "host-owned inline feedback, `detail.surface` placement, and follow-up clearing cues"
    )
  end

  it "keeps README as a docs route map and public API docs as the exact inventory" do
    expect(readme).to include(
      "Use this map as a first reader route, not a full documentation inventory",
      "keep proposal-only boundaries in `doc/*_boundary.md` until they become current public API",
      "This README is a route map. Do not treat the representative helper-family table below as the full package-root export inventory"
    )

    expect(public_api_doc).to include(
      "Use the sections below for the exact public names",
      "this file is the compact public API index",
      "Use [`table_adapters.md`](table_adapters.md) as the source of truth for examples, custom renderer registry setup, and the difference between built-in factory types and custom renderable mappings",
      "Keep the package-root table in this document as the helper inventory source of truth, and keep README, setup, and generated setup notes as routing guidance rather than mirrors of every helper export"
    )
  end

  it "keeps package-root-only contract readers off inferred direct subpath routes" do
    public_api_import_patterns = markdown_section(public_api_doc, "### Import patterns")

    expect(public_api_import_patterns).to include(
      "Direct helper subpath imports are supported only for helper files that `package.json` exports",
      "Prefer package-root imports for normal rendered-field contract helper use",
      "Direct helper subpaths are setup and troubleshooting routes for explicit host-app pins or bundler aliases"
    )

    expect(public_api_import_patterns).to include(
      "The package-root-only readers `readRenderedTomSelectInteractionConfig`, `readRenderedOptionPayloadMapping`, and `readRenderedTableFilterMetadata` intentionally stay on the `rails_fields_kit` package-root route in this 0.1.x surface",
      "do not infer direct subpaths for them unless a future issue explicitly expands the direct helper subpath policy"
    )

    root_only_readers = %w[
      readRenderedTomSelectInteractionConfig
      readRenderedOptionPayloadMapping
      readRenderedTableFilterMetadata
    ]

    root_only_readers.each do |reader_name|
      expect(public_api_import_patterns).to include(reader_name)
      expect(package_metadata.fetch("exports").keys).not_to include("./#{reader_name.gsub(/([a-z])([A-Z])/, "\\1_\\2").downcase}")
    end
  end

  it "keeps representative focused docs discoverable from the public API index without promoting proposals" do
    expect(public_api_doc).to include(
      "[`native_date_time_color_fields.md`](native_date_time_color_fields.md)",
      "[`native_numeric_fields.md`](native_numeric_fields.md)",
      "[`native_contact_fields.md`](native_contact_fields.md)",
      "[`controller_helpers.md`](controller_helpers.md)",
      "[`token_suggestions.md`](token_suggestions.md)",
      "[`ransack_suggestions.md`](ransack_suggestions.md)",
      "[`events.md`](events.md)"
    )

    expect(readme).to include(
      "Rails Fields Kit does not currently provide collection group helpers",
      "do not treat `rfk_mention_field` as part of the current public API"
    )
    expect(public_api_doc).to include(
      "Collection checkbox / radio group helpers are also not current public APIs",
      "Proposal or open-PR helper names are not current public API until they are merged and listed in the table above"
    )
  end

  it "keeps datalist and mention boundary docs packaged without promoting proposal helpers" do
    expect(gemspec).to include('"doc/**/*.md"')

    expect(readme).to include(
      "[`doc/datalist_boundary.md`](doc/datalist_boundary.md) only when comparing the current native wrapper and Tom Select-backed lanes with those future proposals",
      "[`doc/mention_field_boundary.md`](doc/mention_field_boundary.md) when comparing the current `rfk_text_area`, autocomplete, token search, and tag lanes with that future proposal"
    )
    expect(roadmap).to include(
      "`doc/mention_field_boundary.md` is the current proposal boundary for textarea mention workflows",
      "`doc/datalist_boundary.md` is the current proposal boundary for HTML datalist support",
      "Current support stays in `rfk_text_field list:` plus host-owned `<datalist>` markup"
    )

    expect(datalist_boundary).to include(
      "does not add `rfk_datalist_field` to the current public API",
      "The submitted value is just `params[:model][:city]`",
      "host-owned `<datalist>` markup",
      "Do not add `rfk_datalist_field` to `doc/public_api.md`",
      "remote search, selected preload, selected IDs, hidden metadata"
    )
    expect(mention_boundary).to include(
      "does not currently provide a textarea mention helper",
      "proposal boundary, not an implemented API contract",
      "kept out of `visual_references.md`, `visual_reference_index.html`, release evidence, and `public_api.md`",
      "parsing textarea content into mention tokens",
      "authorization and scoping for suggestion endpoints"
    )

    expect(public_api_doc).not_to include("rfk_datalist_field")
    expect(public_api_doc).not_to include("rfk_mention_field")
  end

  def read_repo_file(path)
    File.read(File.join(root, path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?#?\s)/, 2).first
  end

  def markdown_top_level_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##\s)/, 2).first
  end
end
