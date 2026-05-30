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
- `doc/tom_select_visual_reference.html`: static visual reference for representative Tom Select-backed states
- `doc/tom_select_text_override_visual_reference.html`: static visual reference for configured Tom Select text override copy states
- `doc/native_field_visual_reference.html`: static visual reference for representative native helper states
- `doc/table_metadata_visual_reference.html`: static visual reference for representative table metadata filter and editor lanes
- `doc/*.md`: maintained public and maintainer-facing docs

## Docs sync rules

- Keep `README.md`, `doc/setup.md`, `doc/public_api.md`, `doc/field_helpers.md`, `doc/controller_helpers.md`, `doc/configuration.md`, `doc/token_suggestions.md`, `doc/ransack_suggestions.md`, `doc/table_adapters.md`, `doc/select_migration.md`, `doc/events.md`, and any affected topic doc aligned when the current public surface changes.
- Do not document roadmap examples as current public API unless the code and `doc/public_api.md` already support them.
- Keep host-app responsibilities explicit. Rails Fields Kit does not own query parsing, authorization, pagination, or the host app's JavaScript package manager setup.
- When setup guidance or docs discoverability changes, sync `README.md`, `doc/setup.md`, `lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md`, and root inventory docs such as `Product Profile.md` when they summarize maintainer-facing entrypoints.
- When helper discoverability or representative UI states change, sync `README.md`, `doc/field_helpers.md`, and any affected static visual reference together.
- When token suggestion, Ransack suggestion, or table metadata behavior changes, sync the related `doc/*.md` reference plus `doc/public_api.md` together.
- When event dispatch, selected preload, or create-on-the-fly behavior changes, sync `doc/events.md`, `doc/sample_app_checklist.md`, and `doc/sample_app_results.md` together.

## Verification

- Prefer `bundle exec standardrb`, `bundle exec rspec`, and `bundle exec rake build` for code changes.
- For docs-only changes, it is acceptable to skip local checks when no runnable checkout is available, but note that clearly in the PR.

## Release-facing docs

Before release-oriented docs updates, review:

- `CHANGELOG.md`
- `doc/release.md`
- `doc/final_release_checklist.md`
- `doc/sample_app_checklist.md`
- `doc/sample_app_results.md`
- the current version-specific release note draft
