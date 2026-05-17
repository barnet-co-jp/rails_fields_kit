# Rails Fields Kit Final Release Checklist

Use this checklist immediately before publishing a gem release.

## Code and tests

- [ ] Pull latest `main`.
- [ ] Run `bundle install`.
- [ ] Run `bundle exec rspec`.
- [ ] Run `bundle exec rake build`.
- [ ] Confirm the built gem path, for example `pkg/rails_fields_kit-0.1.0.gem`.
- [ ] Confirm RubyGems validation warnings are understood or resolved.

## Version and changelog

- [ ] Confirm `lib/rails_fields_kit/version.rb` matches the intended release.
- [ ] Confirm `CHANGELOG.md` has an entry for the release version and date.
- [ ] Confirm `CHANGELOG.md` has a fresh `Unreleased` section.

## Documentation

- [ ] Review `README.md`.
- [ ] Review `doc/setup.md`.
- [ ] Review `doc/public_api.md`.
- [ ] Review `doc/field_helpers.md`.
- [ ] Review `doc/controller_helpers.md`.
- [ ] Review `doc/configuration.md`.
- [ ] Review `doc/events.md`.
- [ ] Review `doc/sample_app_checklist.md`.
- [ ] Review `doc/sample_app_results.md`.
- [ ] Review `doc/release_notes_0_1_0.md`.

## Generated files

- [ ] Run `rails generate rails_fields_kit:install` in a sample app.
- [ ] Confirm `config/initializers/rails_fields_kit.rb` is generated.
- [ ] Confirm `doc/rails_fields_kit_setup.md` is generated.
- [ ] Confirm generated setup notes mention `selected_url:` and `rfk_find_with`.

## Sample app verification

- [ ] Complete `doc/sample_app_results.md`.
- [ ] Confirm JavaScript import works.
- [ ] Confirm Tom Select CSS is loaded.
- [ ] Confirm remote search works.
- [ ] Confirm selected preload works in edit forms.
- [ ] Confirm create-on-the-fly works.
- [ ] Confirm validation and authorization failures return expected status codes.

## Publishing

- [ ] Confirm RubyGems MFA is available.
- [ ] Confirm `allowed_push_host` is `https://rubygems.org`.
- [ ] Run `bundle exec rake release` only when ready.
- [ ] Confirm the published gem is visible on RubyGems.
- [ ] Create a GitHub Release using `doc/release_notes_0_1_0.md` if desired.

## Post-release

- [ ] Start the next development cycle in `CHANGELOG.md`.
- [ ] Record any sample app findings as issues or follow-up tasks.
