# Rails Fields Kit Release Guide

This guide describes the lightweight release flow for Rails Fields Kit.

## Policy

- Rails Fields Kit targets Rails 7.0 and newer.
- Rails dependency is currently bounded to Rails 7 and Rails 8.
- GitHub Actions CI is not required for every exploratory commit during active development.
- Branch-ready changes should pass the local checks in [`doc/development.md`](development.md):

```bash
bundle exec standardrb
bundle exec rspec
npm run check:js
bundle exec rake build
```

- Before release, rerun those local checks on the latest `main` and confirm GitHub Actions CI succeeds for the exact release candidate commit.
- The repository-local JavaScript boundary is Node 22.x and Node 24.x. `npm run check:js` should be confirmed on both Node lines through local release prep when available and through the GitHub Actions `javascript` matrix for the exact release candidate commit.
- The repository-local `package.json` is gem-packaged JavaScript entrypoint and `exports` metadata, not an npm release contract. Keep its `private: true` and `version: "0.0.0"` values out of gem release version decisions; `lib/rails_fields_kit/version.rb` remains the gem version source of truth.
- The GitHub Actions Rails compatibility matrix runs for pull requests and `main` pushes using the same representative Rails 7.0 / Ruby 3.1 and Rails 8.0 / Ruby 3.3 lanes. Keep the matrix representative rather than expanding release evidence into a full Rails/Ruby cross-product.

## Pre-release checklist

1. Pull the latest main branch.

   ```bash
   git pull
   ```

2. Install dependencies.

   ```bash
   bundle install
   ```

3. Run the linter locally.

   ```bash
   bundle exec standardrb
   ```

4. Run the test suite locally.

   ```bash
   bundle exec rspec
   ```

5. Run the JavaScript smoke checks locally.

   ```bash
   npm run check:js
   ```

   These checks mirror the repository-local JavaScript confirmation described in [`doc/development.md`](development.md), including the package exports import lane and Tom Select request lifecycle smokes. For release prep, treat the command as the same smoke suite that must pass on Node 22.x and Node 24.x; the GitHub Actions `javascript` matrix is the final branch-head confirmation for both Node lines.

6. Build the gem locally.

   ```bash
   bundle exec rake build
   ```

7. Confirm the latest GitHub Actions CI run is green for the commit you plan to release.

   This is the final branch-head confirmation for lint, RSpec, JavaScript syntax and smoke checks on Node 22.x and Node 24.x, gem package/install smoke checks, and the representative Rails compatibility matrix. The gem package check also verifies that the built artifact contains `package.json` and the JavaScript files referenced by its public `exports` map.

   Treat that packaged `package.json` as JavaScript entrypoint metadata only. It is intentionally `private` and uses the repository-local package metadata version, while the Ruby gem release version remains `RailsFieldsKit::VERSION`.

   The Node 22.x / 24.x JavaScript matrix is the repository-local package export and smoke boundary. It does not define a host-app Tom Select runtime version policy, package manager policy, plugin asset policy, or broader browser compatibility matrix.

   The compatibility matrix intentionally stays small: it confirms the oldest supported representative lane and the current Rails 8 representative lane on pull requests and on `main` after merge. Do not add every Rails/Ruby combination unless release planning explicitly accepts the extra CI time and maintenance cost.

