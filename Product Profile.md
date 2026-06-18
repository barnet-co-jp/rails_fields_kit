# Product Profile

## What this repository is

Rails Fields Kit is a Ruby gem that gives Rails applications a focused set of form helpers for inputs that are awkward with native HTML alone. Its current center of gravity is Tom Select-backed searchable selects, editable comboboxes, tag inputs, token search inputs, native wrapper helpers, and table-oriented metadata helpers.

## Who it serves

- maintainers of the gem
- Rails application developers integrating searchable form fields
- host apps that want optional metadata bridges to table-oriented gems

## What it should do well

- wrap Tom Select in Rails-friendly helpers for naming, redisplay, validation, and accessibility
- support remote search, selected preload, and create-on-the-fly workflows
- expose stable integration points for controller helpers, token suggestion builders, JavaScript rendered-contract helpers, table metadata, and read-only setup verification
- keep native wrappers such as `rfk_password_field` thin, Rails-friendly, and explicit about host-app-owned behavior
- stay easy to adopt from ordinary Rails forms without taking over the whole frontend stack

## Responsibility boundary

Rails Fields Kit is not a query engine, authorization layer, or table preference persistence layer.

Host applications remain responsible for:

- installing Tom Select in their chosen JavaScript toolchain
- registering Stimulus controllers, choosing the boot file, and deciding the final frontend setup policy
- loading CSS through their chosen frontend setup
- parsing submitted token search text
- building `params[:q]` or equivalent search params
- authorization, scoping, pagination, and result execution
- app-specific success and error UI copy
- password-specific UX such as visibility toggles, strength meters, credential policy, authentication workflow, and credential storage

## Current public surface

- FormBuilder helpers such as `rfk_select`, `rfk_combobox`, `rfk_tags`, `rfk_token_search`, `rfk_password_field`, `rfk_table_filters`, and `rfk_table_cell_editors`
- controller helpers under `RailsFieldsKit::Searchable`
- token suggestion builders including `RailsFieldsKit::TokenSuggestions.build` and `RailsFieldsKit::RansackSuggestions.build`
- table metadata objects including `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer`
- package-root JavaScript exports including `TomSelectController` and rendered-field contract helpers documented in `doc/public_api.md`
- Stimulus events dispatched by `rails-fields-kit--tom-select`
- read-only setup verification through `rails rails_fields_kit:doctor`, which reports initializer and importmap pin visibility plus a representative Stimulus registration advisory signal while leaving Tom Select package install, final Stimulus boot policy, CSS import, and bundler aliases as host-app responsibilities

## Current non-goals

- hiding all Tom Select configuration
- deciding application-specific search semantics
- owning Ransack execution
- choosing the host app's bundler or importmap strategy
- auto-fixing host app setup or frontend toolchain wiring
- replacing dedicated table or search gems
- owning password visibility toggles, strength meters, credential policy, authentication workflow, or credential storage

## Key docs

