# Rails Fields Kit Final Release Checklist

Use this checklist immediately before publishing a gem release.

## Code and tests

- [ ] Pull latest `main`.
- [ ] Run `bundle install`.
- [ ] Run `bundle exec standardrb`.
- [ ] Run `bundle exec rspec`.
- [ ] Run `bundle exec rake build`.
- [ ] Run `BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rspec`.
- [ ] Run `BUNDLE_GEMFILE=gemfiles/rails_8_0.gemfile bundle exec rspec`.
- [ ] Confirm the latest GitHub Actions CI run passed for the release commit.
- [ ] Confirm the latest release-prep pull request passed the representative Rails 7.0 / Ruby 3.1 and Rails 8.0 / Ruby 3.3 compatibility jobs.
- [ ] Confirm the built gem path matches the target version, for example `pkg/rails_fields_kit-x.y.z.gem`.
- [ ] Confirm RubyGems validation warnings are understood or resolved.

## Version, changelog, and release notes

- [ ] Confirm `lib/rails_fields_kit/version.rb` matches the intended release.
- [ ] Confirm `CHANGELOG.md` has an entry for the release version and date.
- [ ] Confirm `CHANGELOG.md` has a fresh `Unreleased` section for the next cycle.
- [ ] Prepare or update `doc/release_notes_0_1_1.md` for the current next-release draft. If release planning chooses a different version number, rename that draft and keep `doc/release_notes_0_1_0.md` as the historical reference.
- [ ] If request-failure placeholder support is part of the release scope, confirm `CHANGELOG.md` and `doc/release_notes_0_1_1.md` mention `error_surface:` / `error_surface_html:` and `event.detail.surface` without implying built-in retry UI.

## Documentation

- [ ] Review `README.md`.
- [ ] Review `Product Profile.md`.
- [ ] Review `AGENTS.md`.
- [ ] Review `doc/setup.md`.
- [ ] Review `doc/public_api.md`.
- [ ] Review `doc/select_migration.md`.
- [ ] Review `doc/field_helpers.md`.
- [ ] Review `doc/tom_select_visual_reference.html`.
- [ ] Review `doc/native_field_visual_reference.html`.
- [ ] Review `doc/table_metadata_visual_reference.html`.
- [ ] Review `doc/controller_helpers.md`.
- [ ] Review `doc/token_suggestions.md`.
- [ ] Review `doc/ransack_suggestions.md`.
- [ ] Review `doc/table_adapters.md`.
- [ ] Review `doc/configuration.md`.
- [ ] Review `doc/events.md`.
- [ ] Review `doc/development.md`.
- [ ] Review `doc/sample_app_checklist.md`.
- [ ] Review `doc/sample_app_results.md`.
- [ ] Review `doc/release.md`.
- [ ] Review `doc/release_notes_0_1_1.md` for the current next-release draft.
- [ ] Confirm `README.md` and `doc/public_api.md` still describe both documented JavaScript import paths: `rails_fields_kit` and `rails_fields_kit/tom_select_controller`.
- [ ] Confirm token search and table integration docs still distinguish gem responsibilities from host app responsibilities.
- [ ] Confirm release-prep docs, `doc/events.md`, and sample app verification all agree on whether create-on-the-fly success uses a dedicated `rails-fields-kit--tom-select:create` hook or only the generic selection events.

## Generated files

- [ ] Run `rails generate rails_fields_kit:install` in a sample app.
- [ ] Confirm `config/initializers/rails_fields_kit.rb` is generated.
- [ ] Confirm `doc/rails_fields_kit_setup.md` is generated.
- [ ] Confirm generated setup notes still point to maintained setup docs and current JavaScript registration expectations.

## Sample app verification

