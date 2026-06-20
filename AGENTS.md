# AGENTS

## Repo role

You are working in `rails_fields_kit`, a Rails 7/8 form helper gem for inputs that remain awkward with native HTML fields alone.

## Source of truth

1. Current code in `lib/`, `app/javascript/`, generators, and tests
2. Current public docs in `README.md` and `doc/*.md`
3. `CHANGELOG.md` for released and unreleased user-visible behavior
4. `ROADMAP.md` for proposals and future directions, not implemented contract

When `ROADMAP.md` and the code disagree, treat the roadmap as a proposal rather than current behavior.

## Primary areas

- `lib/rails_fields_kit/form_builder.rb`: public `rfk_*` helpers
- `app/javascript/rails_fields_kit/tom_select_controller.js`: Stimulus and Tom Select integration, including event dispatch
- `lib/rails_fields_kit/searchable.rb`: controller-side search, find, create, and token suggestion helpers
- `lib/rails_fields_kit/table_*`: table metadata and renderer support
- `lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md`: generated host-app setup note
- `doc/support_boundary.md`: supported Ruby / Rails / Node boundaries and representative CI evidence
- `doc/setup_doctor.md`: read-only SetupDoctor report surface for `checks`, `report_lines`, `run(io:)`, and host-app-owned setup policy boundaries
- `doc/setup_doctor_machine_readable.md`: structured JSON output guide for SetupDoctor `schema_version`, `summary`, and `checks` payloads; keep host-app CI pass/fail policy and auto-fix behavior out of this doc
- `doc/setup_doctor_output_review.md`: focused setup doctor CLI diagnostic evidence review for `[OK]`, `[MISSING]`, `[MANUAL]`, and importmap target mismatch scanability
- `doc/package_root_helper_release_evidence.md`: release and sample-app evidence guide for package-root rendered-field contract helpers; keep `doc/public_api.md#javascript-exports` as the helper list and return-shape source of truth
- `doc/table_metadata_release_evidence.md`: release and sample-app evidence guide for table metadata rendering, group-level wrappers, and TableRenderer registry lanes
- `doc/visual_references.md`: maintained map for the static visual reference family and each artifact's scope
- `doc/visual_reference_index.html`: static index for choosing the right visual reference artifact during design or release review
- `doc/tom_select_visual_reference.html`: static visual reference for representative Tom Select-backed states
- `doc/tom_select_rich_option_review.html`: companion visual reference for Tom Select rich option label, description, and badge density review
- `doc/tom_select_source_fallback_review.html`: focused companion visual reference for explicit `enum:` sources and remote option label fallback display review
- `doc/tom_select_turbo_reconnect_visual_reference.html`: focused companion visual reference for Turbo reconnect appearance and duplicate-wrapper caution review
- `doc/tom_select_no_event_boundary_review.html`: map-only companion visual reference for stale / aborted Tom Select request no-event boundary review
- `doc/tom_select_disabled_option_visual_reference.html`: focused visual reference for collection-backed disabled option readability and option metadata boundaries
- `doc/tom_select_plugin_clearable_review.html`: map-only companion visual reference for `allow_clear: true`, whole-field clear affordance, and host-owned plugin boundaries
- `doc/tom_select_request_failure_visual_reference.html`: static visual reference for opt-in request-failure feedback, operation/status metadata, and `error_surface: true` lanes
- `doc/tom_select_host_feedback_lifecycle_visual_reference.html`: companion visual reference for host-owned inline feedback and follow-up clearing cues after request-failure events
- `doc/tom_select_error_surface_contract_visual_reference.html`: static visual reference for focused `error_surface: true` live-region contract states and wrapper customization boundaries
- `doc/tom_select_text_override_visual_reference.html`: static visual reference for configured Tom Select text override copy states
- `doc/native_field_visual_reference.html`: static visual reference for representative native helper states
- `doc/native_numeric_fields.md`: focused `rfk_number_field`, `rfk_money_field`, and `rfk_percent_field` native wrapper boundary; formatting, rounding, currency, and masking stay host-app owned
- `doc/native_contact_fields.md`: focused `rfk_email_field`, `rfk_url_field`, `rfk_phone_field`, and `rfk_search_field` native wrapper boundary; validation wording, normalization, phone policy, and search execution stay host-app owned
- `doc/mention_field_boundary.md`: proposal-only boundary for inline textarea mentions; keep `rfk_mention_field`, overlay behavior, hidden metadata, authorization, persistence, and mention-specific endpoint contracts out of the current public API until accepted
- `doc/native_accessibility_contract_visual_reference.html`: static visual reference for focused native helper accessibility contract reader lanes
- `doc/configuration_wrapper_class_visual_reference.html`: static visual reference for initializer-driven wrapper class pass-through and host-app CSS ownership boundaries
- `doc/table_metadata_visual_reference.html`: static visual reference for representative table metadata filter and editor lanes
- `doc/table_direct_helper_boundary.md`: direct `rfk_table_filters(columns)` / `rfk_table_cell_editors(columns)` boundary for columns-only safe-join output versus lower-level render/call-spec lanes
- `doc/token_search_saved_search_visual_reference.html`: static visual reference for saved-search token suggestion states
- `doc/tom_select_turbo_lifecycle.md`: maintained Turbo and Stimulus lifecycle boundary for Tom Select-backed helpers
- `doc/*.md`: maintained public and maintainer-facing docs

