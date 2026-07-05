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
- expose stable integration points for controller helpers, token suggestion builders, JavaScript rendered-contract helpers, table metadata, configuration defaults, and read-only setup verification
- keep native wrappers such as `rfk_password_field`, `rfk_file_field`, `rfk_check_box`, `rfk_radio_button`, `rfk_date_field`, and `rfk_color_field` thin, Rails-friendly, and explicit about host-app-owned behavior
- stay easy to adopt from ordinary Rails forms without taking over the whole frontend stack

## Responsibility boundary

Rails Fields Kit is not a query engine, authorization layer, or table preference persistence layer.

Host applications remain responsible for:

- installing Tom Select in their chosen JavaScript toolchain
- registering Stimulus controllers, choosing the boot file, and deciding the final frontend setup policy
- loading CSS through their chosen frontend setup
- installing, enabling, and styling Tom Select plugins such as `clear_button`
- parsing submitted token search text
- building `params[:q]` or equivalent search params
- authorization, scoping, pagination, and result execution
- app-specific success and error UI copy
- password-specific UX such as visibility toggles, strength meters, credential policy, authentication workflow, and credential storage
- date/time/datetime-local/color UX such as timezone conversion, masking, custom picker UI, browser normalization, validation policy, and production styling

## Current public surface

- FormBuilder helpers such as `rfk_select`, `rfk_combobox`, `rfk_tags`, `rfk_token_search`, `rfk_password_field`, `rfk_file_field`, `rfk_check_box`, `rfk_radio_button`, `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, `rfk_color_field`, `rfk_table_filters`, and `rfk_table_cell_editors`
- controller helpers under `RailsFieldsKit::Searchable`
- token suggestion builders including `RailsFieldsKit::TokenSuggestions.build` and `RailsFieldsKit::RansackSuggestions.build`
- table metadata objects including `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer`
- configuration defaults documented in `doc/configuration.md`, including `default_allow_clear` for the semantic Tom Select clear-button default
- package-root JavaScript exports including `TomSelectController` and rendered-field contract helpers documented in `doc/public_api.md`
- Stimulus events dispatched by `rails-fields-kit--tom-select`
- read-only setup verification through `rails rails_fields_kit:doctor` and `RailsFieldsKit::SetupDoctor`, including text evidence, Ruby-facing `checks`, structured JSON representation, generated setup note visibility, and representative Stimulus registration advisory signal, while leaving Tom Select package install, final Stimulus boot policy, CSS import, and bundler aliases as host-app responsibilities; setup note creation, CI pass/fail policy, and auto-fix behavior also remain with the host app

## Current non-goals

- hiding all Tom Select configuration
- deciding application-specific search semantics
- owning Ransack execution
- choosing the host app's bundler or importmap strategy
- auto-fixing host app setup or frontend toolchain wiring
- replacing dedicated table or search gems
- owning password visibility toggles, strength meters, credential policy, authentication workflow, or credential storage
- owning timezone conversion, masking, custom picker UI, browser normalization, validation policy, or production styling for native date/time/datetime-local/color inputs

## Key docs

This inventory is for maintainers who need to find the right source of truth quickly. It is intentionally more complete than the README Docs map, which remains the public first-reader route rather than a full docs inventory.

### First-reader and repo orientation

- `README.md`: public entrypoint and maintained docs map
- `CHANGELOG.md`: released and unreleased user-visible changes, plus the current release-prep baseline
- `AGENTS.md`: repo-specific source-of-truth order, docs-sync expectations, and release-facing review inventory
- `doc/development.md`: local checks
- `doc/support_boundary.md`: supported Ruby / Rails / Node boundaries and representative CI evidence

### Setup and generated host-app notes

- `doc/setup.md`: maintained setup walkthrough, including the read-only setup doctor boundary
- `doc/setup_doctor.md`: read-only SetupDoctor report surface for generated setup note visibility, programmatic checks, text evidence, and command behavior boundaries
- `doc/setup_doctor_machine_readable.md`: structured JSON output guide for SetupDoctor `schema_version`, `summary`, and `checks` payloads, without turning advisory checks into host-app CI policy
- `doc/setup_doctor_output_review.md`: focused CLI diagnostic evidence review for setup doctor output, generated setup note advisory states, Stimulus registration advisory states, target mismatch readability, and manual-check boundaries
- `lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md`: generated host-app checklist that should stay pointed back to the maintained docs

### Public API and behavior sources of truth

- `doc/public_api.md`: intended stable API for 0.1.x
- `doc/field_helpers.md` and `doc/controller_helpers.md`: public helper references
- `doc/configuration.md`: initializer defaults and override precedence
- `doc/default_allow_clear.md`: focused app-wide `allow_clear` default guide; keep `clear_button` plugin installation, styling, empty-state copy, and lifecycle behavior with the host app
- `doc/styling_boundary.md`: reader-facing source of truth for wrapper classes, styling hooks, and host-app CSS ownership
- `doc/tom_select_class_names.md`: focused field-level Tom Select internal `classNames` pass-through guide; keep wrapper customization, production CSS, theme presets, and initializer-level defaults out of this lane
- `doc/dropdown_parent.md`: focused `dropdown_parent:` selector pass-through guide; modal, drawer, portal, z-index, focus, and production CSS ownership stay with the host app
- `doc/events.md`: Stimulus event contract
- `doc/tom_select_turbo_lifecycle.md`: Turbo and Stimulus connect/disconnect lifecycle boundary for Tom Select-backed helpers
- `doc/select_migration.md`, `doc/grouped_select.md`, and `doc/enum_select.md`: focused collection-backed select docs for ordinary Rails select migration, optgroup choices, and enum-backed choices
- `doc/token_suggestions.md` and `doc/ransack_suggestions.md`: token-search suggestion surfaces and host-app responsibility boundary
- `doc/table_adapters.md`: table metadata bridge
- `doc/table_direct_helper_boundary.md`: direct table FormBuilder helper safe-join boundary, optional single outer `group_html:` wrapper, and lower-level render/call-spec lane guidance
- `doc/table_group_html.md`: direct table FormBuilder helper group-level wrapper attributes
- `doc/table_range_field_metadata.md`: focused table metadata guide for `TableFilterInput.range_field` / `TableCellInput.range_field`; range-pair queries, custom sliders, table persistence, Ransack execution, and production styling stay out of scope
- `doc/table_check_box_metadata.md`: focused table metadata guide for `TableFilterInput.check_box` / `TableCellInput.check_box`; boolean query semantics, tri-state filtering, bulk edit, table persistence, and production styling stay out of scope
- `doc/table_radio_button_metadata.md`: focused table metadata guide for `TableFilterInput.radio_button` / `TableCellInput.radio_button`; required `tag_value:`, radio filter query semantics, collection groups, same-name grouping policy, table persistence, and production styling stay out of scope
- `doc/table_file_field_metadata.md`: focused table metadata guide for `TableCellInput.file_field`; file upload execution, preview UI, storage policy, query execution, table persistence, and `TableFilterInput.file_field` stay out of scope

### Helper boundary docs

- `doc/password_field.md`: focused `rfk_password_field` native wrapper boundary and password-specific non-goals
- `doc/file_field.md`: focused `rfk_file_field` native wrapper boundary and file-upload ownership non-goals
- `doc/check_box.md`: focused `rfk_check_box` native wrapper boundary and Rails checkbox contract non-goals
- `doc/radio_button.md`: focused `rfk_radio_button` native wrapper boundary and Rails radio button contract non-goals
- `doc/native_numeric_fields.md`: focused `rfk_number_field`, `rfk_money_field`, and `rfk_percent_field` native wrapper boundary and numeric formatting non-goals
- `doc/native_contact_fields.md`: focused `rfk_email_field`, `rfk_url_field`, `rfk_phone_field`, and `rfk_search_field` native wrapper boundary and contact/search ownership non-goals
- `doc/native_date_time_color_fields.md`: focused `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, and `rfk_color_field` native wrapper boundary and date/time/color ownership non-goals
- `doc/textarea_autosize.md`: focused `rfk_text_area` autosize boundary; autosize remains host-app owned in the current 0.1.x surface

