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
- [ ] If the current release adds package-root helper exports, confirm `doc/release_notes_0_1_1.md` mentions the representative helper surface without implying built-in query parsing.

## Documentation

- [ ] Review `README.md`.
- [ ] Review `Product Profile.md`.
- [ ] Review `AGENTS.md`.
- [ ] Review `doc/setup.md`.
- [ ] Review `doc/public_api.md`.
- [ ] Review `doc/select_migration.md`.
- [ ] Review `doc/field_helpers.md`.
- [ ] Review `doc/tom_select_visual_reference.html`.
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
- [ ] If the current release adds package-root helper exports, confirm `doc/setup.md` and `doc/public_api.md` still agree on the representative helper import path and responsibility boundary.
- [ ] Confirm token search and table integration docs still distinguish gem responsibilities from host app responsibilities.

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
- [ ] Confirm selected preload works in edit forms.
- [ ] Confirm create-on-the-fly works.
- [ ] If the current release adds package-root helper exports, confirm `import { readRenderedRansackFilterMetadata } from "rails_fields_kit"` resolves in the sample app.
- [ ] If the current release adds package-root helper exports, confirm a representative table-rendered field returns `{ adapter, paramName, fields }` and a plain `rfk_token_search` field still returns `null`.
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
