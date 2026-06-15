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

It also includes a source-level Tom Select data value drift guard that checks FormBuilder-generated data value names remain represented in `TomSelectController.static values` without turning this guide into a full spec inventory.

It also guards bundled locale packaging for the Tom Select render text defaults. Keep `config/locales/en.yml`, `config/locales/ja.yml`, the gemspec file list, and the `RailsFieldsKit::FormBuilder` I18n keys aligned when adding or renaming bundled copy.

It also includes a lightweight repository-local documentation link check for `README.md` and `doc/**/*.{md,html}`. The check verifies relative file targets, repository-local Markdown heading anchors, and same-file HTML fragment links that resolve to element ids; external URLs and cross-file HTML element anchors remain intentionally outside its scope.

The visual reference documentation drift spec keeps `doc/visual_references.md`, `doc/visual_reference_index.html`, and the README Docs map aligned. The README check intentionally points at the maintained visual reference family map and representative family wording instead of every individual HTML artifact, so new artifact families should update the Markdown map, HTML index, and README summary together without freezing the README sentence verbatim.

The styling boundary documentation drift spec keeps `doc/styling_boundary.md`, `doc/visual_references.md`, and `doc/public_api.md` aligned on representative wrapper hook and host-app CSS ownership signals. It intentionally checks source-of-truth roles and responsibility boundaries instead of freezing helper markup, every class inventory row, or production CSS approval wording.

The configuration documentation drift spec compares `RailsFieldsKit::Configuration` public initializer keys with `doc/configuration.md` quick reference rows and detailed headings. Keep new configuration keys, field-level override notes, and stable nil / locale-aware default boundaries aligned there when the initializer surface changes.

The repository documentation drift spec covers two narrow repository-maintenance boundaries: generated setup notes upstream links must point at existing repository docs, and `doc/support_boundary.md` plus this development guide must stay aligned with the Ruby / Rails / Node version values declared in gem metadata, package metadata, and representative CI rows. This check is intentionally not a full README Docs map mirror or an external URL validator.

The setup example documentation drift spec keeps the JavaScript setup signals in `README.md` and `doc/setup.md` aligned for package-root imports, direct controller imports, bundler aliases, and importmap pins without freezing the full prose.

The suggestion payload documentation drift spec keeps `TokenSuggestions` and `RansackSuggestions` docs aligned with representative option payload keys, custom output field names, and Ransack metadata keys without freezing full examples or prose.

The FormBuilder helper inventory docs spec keeps the compact helper list in `doc/public_api.md` aligned with detailed helper sections in `doc/field_helpers.md`, while checking only representative README chooser entries so the README can stay concise instead of becoming an exhaustive API mirror.

When checking the table FormBuilder helper surface, read `lib/rails_fields_kit/form_builder.rb` together with `lib/rails_fields_kit/form_builder_table_groups.rb`. The base file alone does not show the full `group_html:` surface for `rfk_table_filters` and `rfk_table_cell_editors`; `doc/table_group_html.md` is the source of truth for that split definition boundary.

The remote request option documentation drift spec keeps representative request-shaping option names visible across README, `doc/field_helpers.md`, and `doc/controller_helpers.md`. It checks public option signals such as `query_params:`, `selected_query_params:`, `create_params:`, `selected_param:`, `selected_multiple_param:`, and `create_param:` without turning README into a full mirror of the endpoint helper reference.