8. Review documentation.

   - `README.md`
   - `Product Profile.md`
   - `AGENTS.md`
   - `CHANGELOG.md`
   - `doc/setup.md`
   - `doc/setup_doctor_output_review.md` when setup doctor output or setup evidence is part of the release surface
   - `doc/setup_doctor_machine_readable.md` when Ruby API JSON output or machine-readable setup evidence is part of the release surface
   - `doc/support_boundary.md`
   - `doc/public_api.md`
   - `doc/select_migration.md`
   - `doc/field_helpers.md`
   - `doc/dependent_query_params.md` when `depends_on:` request shaping or dependency-change behavior is part of the release surface
   - `doc/check_box.md` when the `rfk_check_box` wrapper or checkbox boundary is part of the release surface
   - `doc/check_box_release_evidence.md` when checkbox sample-app or release evidence is part of the release surface
   - `doc/radio_button.md` when the `rfk_radio_button` wrapper or radio button boundary is part of the release surface
   - `doc/radio_button_release_evidence.md` when radio button sample-app or release evidence is part of the release surface
   - `doc/textarea_autosize.md` when the `rfk_text_area` autosize ownership boundary is part of the release surface
   - `doc/textarea_autosize_release_evidence.md` when textarea autosize sample-app or release evidence is part of the release surface
   - `doc/native_numeric_fields.md` when native numeric wrapper helpers are part of the release surface
   - `doc/native_contact_fields.md` when native contact or native search wrapper helpers are part of the release surface
   - `doc/visual_references.md`
   - `doc/visual_reference_index.html`
   - `doc/tom_select_visual_reference.html`
   - `doc/tom_select_request_failure_visual_reference.html`
   - `doc/tom_select_error_surface_contract_visual_reference.html` when request-failure accessibility contract evidence is part of the release surface
   - `doc/tom_select_text_override_visual_reference.html`
   - `doc/native_field_visual_reference.html`
   - `doc/native_accessibility_contract_visual_reference.html` when native helper accessibility contract evidence is part of the release surface
   - `doc/configuration_wrapper_class_visual_reference.html`
   - `doc/table_metadata_visual_reference.html`
   - `doc/token_search_saved_search_visual_reference.html`
   - `doc/controller_helpers.md`
   - `doc/token_suggestions.md`
   - `doc/saved_search_token_suggestion_evidence.md` when saved-search token suggestion evidence is part of the release or PR scope
   - `doc/ransack_suggestions.md`
   - `doc/table_adapters.md`
   - `doc/rails_table_preferences_bridge_boundary.md` when Rails Table Preferences bridge ownership, dependency-light integration, or table metadata handoff is part of the release review surface
   - `doc/configuration.md`
   - `doc/default_allow_clear.md` when the app-wide clear-button default or field-level `allow_clear:` precedence is part of the release surface
   - `doc/events.md`
   - `doc/tom_select_turbo_lifecycle.md`
   - `doc/development.md`
   - `doc/sample_app_checklist.md`
   - `doc/package_root_helper_release_evidence.md` when package-root read-only helper exports are part of the release evidence scope
   - `doc/table_metadata_release_evidence.md` when table metadata rendering, group-level wrappers, or TableRenderer registry checks are part of the release evidence scope
   - `doc/token_table_sample_app_evidence.md` when token search, token suggestions, Ransack suggestion metadata, or table metadata sample-app evidence is part of the release or PR scope
   - `doc/sample_app_results.md`
   - `doc/sample_app_results_route_guide.md` when choosing whether narrow PR evidence belongs in the full sample app evidence log or a PR comment
   - `doc/selected_preload_release_gate.md` when selected preload behavior is part of the release surface
   - `doc/final_release_checklist.md`
   - `doc/release.md`
   - `doc/release_notes_0_1_1.md` for the current next-release draft

   Use `doc/visual_references.md` and `doc/visual_reference_index.html` as the review entrypoints for the static visual reference family, then open the individual artifact that matches the release surface. Do not treat proposal-only lanes or unmerged visual references as release-ready evidence.

   While reviewing `CHANGELOG.md` and the release note draft, keep their roles separate: `CHANGELOG.md` is the exhaustive release-history source, and `doc/release_notes_0_1_1.md` is the reviewer-facing and GitHub-release-facing summary. Confirm the release note highlights are backed by landed `Unreleased` entries, avoid proposal or open-PR behavior, and check that major categories such as token search, table metadata, JavaScript exports, request lifecycle, install generator, and release-scoped event surfaces are not missing from one side.

   For a merge train with docs-only, spec-only, and runtime behavior PRs open at the same time, review release-facing docs only after each PR has landed on the branch being released. Use the merged PR body and linked issue as the boundary evidence, then decide the smallest release-facing update that fits the landed change:

   - docs-only syncs usually need at most a changelog or release-note wording check, and may need no release note highlight when they only clarify existing behavior.
   - spec-only or docs drift guards usually stay out of user-facing release highlights unless they protect a newly documented public contract.
   - runtime behavior changes should get a changelog entry, and the release note draft should mention them only when the behavior is user-facing or changes integration expectations.
   - stacked PRs should be reviewed in merge order so a dependent guard or follow-up does not describe behavior before its base PR has landed.
   - PR-local notes about skipped local checks or connector-only verification should be rechecked on the final release candidate instead of copied into release notes.