### Proposal-only boundary docs

- `doc/masked_input_boundary.md`: proposal-only boundary for masked inputs; keeps `rfk_masked_field` out of the current public API while pointing host apps to current native wrapper and host-owned masking lanes
- `doc/slug_helper_boundary.md`: proposal-only boundary for title-to-slug workflows; keeps `rfk_slug_field`, slug generation, uniqueness, transliteration, reserved words, validation, and persistence out of the current public API
- `doc/datalist_boundary.md`: proposal-only boundary for HTML datalist support; keeps `rfk_datalist_field` out of the current public API and separates browser-native datalist limits from Tom Select-backed lanes
- `doc/mention_field_boundary.md`: proposal-only boundary for inline textarea mentions; compares current textarea, autocomplete, token-search, and tag lanes without making `rfk_mention_field` current public API

### Visual reference family

- `doc/visual_references.md`: maintained visual reference family map and scope notes
- `doc/visual_reference_index.html`: one-screen reviewer entrypoint for the static visual reference family
- `doc/visual_reference_browser_evidence.md`: manual browser-capable desktop and narrow viewport evidence runbook for static visual reference PRs; CI success and source review are not browser approval
- `doc/tom_select_visual_reference.html` and `doc/native_field_visual_reference.html`: static visual references for representative Tom Select-backed and native helper states
- `doc/native_character_counter_boundary_sample_evidence.html`: map-only native companion evidence for `maxlength` pass-through beside host-owned character counter copy; it does not make `character_counter:` a current helper option
- `doc/native_select_boundary_sample_evidence.html`: map-only native companion artifact for plain native select, grouped optgroup select, and Tom Select-backed collection boundary comparison; remote optgroup endpoints, custom renderers, search execution, authorization, persistence, and production CSS stay out of scope
- `doc/tom_select_rich_option_review.html`: companion visual reference for Tom Select rich option label, description, and badge density review
- `doc/tom_select_source_fallback_review.html`: focused companion visual reference for explicit `enum:` sources and remote option label fallback display review
- `doc/tom_select_turbo_reconnect_visual_reference.html`: focused companion visual reference for Turbo reconnect behavior review
- `doc/tom_select_no_event_boundary_review.html`: map-only companion visual reference for stale / aborted Tom Select request no-event boundary review
- `doc/tom_select_plugin_clearable_review.html`: map-only companion visual reference for `allow_clear: true`, whole-field clear affordance, and host-owned plugin boundaries
- `doc/tom_select_request_failure_visual_reference.html`: static visual reference for opt-in request-failure feedback and `error_surface: true` lanes
- `doc/tom_select_host_feedback_lifecycle_visual_reference.html`: companion visual reference for host-owned inline feedback and follow-up clearing cues after request-failure events
- `doc/tom_select_error_surface_contract_visual_reference.html`: static visual reference for focused `error_surface: true` live-region contract review
- `doc/tom_select_text_override_visual_reference.html`: static visual reference for configured Tom Select text override copy states
- `doc/tom_select_disabled_option_visual_reference.html`: static visual reference for collection-backed disabled option readability and option metadata boundaries
- `doc/dropdown_parent_review.html`: static companion review lane for modal, drawer, and body-mounted `dropdown_parent:` selector ownership; it is not browser positioning approval or production CSS evidence
- `doc/native_accessibility_contract_visual_reference.html`: static visual reference for focused native helper accessibility contract reader lanes
- `doc/configuration_wrapper_class_visual_reference.html`: static visual reference for initializer-driven wrapper class pass-through, narrow viewport review, and host-app CSS ownership boundaries
- `doc/table_metadata_visual_reference.html`: static visual reference for representative table metadata filter and editor lanes
- `doc/token_search_saved_search_visual_reference.html`: static visual reference for saved-search token suggestion states

