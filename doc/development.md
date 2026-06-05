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

It also guards bundled locale packaging for the Tom Select render text defaults. Keep `config/locales/en.yml`, `config/locales/ja.yml`, the gemspec file list, and the `RailsFieldsKit::FormBuilder` I18n keys aligned when adding or renaming bundled copy.

It also includes a lightweight repository-local documentation link check for `README.md` and `doc/**/*.{md,html}`. The check verifies relative file targets only; external URLs and in-page anchors are intentionally outside its scope.

The visual reference documentation drift spec keeps `doc/visual_references.md`, `doc/visual_reference_index.html`, and the README Docs map aligned. The README check intentionally points at the maintained visual reference family map and representative family wording instead of every individual HTML artifact, so new artifact families should update the Markdown map, HTML index, and README summary together without freezing the README sentence verbatim.

The configuration documentation drift spec compares `RailsFieldsKit::Configuration` public initializer keys with `doc/configuration.md` quick reference rows and detailed headings. Keep new configuration keys, field-level override notes, and stable nil / locale-aware default boundaries aligned there when the initializer surface changes.

The repository documentation drift spec covers two narrow repository-maintenance boundaries: generated setup notes upstream links must point at existing repository docs, and `doc/support_boundary.md` must stay aligned with the Ruby / Rails / Node version values declared in gem metadata, package metadata, and representative CI rows. This check is intentionally not a full README Docs map mirror or an external URL validator.

The setup example documentation drift spec keeps the JavaScript setup signals in `README.md` and `doc/setup.md` aligned for package-root imports, direct controller imports, bundler aliases, and importmap pins without freezing the full prose.

The suggestion payload documentation drift spec keeps `TokenSuggestions` and `RansackSuggestions` docs aligned with representative option payload keys, custom output field names, and Ransack metadata keys without freezing full examples or prose.

The FormBuilder helper inventory docs spec keeps the compact helper list in `doc/public_api.md` aligned with detailed helper sections in `doc/field_helpers.md`, while checking only representative README chooser entries so the README can stay concise instead of becoming an exhaustive API mirror.

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

This command checks the public package entrypoint and Tom Select controller source without installing additional npm dependencies. It first runs the JavaScript smoke inventory guard, then runs lightweight Node sandbox checks for package `exports` import wiring, Tom Select fixed query params append behavior, Tom Select forwarded interaction event payloads, Tom Select create-on-the-fly JSON request headers and success response normalization, Tom Select error-surface metadata, Tom Select Turbo lifecycle behavior, Tom Select label fallback rendering, Tom Select render text fallback rendering, Tom Select plugin contract reading, and selected preload config reading, stubbing external browser dependencies so the package root and direct controller entrypoint are resolved through the same public import paths CI uses.

The smoke inventory guard derives CI-owned smoke candidates from `scripts/check_*.mjs` and compares them with the repository-local `scripts/check_javascript.mjs` runner. New JavaScript smoke scripts are expected to run through `npm run check:js` unless they are intentionally standalone; in that rare case, add the script path to the documented allowlist inside `scripts/check_javascript_smoke_inventory.mjs` with a short reason.

The package export smoke derives package-root named-export expectations from the JavaScript exports table in `doc/public_api.md` and stops reading at the next level-2 heading, so later public API tables are not treated as package-root export rows. It also derives callable helper assertions from rows whose `Kind` marks them as contract readers, while keeping the `TomSelectController` class export, package-root default export, and direct controller entrypoint checks separate.

The Tom Select controller smokes share an internal sandbox harness for the Stimulus and Tom Select stubs, controller import, and cleanup. That harness is repository-local test setup only; it does not add a new JavaScript test framework or change the public package entrypoints.

The fixed query params smoke keeps configured request params visible: scalar values are appended, array values keep all representative entries, top-level `null` / `undefined` values are skipped, and existing query params can coexist with appended params. Array item values are passed through `URLSearchParams.append`, so array item `null` / `undefined` / blank strings remain visible as query entries rather than being filtered like top-level values.

The forwarded interaction event smoke keeps the current Tom Select event detail shape visible: `change` forwards the scalar value plus the normalized `values` array, single-value `clear` wraps Tom Select's scalar cleared value as `values: [""]`, and multiple-value `clear` keeps the empty array shape.

The create request header smoke keeps the existing create-on-the-fly contract visible: JSON `Accept` / `Content-Type` headers are always sent, a Rails CSRF meta token is copied to `X-CSRF-Token` when present without requiring one in non-Rails or test-only DOMs, wrapped `{ option: ... }` and raw option response objects are accepted, and nullish success payloads remain non-options.

The error surface smoke keeps request-failure feedback metadata visible: when `error_surface: true` is enabled, create failures mark the configured surface with `data-rfk-error-state`, operation, and status metadata, and clearing the error surface removes those attributes without moving visible message ownership into the package.

The label fallback smoke keeps the remote option display contract visible: explicit label fields still win, missing / blank / null labels fall back to the value field for display only, and `0` / `false` labels remain present values.

The render text fallback smoke keeps the selected-option text contract visible: renderer output uses the configured render text field when present, falls back to label/value text when render text is missing, and stays separate from the label fallback smoke so value display and custom render text regressions are easier to diagnose.

The Tom Select plugin contract smoke keeps rendered plugin data readable from the package root: `clear_button` and `remove_button` produce derived flags, plain plugin arrays stay readable, and unrelated elements return `null`.

The selected preload config smoke keeps rendered selected preload data readable from the package root: explicit and default param names are visible, query params are object-shaped, and fields without selected preload return `null`.

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
- Representative Rails compatibility checks for pull requests and `main` pushes: Rails 7.0 on Ruby 3.1 and Rails 8.0 on Ruby 3.3
- `npm run check:js` on Node 22.x for the JavaScript syntax, smoke inventory, package exports import lane, Tom Select fixed query params smoke, Tom Select forwarded interaction event smoke, Tom Select create request header and response normalization smoke, Tom Select error surface smoke, Tom Select Turbo lifecycle smoke, Tom Select label fallback smoke, Tom Select render text fallback smoke, Tom Select plugin contract smoke, and selected preload config smoke
- gem build, install, and `require "rails_fields_kit"` smoke checks

## Release-related checks

Before release, also review:

- `CHANGELOG.md`
- `doc/release.md`
- `doc/final_release_checklist.md`
- `rails_fields_kit.gemspec`
- `lib/rails_fields_kit/version.rb`
