# Rails Fields Kit Development

This document summarizes the local development checks and how they relate to GitHub Actions.

## Support boundary

For the current host-app Ruby / Rails boundary and the repository-local Node check boundary, see [`support_boundary.md`](support_boundary.md). Keep that page aligned with `rails_fields_kit.gemspec`, `package.json`, and `.github/workflows/ci.yml` when version metadata or CI coverage changes.

## Install dependencies

```bash
bundle install
```

## Lint locally

```bash
bundle exec standardrb
```

## Test locally

```bash
bundle exec rspec
```

The RSpec suite includes Node-sandbox checks for the documented `rails_fields_kit` and `rails_fields_kit/tom_select_controller` entrypoints, plus Tom Select request-lifecycle behavior, so public import-path wiring drift and stale-request regressions are caught alongside the Ruby-side contract specs.

It also includes a lightweight repository-local documentation link check for `README.md` and `doc/**/*.{md,html}`. The check verifies relative file targets only; external URLs and in-page anchors are intentionally outside its scope.

Representative compatibility checks are also useful before review or release:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rspec
BUNDLE_GEMFILE=gemfiles/rails_8_0.gemfile bundle exec rspec
```

## Check JavaScript locally

The JavaScript syntax check uses Node 22.x, matching `package.json` and the GitHub Actions `javascript` job.

```bash
npm run check:js
```

This command checks the public package entrypoint and Tom Select controller source without installing additional npm dependencies. It also runs lightweight Node sandbox checks for package `exports` import wiring and the Tom Select create-on-the-fly JSON request headers, stubbing external browser dependencies so the package root and direct controller entrypoint are resolved through the same public import paths CI uses.

The package export smoke derives package-root named-export expectations from the JavaScript exports table in `doc/public_api.md` and fails if those documented exports are missing from the package root. Helper-specific assertions stay limited to representative contract checks, so adding a new documented package-root helper should not require updating a second fixed export list in the smoke script.

The create request header smoke keeps the existing create-on-the-fly contract visible: JSON `Accept` / `Content-Type` headers are always sent, and a Rails CSRF meta token is copied to `X-CSRF-Token` when present without requiring one in non-Rails or test-only DOMs.

## Build locally

```bash
bundle exec rake build
```

These are the primary local checks for branch-ready work:

- `bundle exec standardrb`
- `bundle exec rspec`
- `npm run check:js`
- `bundle exec rake build`

When build fails, check these first:

- `rails_fields_kit.gemspec` metadata URLs
- missing files in `specification.files`
- generator template paths
- documentation paths referenced from README
- RubyGems warnings about metadata, licenses, or required Ruby version

## GitHub Actions confirmation

Run the local checks first during active development. When the branch head is ready for review or release, also confirm the latest GitHub Actions CI run is green for that exact commit.

Current CI adds these repository-level confirmations on top of the local workflow above:

- `bundle exec standardrb`
- `bundle exec rspec`
- Representative PR compatibility checks for Rails 7.0 on Ruby 3.1 and Rails 8.0 on Ruby 3.3
- `npm run check:js` on Node 22.x for the JavaScript syntax, package exports import lane, and Tom Select create request header smoke
- gem build, install, and `require "rails_fields_kit"` smoke checks

## Release-related checks

Before release, also review:

- `CHANGELOG.md`
- `doc/release.md`
- `doc/final_release_checklist.md`
- `rails_fields_kit.gemspec`
- `lib/rails_fields_kit/version.rb`