- `README.md`: public entrypoint and maintained docs map
- `CHANGELOG.md`: released and unreleased user-visible changes, plus the current release-prep baseline
- `AGENTS.md`: repo-specific source-of-truth order, docs-sync expectations, and release-facing review inventory
- `doc/setup.md`: maintained setup walkthrough, including the read-only setup doctor boundary
- `doc/setup_doctor.md`: read-only SetupDoctor report surface for programmatic checks, text evidence, and command behavior boundaries
- `doc/setup_doctor_output_review.md`: focused CLI diagnostic evidence review for setup doctor output, Stimulus registration advisory states, target mismatch readability, and manual-check boundaries
- `doc/support_boundary.md`: supported Ruby / Rails / Node boundaries and representative CI evidence
- `lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md`: generated host-app checklist that should stay pointed back to the maintained docs
- `doc/field_helpers.md` and `doc/controller_helpers.md`: public helper references
- `doc/password_field.md`: focused `rfk_password_field` native wrapper boundary and password-specific non-goals
- `doc/native_numeric_fields.md`: focused `rfk_number_field`, `rfk_money_field`, and `rfk_percent_field` native wrapper boundary and numeric formatting non-goals
- `doc/native_contact_fields.md`: focused `rfk_email_field`, `rfk_url_field`, `rfk_phone_field`, and `rfk_search_field` native wrapper boundary and contact/search ownership non-goals
- `doc/textarea_autosize.md`: focused `rfk_text_area` autosize boundary; autosize remains host-app owned in the current 0.1.x surface
- `doc/textarea_autosize_release_evidence.md`: release and sample-app evidence guide for the current `rfk_text_area` autosize boundary without treating autosize as built-in behavior
- `doc/visual_references.md`: maintained visual reference family map and scope notes
- `doc/visual_reference_index.html`: one-screen reviewer entrypoint for the static visual reference family
- `doc/tom_select_visual_reference.html` and `doc/native_field_visual_reference.html`: static visual references for representative Tom Select-backed and native helper states
- `doc/tom_select_rich_option_review.html`: companion visual reference for Tom Select rich option label, description, and badge density review
- `doc/tom_select_source_fallback_review.html`: focused companion visual reference for explicit `enum:` sources and remote option label fallback display review
- `doc/tom_select_turbo_reconnect_visual_reference.html`: focused companion visual reference for Turbo reconnect behavior review
- `doc/tom_select_no_event_boundary_review.html`: map-only companion visual reference for stale / aborted Tom Select request no-event boundary review
- `doc/tom_select_plugin_clearable_review.html`: map-only companion visual reference for `allow_clear: true`, whole-field clear affordance, and host-owned plugin boundaries
- `doc/tom_select_request_failure_visual_reference.html`: static visual reference for opt-in request-failure feedback and `error_surface: true` lanes
- `doc/tom_select_host_feedback_lifecycle_visual_reference.html`: companion visual reference for host-owned inline feedback and follow-up clearing cues after request-failure events
- `doc/tom_select_error_surface_contract_visual_reference.html`: static visual reference for focused `error_surface: true` live-region contract review
- `doc/native_accessibility_contract_visual_reference.html`: static visual reference for focused native helper accessibility contract reader lanes
- `doc/tom_select_text_override_visual_reference.html`: static visual reference for configured Tom Select text override copy states
- `doc/tom_select_disabled_option_visual_reference.html`: static visual reference for collection-backed disabled option readability and option metadata boundaries
- `doc/configuration_wrapper_class_visual_reference.html`: static visual reference for initializer-driven wrapper class pass-through, narrow viewport review, and host-app CSS ownership boundaries
- `doc/table_metadata_visual_reference.html`: static visual reference for representative table metadata filter and editor lanes
- `doc/token_search_saved_search_visual_reference.html`: static visual reference for saved-search token suggestion states
- `doc/configuration.md`: initializer defaults and override precedence
- `doc/styling_boundary.md`: reader-facing source of truth for wrapper classes, styling hooks, and host-app CSS ownership
- `doc/select_migration.md`: practical `collection_select` to `rfk_select` migration pattern
- `doc/token_suggestions.md` and `doc/ransack_suggestions.md`: token-search suggestion surfaces and host-app responsibility boundary
- `doc/table_adapters.md`: table metadata bridge
- `doc/table_direct_helper_boundary.md`: direct table FormBuilder helper `columns`-only boundary and lower-level render/call-spec lane guidance
- `doc/table_group_html.md`: direct table FormBuilder helper group-level wrapper attributes
- `doc/public_api.md`: intended stable API for 0.1.x
- `doc/package_root_helper_release_evidence.md`: focused release and sample-app evidence guide for package-root rendered-field contract helpers; `doc/public_api.md` remains the source of truth for helper names and return shapes
- `doc/events.md`: Stimulus event contract
- `doc/tom_select_turbo_lifecycle.md`: Turbo and Stimulus connect/disconnect lifecycle boundary for Tom Select-backed helpers
- `doc/development.md`: local checks
- `doc/release.md`, `doc/final_release_checklist.md`, `doc/selected_preload_release_gate.md`, `doc/sample_app_checklist.md`, `doc/sample_app_results.md`, and `doc/release_notes_0_1_1.md`: release-facing maintainer docs and current next-release draft

## Source-of-truth reminder

Use current code first, then current docs and changelog. Treat `ROADMAP.md` as direction-setting material rather than implemented contract.