- [ ] Complete `doc/sample_app_results.md`.
- [ ] Confirm the documented JavaScript import paths resolve in the sample app.
- [ ] Confirm Tom Select CSS is loaded.
- [ ] Confirm remote search works.
- [ ] Confirm one representative `rfk_select` lane keeps a server-rendered collection-backed selected value stable through edit-form redisplay or validation rerender, while `include_blank:`, representative `disabled:`, and representative `option_html:` stay aligned with current docs and do not depend on remote search or create-on-the-fly hooks.
- [ ] Confirm one representative clearable `rfk_select` lane can return from a selected value to the documented blank or placeholder state with `allow_clear: true` while staying in the collection-backed single-value contract.
- [ ] Confirm one representative `rfk_autocomplete` lane keeps remote suggestions in the typing-assist role while the submitted value stays free text, without depending on `selected_url:` or create-on-the-fly hooks.
- [ ] Confirm one representative `rfk_multi_select` lane keeps a known collection-backed multiple-value flow, with the submitted value staying an ordinary array of selected IDs or values rather than a tag-entry or free-text creation lane.
- [ ] Confirm one representative `rfk_grouped_select` lane preserves the documented optgroup structure while the submitted value stays an ordinary selected ID or value and does not depend on remote search or create-on-the-fly hooks.
- [ ] Confirm one representative `rfk_enum_select` lane preserves the current enum label and value mapping through edit-form redisplay or validation rerender without drifting into a hand-maintained arbitrary collection lane.
- [ ] Confirm one representative native helper lane keeps `wrapper: true` label / hint / prefix / suffix rendering stable through validation rerender, and that a comparable `accessibility: false` example clearly drops the shared automatic wiring.
- [ ] Confirm one representative native helper customization lane preserves field-level `wrapper_html:` / `label_html:` / `hint_html:` / `error_html:` / `control_html:` / `prefix_html:` / `suffix_html:` attributes while `html:` remains scoped to the input element and label / hint / error `aria-describedby` wiring plus error wrapper state stay aligned with `doc/field_helpers.md`.
- [ ] Confirm selected preload works in edit forms.
- [ ] Confirm one representative selected preload lane covers saved-ID label restore, `rails-fields-kit--tom-select:selected-load`, `rails-fields-kit--tom-select:selected-load-error`, and any host-app fallback or `error_surface:` boundary together.
- [ ] Confirm one representative multi-value selected preload lane restores visible labels for saved IDs and still uses the documented `selected_multiple_param:` or comma-separated `ids` contract when the endpoint relies on it.
- [ ] Confirm create-on-the-fly works.
- [ ] Confirm create-on-the-fly success dispatched `rails-fields-kit--tom-select:create` before the normal selection events when that hook is part of the release surface.
- [ ] Confirm `event.detail.input` and `event.detail.option` exposed the expected payload for the representative create success flow.
- [ ] Confirm one representative create-on-the-fly failure lane covers `rails-fields-kit--tom-select:create-error`, host-app fallback or retry UI, and any `error_surface:` boundary together.
- [ ] Confirm request-failure events expose `event.detail.surface` when `error_surface:` is part of the release surface.
- [ ] Confirm at least one representative `error_surface_html:` lane keeps its custom class or wrapper attrs without losing the shared placeholder `id`, hidden default, `role`, `aria-live`, or `aria-atomic` contract.
- [ ] Confirm one representative Turbo reconnect lane covers page replacement or same-form revisit without duplicate Tom Select initialization, confirms pending load / selected-load / create requests are aborted or ignored on disconnect, and verifies selected preload or remote search still works after reconnect without a host-app reinitializer.
- [ ] Confirm visible success UI remained a host-app responsibility rather than a built-in Rails Fields Kit surface.
- [ ] Confirm visible error or retry UI around any opt-in `error_surface:` placeholder remained a host-app responsibility.
- [ ] Confirm token search and token suggestion endpoints are covered if they are part of the release surface.
- [ ] Confirm table metadata helpers or call-spec rendering paths are covered if they are part of the release surface.
- [ ] Confirm validation and authorization failures return expected status codes.

## Publishing

- [ ] Confirm RubyGems MFA is available.
- [ ] Confirm `allowed_push_host` is `https://rubygems.org`.
- [ ] Run `bundle exec rake release` only when ready.
- [ ] Confirm the published gem is visible on RubyGems.
- [ ] Create a GitHub Release using the version-specific release note draft if desired.

## Post-release

- [ ] Start the next development cycle in `CHANGELOG.md`.
- [ ] Prepare the next release note draft as needed.
- [ ] Record any sample app findings as issues or follow-up tasks.