Representative compatibility checks are also useful before review or release:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rspec
BUNDLE_GEMFILE=gemfiles/rails_8_0.gemfile bundle exec rspec
```

## Check JavaScript locally

The package metadata boundary is Node 22.x || 24.x. The JavaScript syntax check uses Node 22.x and Node 24.x, matching `package.json` and the GitHub Actions `javascript` job matrix.

This repository intentionally does not commit a single `.nvmrc` or `.node-version` as the support boundary. When reproducing JavaScript checks locally, select either supported major explicitly with your version manager, for example Node 22.x or Node 24.x, then run the same `npm run check:js` command that CI runs on both lines.

```bash
npm run check:js
```

This command checks the public package entrypoint and Tom Select controller source without installing additional npm dependencies. It starts with the smoke inventory guard, then runs lightweight Node sandbox checks through the same public import paths that CI uses.

Read the `check:js` coverage as guard families. Do not treat this guide as the script membership source of truth:

- package/import metadata: package `exports`, package-root named exports, callable contract-reader rows, the package-root default export, and the direct controller entrypoint
- request lifecycle and event payloads: fixed query params, Tom Select forwarded interaction event payloads, request success / failure details, create request headers and response normalization, error-surface metadata, Tom Select Turbo lifecycle behavior, and Turbo lifecycle cleanup
- rendered text, option, and fallback semantics: label fallback, option value guards, render text fallback, render text accessibility boundaries, and escaping or live-region cues that should stay package-owned
- package-root contract readers: selection state, plugin state, selected preload config, and similar read-only rendered-field helpers that inspect existing data without exposing Tom Select internals or adding mutation APIs
- docs and smoke-inventory drift: runner membership, docs wording, and public JavaScript export documentation that should stay aligned without turning this guide, README, or `doc/public_api.md` into an exhaustive smoke inventory

Within the request lifecycle family, keep the Tom Select forwarded interaction event payloads boundaries visible: `change` forwards the scalar value plus the normalized `values` array, single-value `clear` wraps Tom Select's scalar cleared value as `values: [""]`, and multiple-value `clear` keeps the empty array shape. This family also includes the Tom Select Turbo lifecycle smoke so the Tom Select Turbo lifecycle behavior remains covered alongside request abort, stale-response, and cleanup checks.

Exact smoke script membership belongs to `scripts/check_javascript.mjs`, and `scripts/check_javascript_smoke_inventory.mjs` verifies that CI-owned `scripts/check_*.mjs` files are either run by `npm run check:js` or explicitly documented as standalone with a short, single-line reason. Update those sources first when adding, removing, or intentionally exempting a smoke; keep this section focused on the guard families and responsibility boundaries.

The package export smoke derives package-root named-export expectations from the JavaScript exports table in `doc/public_api.md` and stops reading at the next level-2 heading, so later public API tables are not treated as package-root export rows. It also derives callable helper assertions from rows whose `Kind` marks them as contract readers, while keeping the `TomSelectController` class export, package-root default export, and direct controller entrypoint checks separate.

The Tom Select controller smokes share an internal sandbox harness for the Stimulus and Tom Select stubs, controller import, and cleanup. That harness is repository-local test setup only; it does not add a new JavaScript test framework or change the public package entrypoints.

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
- `npm run check:js` on Node 22.x and Node 24.x for JavaScript syntax plus the smoke inventory guard, package/import metadata checks, Tom Select request lifecycle and event payload checks, rendered text and option semantics checks, package-root contract reader checks, and docs or smoke-inventory drift checks
- gem build, install, and `require "rails_fields_kit"` smoke checks

## Open PR freshness checks

Before treating an open pull request as review- or release-ready, re-check the current PR metadata instead of relying only on historical CI notes in the PR body or earlier comments. A green workflow run for an old head commit is useful evidence, but it does not prove the PR is still mergeable against the latest `main`.

For review queue triage and release prep, confirm these current signals together:

- the latest workflow run state for the PR head commit
- the PR metadata `mergeable` value or equivalent GitHub mergeability signal
- whether the PR branch is behind, diverged, or superseded by a replacement PR
- the base branch freshness, especially after recent `main` merges that touched nearby docs, specs, package metadata, or public API wording

When a replacement PR supersedes an older PR, leave the older PR with enough reviewer-facing context to avoid duplicate review effort: link the replacement, summarize whether the old branch should be closed, and call out any human decision that still belongs on the old PR. If the older PR cannot be closed safely because the replacement changes scope, risk, or public API surface, leave both open and record the reason in the newer PR's Notes.

When multiple open PRs close the same issue, do not treat that as an automatic merge or close signal. Pick a single active candidate only when the scope, target issue, and review status make the choice clear; otherwise keep the duplicate closing PRs visible for human review and note the overlap in each affected PR's Notes.

Keep this as a manual queue hygiene guard. Do not add a GitHub API-dependent CI job, automatic branch refresh, force push, stale PR cleanup, or merge decision automation unless release planning explicitly accepts that larger devops surface.

## Release-related checks

Before release, also review:

- `CHANGELOG.md`
- `doc/release.md`
- `doc/final_release_checklist.md`
- `rails_fields_kit.gemspec`
- `lib/rails_fields_kit/version.rb`