9. Confirm version.

   ```ruby
   # lib/rails_fields_kit/version.rb
   RailsFieldsKit::VERSION = "x.y.z"
   ```

   Do not use `package.json`'s `version` field as the gem release version. The package file is included so host apps and package checks can resolve the documented JavaScript entrypoints and `exports` metadata; it is not an npm publish target.

10. Install the built gem into a sample Rails 7+ application, verify [`sample_app_checklist.md`](sample_app_checklist.md), and record the result in [`sample_app_results.md`](sample_app_results.md).

   Use [`sample_app_results_route_guide.md`](sample_app_results_route_guide.md) when the change under review is a narrow PR, source-only visual review, or package-root helper evidence slice and you need to choose between the full sample app evidence log and a compact PR comment. The guide is only a recording-lane selector; it does not add a release gate or turn CI success into browser visual approval.

   When dependent query params are release-scoped, use [`dependent_query_params.md`](dependent_query_params.md) as the behavior source of truth and run only the feature-specific dependent query params lane in [`sample_app_checklist.md`](sample_app_checklist.md). Record it in [`sample_app_results.md`](sample_app_results.md) or a scoped PR comment selected through [`sample_app_results_route_guide.md`](sample_app_results_route_guide.md). Do not turn this lane into release-wide baseline evidence, and keep endpoint authorization, query execution, business autofill, selected preload, pagination, production CSS, and visual approval out of scope.

   When `default_allow_clear` is release-scoped, run the focused default-allow-clear lane in [`sample_app_checklist.md`](sample_app_checklist.md) and record the result in [`sample_app_results.md`](sample_app_results.md) or the scoped PR comment. Keep plugin assets, styling, empty-state wording, selection mutation, and Tom Select lifecycle behavior outside Rails Fields Kit evidence.

   Confirm the host app's Tom Select package version, pin source, plugin CSS, and plugin-specific asset loading through that app's normal JavaScript dependency review. Rails Fields Kit documents and packages its own import paths, but it does not fix, detect, or auto-correct Tom Select versions or plugin asset policy as part of the gem release gate.

   When setup or import evidence is part of the release or PR scope, record the host app's package manager, Tom Select version or pin, and CSS route in the Tom Select environment reproducibility memo in [`sample_app_results.md`](sample_app_results.md). Keep that memo separate from setup doctor `[OK]` / `[MANUAL]` visibility results: the memo records observed host-app package and asset choices, not Rails Fields Kit package-manager policy or a fixed Tom Select version requirement.

   When package-root read-only helper exports are in scope, use [`package_root_helper_release_evidence.md`](package_root_helper_release_evidence.md) to choose representative helper checks before recording the final sample-app or release PR evidence. Keep `doc/public_api.md#javascript-exports` as the source of truth for the exported helper list and return-shape boundary.

   When saved-search token suggestions are in release or PR scope, use [`saved_search_token_suggestion_evidence.md`](saved_search_token_suggestion_evidence.md) to keep the evidence on suggestion option JSON and record the final result in [`sample_app_results.md`](sample_app_results.md) or the PR comment. Keep token parsing, saved-search execution, persistence, authorization, sharing policy, and any independent saved-search selector helper outside this evidence lane.

   When table metadata rendering, group-level wrappers, or TableRenderer registry checks are in scope, use [`table_metadata_release_evidence.md`](table_metadata_release_evidence.md) to choose representative helper checks before recording the final sample-app or release PR evidence. Keep `doc/table_adapters.md` and `doc/table_group_html.md` as the source of truth for behavior and responsibility boundaries.

   When token search, token suggestions, Ransack suggestion metadata, or table metadata sample-app evidence is in scope, use [`token_table_sample_app_evidence.md`](token_table_sample_app_evidence.md) as the companion lane selector before recording the final result in `doc/sample_app_results.md` or a scoped PR comment. Keep token parsing, Ransack or query execution, authorization, table persistence, pagination, visible save/error copy, and final table layout as host-app or table-integration responsibilities.

   After the install generator runs, run the read-only setup doctor in the sample app:

   ```bash
   rails rails_fields_kit:doctor
   ```

   Record whether it reports the initializer and, when importmap is present, the Rails Fields Kit pins. Treat Tom Select package install, Stimulus registration, CSS import, and bundler alias output as manual checklist reminders rather than automatic pass/fail gates or auto-fix behavior.

   When recording or reviewing setup doctor CLI output evidence, use [`setup_doctor_output_review.md`](setup_doctor_output_review.md) for the `[OK]`, `[MISSING]`, `[MANUAL]`, and target-mismatch scanability lanes. Keep that artifact as review evidence, not as the source of runtime wording or setup policy.

   When release or sample-app evidence needs structured setup visibility, use [`setup_doctor_machine_readable.md`](setup_doctor_machine_readable.md) as the source of truth for the Ruby API `format: :json` payload. Keep release evidence to representative JSON output usage and do not treat it as a CLI `--json` contract, auto-fix behavior, formal schema publication, or universal host-app CI pass/fail policy.

   When the release surface includes selected preload behavior, run the focused [`selected_preload_release_gate.md`](selected_preload_release_gate.md) before marking the sample app pass complete. Keep this check to the documented single-value and comma-separated multiple-ID request contract unless release planning explicitly changes that public surface.

   When the release surface includes create-on-the-fly success hooks, confirm the sample app and recorded results cover `rails-fields-kit--tom-select:create`, `event.detail.input`, `event.detail.option`, and the continued `item-add` / `change` flow. Visible success UI remains a host-app responsibility.

   When the release surface includes Turbo reconnect behavior, use [`tom_select_turbo_lifecycle.md`](tom_select_turbo_lifecycle.md) as the focused boundary and QA reference. Keep verification to Stimulus connect/disconnect cleanup, request abort or stale-response behavior, and post-reconnect selected preload or remote search behavior unless release planning explicitly changes the lifecycle contract.