### Release and evidence docs

- `doc/release.md`, `doc/final_release_checklist.md`, `doc/selected_preload_release_gate.md`, `doc/sample_app_checklist.md`, `doc/sample_app_results.md`, and `doc/release_notes_0_1_1.md`: release-facing maintainer docs and current next-release draft
- `doc/search_controller_release_evidence.md`: release evidence guide for `rfk_search_with minimum_query_length:` and `match:` endpoint policy; keep endpoint behavior in `doc/controller_helpers.md` and host-app search execution out of scope
- `doc/check_box_release_evidence.md`: release and sample-app evidence guide for `rfk_check_box`; keep radio buttons, collection groups, validation UI, label placement redesign, and production CSS out of this lane
- `doc/radio_button_release_evidence.md`: release and sample-app evidence guide for `rfk_radio_button`; keep evidence focused on the single radio wrapper and Rails radio contract, not collection groups, fieldset / legend builders, or group validation UI
- `doc/textarea_autosize_release_evidence.md`: release and sample-app evidence guide for the current `rfk_text_area` autosize boundary without treating autosize as built-in behavior
- `doc/saved_search_token_suggestion_evidence.md`: release and PR evidence guide for `TokenSuggestions.build(saved_searches:)`; keep saved-search parsing, execution, persistence, authorization, sharing policy, and management UI host-app owned
- `doc/package_root_helper_release_evidence.md`: focused release and sample-app evidence guide for package-root rendered-field contract helpers; `doc/public_api.md` remains the source of truth for helper names and return shapes
- `doc/dropdown_parent_release_evidence.md`: focused release and sample-app evidence note for Tom Select-backed `dropdown_parent:` selector pass-through and no-config boundaries without taking over modal, drawer, portal, z-index, or production CSS policy
- `doc/table_metadata_release_evidence.md`: focused release and sample-app evidence guide for table metadata rendering, group-level wrappers, and TableRenderer registry lanes
- `doc/token_table_sample_app_evidence.md`: focused release and PR evidence companion for token search, token suggestions, Ransack suggestion metadata, and table metadata lanes without making parsing, execution, authorization, or table persistence Rails Fields Kit responsibilities
- `doc/sample_app_results_route_guide.md`: recording-lane selector for release-wide sample-app evidence, narrow PR comments, source-only visual reviews, and deferred browser-capable evidence

## Source-of-truth reminder

Use current code first, then current docs and changelog. Treat `ROADMAP.md` as direction-setting material rather than implemented contract.