## Docs sync rules

- Keep `README.md`, `doc/setup.md`, `doc/support_boundary.md`, `doc/public_api.md`, `doc/field_helpers.md`, `doc/controller_helpers.md`, `doc/configuration.md`, `doc/token_suggestions.md`, `doc/ransack_suggestions.md`, `doc/table_adapters.md`, `doc/select_migration.md`, `doc/events.md`, `doc/tom_select_turbo_lifecycle.md`, and any affected topic doc aligned when the current public surface or support boundary changes.
- Do not document roadmap examples as current public API unless the code and `doc/public_api.md` already support them.
- Keep host-app responsibilities explicit. Rails Fields Kit does not own query parsing, authorization, pagination, or the host app's JavaScript package manager setup.
- When setup guidance or docs discoverability changes, sync `README.md`, `doc/setup.md`, `lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md`, and root inventory docs such as `Product Profile.md` when they summarize maintainer-facing entrypoints.
- When helper discoverability or representative UI states change, sync `README.md`, `doc/field_helpers.md`, and any affected static visual reference together.
- When token suggestion, Ransack suggestion, or table metadata behavior changes, sync the related `doc/*.md` reference plus `doc/public_api.md` together.
- When event dispatch, selected preload, create-on-the-fly behavior, or Tom Select lifecycle behavior changes, sync `doc/events.md`, `doc/tom_select_turbo_lifecycle.md`, `doc/sample_app_checklist.md`, and `doc/sample_app_results.md` together.

## Verification

- Prefer `bundle exec standardrb`, `bundle exec rspec`, and `bundle exec rake build` for code changes.
- For docs-only changes, it is acceptable to skip local checks when no runnable checkout is available, but note that clearly in the PR.

## Release-facing docs

Before release-oriented docs updates, review:

- `CHANGELOG.md`
- `doc/support_boundary.md`
- `doc/release.md`
- `doc/final_release_checklist.md`
- `doc/selected_preload_release_gate.md`
- `doc/package_root_helper_release_evidence.md`: focused release and sample-app evidence guide for package-root rendered-field contract helpers
- `doc/table_metadata_release_evidence.md`: focused release and sample-app evidence guide for table metadata rendering, group-level wrappers, and TableRenderer registry lanes
- `doc/sample_app_checklist.md`
- `doc/sample_app_results.md`
- `doc/release_notes_0_1_1.md`: current version-specific release note draft; update this bullet when the maintained current release note moves to a new version file
- `doc/release_notes_0_1_0.md`: historical release note reference kept in the packaged docs map
- `doc/table_direct_helper_boundary.md` when table metadata direct helper layout or lower-level render/call-spec boundaries are part of the release surface