## Release steps

1. Update `CHANGELOG.md`.

   Move entries from `Unreleased` to the target version, for example:

   ```markdown
   ## 0.1.1 - YYYY-MM-DD
   ```

   Keep the moved changelog entry as the detailed source of truth for landed behavior, and leave proposal or open-PR behavior out until it has landed in the release branch. When multiple PRs landed close together, group detailed entries by the behavior that shipped rather than by PR number, and keep docs-only clarifications separate from runtime behavior changes so reviewers can see which items affect host-app integration.

2. Prepare the version-specific release note draft.

   Update `doc/release_notes_0_1_1.md` when the next release remains `0.1.1`. If release planning chooses a different version number, rename that draft and use `doc/release_notes_0_1_0.md` as the historical reference instead of editing the historical notes in place.

   Before using it for a GitHub Release, compare the draft against the moved changelog entry. The release note should summarize user-facing highlights and responsibility boundaries, not replace the detailed changelog entries. If a landed PR only adds a docs guard, release checklist wording, or other review aid, keep it out of the release note highlights unless it changes what host apps should adopt or verify.

3. Commit release metadata.

   ```bash
   git add CHANGELOG.md lib/rails_fields_kit/version.rb
   git commit -m "Prepare x.y.z release"
   ```

4. Build the gem.

   ```bash
   bundle exec rake build
   ```

5. Publish the gem when ready.

   ```bash
   bundle exec rake release
   ```

## Post-release checklist

- Confirm the gem is visible on RubyGems.
- Create a GitHub release if desired.
- Start the next changelog section:

```markdown
## Unreleased
```

- Prepare the next release note draft when useful.

## Notes

This project intentionally avoids owning the JavaScript package manager or importmap setup. Host applications should install Tom Select and register the Stimulus controller using the documented public import paths through their existing JavaScript toolchain.
