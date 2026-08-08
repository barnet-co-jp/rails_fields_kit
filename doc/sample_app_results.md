# Rails Fields Kit Sample App Results

Use this file to record manual verification results before publishing a release.

Use the route map below to choose the evidence lane for the release or PR under review. Keep release-wide checks separate from feature-specific evidence; this file records what was manually verified, not a new release gate or runtime contract.

The route map is a triage aid. Start with release-wide confidence for release candidates, then add only the feature-specific lane that changed. A narrow PR can cite the relevant lane in a PR comment instead of filling every section here.

If the route map is too broad for a narrow PR, use `doc/sample_app_results_route_guide.md` as the quick decision table. It explains when to update this evidence log, when a PR comment is enough, and how to use `PASS`, `FAIL`, `SOURCE REVIEW ONLY`, and `DEFERRED` without treating CI success or source review as browser approval.

| Review goal | Start with | Use when | Keep separate from |
| --- | --- | --- | --- |
| Release-wide confidence | Target release, local gem checks, branch head CI confirmation, generator checks | Every release candidate or release PR needs baseline package, CI, and generator evidence. | Feature-specific helper, visual, remote, token, or table lanes unless the release candidate explicitly includes them. |
| JavaScript setup and package-root helper evidence | Setup doctor checks, JavaScript setup checks, package-root helper lanes checked, event checks, Turbo reconnect checks | The release touches setup visibility, package-root exports, read-only rendered-field helper evidence, Stimulus registration, importmap/jsbundling setup, events, or reconnect behavior. | Native wrapper behavior, visual reference rendering, endpoint execution, or table metadata unless those lanes also changed. |
| Tom Select plugin override boundary | Tom Select plugin override checks | The release or PR touches `config.default_plugins`, field-level `plugins:`, or the `remove_button` helper default for `rfk_tags` / `rfk_token_search`. | Tom Select package install, plugin-specific UI behavior, production CSS approval, `allow_clear` visual review, or package-root helper evidence unless those lanes also changed. |
| Default allow clear policy | Default allow clear checks | The release or PR touches `config.default_allow_clear` or field-level `allow_clear:` precedence. | Raw `default_plugins` / `plugins:` replacement, visual approval, event payloads, selection mutation, or Tom Select lifecycle unless those lanes also changed. |
| Native wrapper and accessibility | Form helper checks, native helper representative wrapper and accessibility lane checks, password field native wrapper checks, native wrapper customization checks | Native helper wrapper, password helper boundary, class/styling boundary, hint/error, affix, accessibility wiring, or browser semantics evidence changed. | Tom Select remote lifecycle, package-root helper import checks, credential policy, or table persistence. |
| README first field quickstart evidence | `rfk_select` representative collection-backed single-value lane checks, Visual reference render checks | The README first field or quickstart sample needs endpoint-free, server-rendered collection evidence without mixing in setup/import, remote search, selected preload, create-on-the-fly, or token metadata lanes. | Setup/import verification, remote search, selected preload, create-on-the-fly, token metadata, or release-wide readiness. |
| Visual reference review | Visual reference render checks | Static HTML visual references or the one-screen visual reference index changed. | Runtime helper behavior, production CSS approval, sample-app field behavior, or CI success as visual approval. |
| Remote lifecycle feedback | Selected preload representative lane checks, create-on-the-fly representative failure lane checks, visible feedback checks | Selected preload, remote search, create-on-the-fly, request-failure, or visible fallback behavior changed. | Setup/import checks, static visual reference approval, endpoint authorization policy, or retry UI ownership unless those surfaces changed. |
| Token and table metadata | `rfk_token_search` representative token-entry lane checks, token suggestion and Ransack suggestion metadata checks, table metadata checks | `rfk_token_search` helper rendering, submitted token text, token suggestions, saved-search metadata, Ransack metadata, table filters, range field table metadata, or cell editor metadata changed. | Query execution, parser semantics, table preference persistence, visual reference rendering, native wrapper evidence, or suggestion/table metadata approval unless those lanes also changed. |

When adding a new evidence lane, place it near the closest feature-specific section and update this route map only when reviewers need a new starting point. Do not turn a feature-specific lane into a release-wide requirement without a separate release policy decision.

## Target release

- Version:
- Date:
- Tester:
- Sample app Rails version:
- Ruby version:
- Gem source:
  - [ ] local path checkout
  - [ ] built gem package
  - [ ] other:
- JavaScript setup:
  - [ ] esbuild
  - [ ] jsbundling-rails
  - [ ] importmap
  - [ ] other:

## Local gem checks

```bash
bundle exec standardrb
bundle exec rspec
npm run check:js
bundle exec rake build
```

Result:

- [ ] StandardRB passed
- [ ] RSpec passed
- [ ] JavaScript smoke check passed
- [ ] Gem build passed
- [ ] No RubyGems validation warnings

Notes:

## Branch head CI confirmation

- Branch / PR:
- Commit SHA:
- Workflow run URL:
- [ ] GitHub Actions passed for the same branch head reviewed in this checklist

Notes:

## Generator checks

```bash
rails generate rails_fields_kit:install
```

Result:

- Setup note route checked:
  - [ ] default generated note
  - [ ] `--skip-setup-notes`
  - [ ] host-app-owned setup notes
- [ ] `config/initializers/rails_fields_kit.rb` generated for the selected route
- [ ] default route generated `doc/rails_fields_kit_setup.md` and the note matched the current public API and `doc/setup.md` walkthrough
- [ ] `--skip-setup-notes` route intentionally omitted `doc/rails_fields_kit_setup.md` and directed the reviewer to maintained `doc/setup.md`
- [ ] host-app-owned setup note location was recorded when that route was used

Notes:

## Setup doctor checks

```bash
rails rails_fields_kit:doctor
```

Use `doc/setup.md` as the setup behavior source of truth. Use `doc/setup_doctor_output_review.md` when the release or PR needs evidence that setup doctor output is readable and that `[OK]`, `[MISSING]`, and `[MANUAL]` states are being interpreted correctly.

Result:

- [ ] setup doctor ran after generator setup without changing files
- [ ] initializer visibility was recorded
- [ ] generated setup note evidence was recorded as `[OK]` when `doc/rails_fields_kit_setup.md` existed, or `[MANUAL]` when `--skip-setup-notes` / host-app-owned notes were the selected route
- [ ] `[OK] Generated setup note` was treated as path visibility only, not approval of app-specific note content or setup quality
- [ ] `[MANUAL] Generated setup note` was not treated as `[MISSING]`, a hard failure, an auto-fix request, or a request for setup doctor to create or inspect the note
- [ ] importmap pin visibility was recorded when `config/importmap.rb` was present, or the non-importmap/manual status was recorded without treating bundler apps as failures
- [ ] representative Stimulus registration evidence was recorded as either `[OK]` advisory source visibility or `[MANUAL]` host-app follow-up when registration evidence was in scope
- [ ] `[OK] Stimulus registration` was not treated as proof of the host app's final Stimulus boot policy or every possible controller registry
- [ ] setup doctor output readability was checked with `doc/setup_doctor_output_review.md` when diagnostic scanability or importmap target mismatch evidence was in scope
- [ ] evidence notes distinguish setup behavior from CLI output readability evidence, instead of treating this section as a source of new doctor behavior or output wording
- [ ] manual checklist items for Tom Select package install, Stimulus registration, CSS import, and bundler aliases were reviewed as host-app responsibilities rather than automatic pass/fail gates, with Stimulus registration evidence recorded above as either an `[OK]` advisory signal or a `[MANUAL]` follow-up rather than proof of final boot policy

Notes:

## JavaScript setup checks

- [ ] Tom Select package installed
- [ ] `import { TomSelectController } from "rails_fields_kit"` resolved
- [ ] `import { nativeFieldAccessibilityContract } from "rails_fields_kit"` resolved
- [ ] `import TomSelectController from "rails_fields_kit/tom_select_controller"` resolved
- [ ] documented controller registration succeeded
- [ ] importmap pins resolved `rails_fields_kit` and `rails_fields_kit/tom_select_controller` when importmap was used
- [ ] documented controller registration still worked from the existing Stimulus boot file after adding those importmap pins
- [ ] at least one rendered native helper field was readable through `nativeFieldAccessibilityContract(element)` without adding a new package-root helper export
- [ ] package-root helper lanes in release scope were selected from `doc/package_root_helper_release_evidence.md` and matched the current `doc/public_api.md#javascript-exports` helper list
- [ ] helper-specific package-root import and read-only evidence was recorded in the table below with the representative field, result, and source-of-truth reference instead of becoming a release-wide setup checkbox
- [ ] helper-specific examples such as native accessibility, Tom Select plugin contract, or selected preload config stayed tied to the selected evidence lane rather than implying every package-root helper must be checked for every release
- [ ] Tom Select CSS loaded
- [ ] browser console has no import errors

Notes:

README first field quickstart evidence does not belong in this setup/import section unless the PR also changes setup visibility. Record the rendered field behavior in the `rfk_select` representative collection-backed single-value lane below, and use this section only for import, registration, CSS, or package-root helper evidence.

Tom Select environment reproducibility memo:

| Item | Recorded value | Notes |
| --- | --- | --- |
| Package manager / install route |  | Record the sample app route used for this check, such as yarn, npm, pnpm, importmap, or an existing app bundle. This is an observed setup note, not a Rails Fields Kit package-manager policy. |
| Tom Select package version or pin |  | Record the version, pin, or source visible to the sample app when it was checked. This is not a Rails Fields Kit-owned Tom Select version requirement. |
| CSS import or asset route |  | Record the CSS route that made Tom Select styles visible, such as `tom-select/dist/css/tom-select.css`, a bundled stylesheet, or an app-owned asset. This is not a Rails Fields Kit CSS bundle or plugin asset policy. |

Use this memo only to make release evidence reproducible. Tom Select package version, package manager, lockfile, CDN or pin source, plugin assets, and final CSS bundle choices remain host-app responsibilities as described in `doc/support_boundary.md`.

Package-root helper lanes checked:

Use this table as the helper-specific evidence log. Choose helper names from `doc/public_api.md#javascript-exports`, use `doc/package_root_helper_release_evidence.md` for the representative lane guidance, and record only helpers that are in release or PR scope. Do not mirror the full helper family here when a helper is unrelated to the change under review.

When the scoped helper lane is `tomSelectPluginContract(element)` for `allow_clear: true`, record it in this package-root helper table instead of the Tom Select plugin override section below. The row should name the representative field, the `clear_button` / `hasClearButton` evidence, and any explicit `plugins:` field that was intentionally checked, while leaving plugin assets, clear/remove styling, selection mutation, empty-state copy, and Tom Select plugin lifecycle outside Rails Fields Kit ownership.

In the `Result` column, use `PASS` when the scoped helper lane was checked successfully, `FAIL` when it was checked and did not satisfy the lane, `SKIPPED` when an in-scope lane was intentionally deferred, and `OUT OF SCOPE` when a package-root helper boundary was reviewed and deliberately left outside this release or PR. For `SKIPPED` and `OUT OF SCOPE`, use `Evidence notes` to name the reason, follow-up, or boundary instead of leaving the row blank. Do not add rows for unrelated helpers solely to prove they were not checked.

| Helper | Source-of-truth reference | Representative field or selector | Result | Evidence notes |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |

## Default allow clear checks

Use this section only when the release or PR changes the app-wide semantic clear default or its field-level precedence. Keep raw plugin replacement evidence in `Tom Select plugin override checks` and visual review in the visual evidence lane.

- Representative helper / fields:
- Branch or commit:
- Evidence location:
- Result: `PASS` / `FAIL` / `SOURCE REVIEW ONLY` / `DEFERRED`

- [ ] `config.default_allow_clear = true` added `clear_button` when the representative field omitted `allow_clear:`
- [ ] a comparable `allow_clear: false` field suppressed only Rails Fields Kit's semantic auto-add
- [ ] an explicit `plugins: ["clear_button"]` remained explicit plugin configuration rather than being removed by `allow_clear: false`
- [ ] the representative single-value clear returned to Rails-owned `include_blank:` or `prompt:` wording
- [ ] `clear_button` was recorded as whole-field clear and `remove_button` as per-item removal
- [ ] evidence notes kept plugin assets, styling, empty-state wording, selection mutation, and Tom Select lifecycle behavior with the host app or Tom Select

Notes:

## Tom Select plugin override checks

Use this section only when the release or PR changes plugin defaults, field-level `plugins:`, or the documented `remove_button` default for `rfk_tags` / `rfk_token_search`. Keep it as feature-specific evidence; it is not a release-wide requirement.

- Representative helper:
- Representative field:
- Evidence location:

- [ ] initializer `config.default_plugins` was recorded as the fallback only when the representative field omitted `plugins:`
- [ ] field-level `plugins:` was checked as a replacement for the initializer default, not a merge with it
- [ ] `rfk_tags` or `rfk_token_search` kept the documented `remove_button` default when `plugins:` was omitted
- [ ] an explicit `plugins:` override for `rfk_tags` or `rfk_token_search` included `"remove_button"` when the representative field still expected remove controls
- [ ] `allow_clear: true` was kept separate from this lane unless the release or PR also touched the clearable visual or event surface
- [ ] evidence notes confirmed Rails Fields Kit passes plugin names through and does not own Tom Select plugin asset installation, plugin-specific behavior, or production CSS approval

Notes:

## Form helper checks

- [ ] `rfk_select`
- [ ] `rfk_combobox`
- [ ] `rfk_autocomplete`
- [ ] `rfk_lookup` submits separate text and selected ID params
- [ ] `rfk_tags`
- [ ] `rfk_multi_select`
- [ ] `rfk_grouped_select`
- [ ] `rfk_enum_select`
- [ ] `rfk_token_search`
- [ ] native helpers such as `rfk_text_field` and `rfk_money_field`
- [ ] `rfk_password_field` when password helper native-wrapper evidence is in release scope

Notes:

## Visual reference render checks

Use this section when the release or PR changes one of the static visual reference HTML files. For narrow static visual reference PRs, use `doc/sample_app_results_route_guide.md` to decide whether this matrix needs an entry or whether a scoped PR comment is enough.

- Changed visual reference file(s):
- Rendered artifact or screenshot link(s):

Use the matrix below for changed or release-critical visual references before treating the checkbox pass as complete. Keep static visual artifact evidence separate from runtime sample-app lanes; the matrix records what was rendered, not new helper behavior.

In the `Browser review result` column, use `PASS` only when the named viewport was actually reviewed in a browser, `FAIL` when the browser review found an issue, `SOURCE REVIEW ONLY` when connector-only or source-level review checked the changed HTML/CSS without rendering it, and `DEFERRED` when browser-capable review is intentionally handed off. For `SOURCE REVIEW ONLY` and `DEFERRED`, use `Evidence location` to name the source diff, PR comment, reviewer handoff, or follow-up. Do not treat CI success or source review alone as visual approval.

Example entries for source-only or deferred static visual reference review:

| Artifact | Viewport checked | State or lane checked | Browser review result | Responsibility boundary confirmed | Evidence location |
| --- | --- | --- | --- | --- | --- |
| `doc/tom_select_visual_reference.html` | desktop / narrow | Restored Preload Evidence | `SOURCE REVIEW ONLY` | Runtime behavior and production CSS unchanged | Source diff reviewed; browser-capable desktop / narrow check remains required. |
| `doc/tom_select_visual_reference.html` | desktop / narrow | Restored Preload Evidence | `DEFERRED` | Runtime behavior and production CSS unchanged | PR comment hands off browser-capable desktop / narrow review to reviewer before visual approval. |

Use `SOURCE REVIEW ONLY` when the changed source was reviewed but not rendered in a browser. Use `DEFERRED` when the browser-capable review is deliberately handed off; always name the missing artifact, viewport, lane, and handoff context instead of leaving the evidence blank.

| Artifact | Viewport checked | State or lane checked | Browser review result | Responsibility boundary confirmed | Evidence location |
| --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |

- [ ] desktop viewport checked for state visibility, readable labels, and expected spacing
- [ ] narrow/mobile viewport checked for wrapping, overflow, state visibility, and readable feedback copy
- [ ] review notes call out any intentionally deferred visual follow-up instead of treating CI green as visual approval

Notes:

## Native helper representative wrapper and accessibility lane checks

- [ ] one representative native helper field covered the end-to-end `wrapper: true` lane
- [ ] the field rendered the documented label, hint, prefix, and suffix while staying in the native helper family rather than a Tom Select lane
- [ ] `nativeFieldAccessibilityContract(element)` read the representative field's rendered `describedByIds`, `hintElement`, `errorElement`, and `wrapperElement` contract from package-root import code
- [ ] an edit form or validation rerender kept the same value and preserved the shared wrapper / accessibility wiring for that representative field
- [ ] a comparable `accessibility: false` example clearly removed the automatic accessibility wiring that the release docs treat as opt-out behavior

Notes:

## Password field native wrapper checks

Use this section when `rfk_password_field` is release-critical evidence. Keep it inside the native wrapper family: this section records wrapper, hint, validation, and accessibility behavior around an ordinary password input, not a credential workflow.

- Representative helper: `rfk_password_field`
- Representative field:
- Evidence location:

- [ ] the representative password field rendered a native `type="password"` input through the same wrapper lane as other native helpers
- [ ] label, hint, validation error, prefix or suffix if present, and required marker stayed readable through an edit form or validation rerender
- [ ] accessibility wiring still connected label, hint, and error ids when `accessibility:` remained enabled
- [ ] ordinary native options such as `autocomplete:` reached the password input when supplied by the host app
- [ ] evidence notes confirmed Rails Fields Kit did not add a password visibility toggle, strength meter, credential policy, authentication workflow, credential storage behavior, or final password validation copy
- [ ] host-app-owned password policy and password manager guidance were recorded separately from Rails Fields Kit wrapper evidence when relevant

Notes:

## Native wrapper customization checks

Use this section for wrapper class and styling boundary evidence when initializer defaults, field-level `*_html` overrides, or wrapper / affix class pass-through changed. Keep this lane representative: record the source, rendered artifact, result, and evidence location for the scoped field instead of mirroring every class hook.

Styling boundary evidence:

- Source-of-truth reference: `doc/styling_boundary.md`
- Initializer / override reference: `doc/configuration.md`
- Rendered evidence route when browser-capable visual review is required: `doc/configuration_wrapper_class_visual_reference.html`
- Representative helper / field:
- Evidence location:
- Result:

- [ ] `wrapper_html:` added a representative class or `data` attribute to the outer wrapper while keeping the configured `wrapper_class`
- [ ] `label_html:`, `hint_html:`, and `error_html:` added representative attributes without losing generated label, hint, or validation error behavior
- [ ] `control_html:`, `prefix_html:`, and `suffix_html:` added representative attributes on an affix field without changing the input value or submitted param shape
- [ ] `html:` still targeted the input element itself, separate from generated wrapper pieces
- [ ] hint / error ids still fed the shared accessibility wiring when `accessibility:` remained enabled
- [ ] `accessibility: false` stayed an explicit opt-out from automatic aria wiring only, not from the wrapper customization lane
- [ ] repo-wide initializer class defaults still provided the shared baseline while field-level `*_html` options only layered additional attributes for that field
- [ ] evidence notes confirmed production CSS, theme tokens, dark mode, density policy, and design-system approval remained host-app responsibilities
- [ ] any browser-capable visual review of `doc/configuration_wrapper_class_visual_reference.html` was recorded in the Visual reference render checks matrix, or explicitly deferred there rather than treated as CI approval
- [ ] this lane stayed a representative styling-boundary check and did not become a full wrapper class inventory mirror

Notes:

## Native constraint attribute checks

Use this section when native helper constraint pass-through is release-critical evidence. Keep it separate from the wrapper / accessibility lane: this section records input attributes reaching the rendered input, not a new validation UI or masking contract.

- Representative helper:
- Representative field:
- Evidence location:

- [ ] `maxlength` or `minlength` reached the rendered input when supplied through top-level field options or `html:`
- [ ] `pattern` reached the rendered input when supplied through top-level field options or `html:`
- [ ] `autocomplete` reached the rendered input when supplied through top-level field options or `html:`
- [ ] `inputmode` reached the rendered input when supplied through top-level field options or `html:`
- [ ] any checked `required`, `disabled`, or `readonly` state stayed limited to ordinary native input state and did not imply a Rails Fields Kit-owned validation-message policy
- [ ] the same field still kept its wrapper / hint / error / affix and accessibility wiring responsibilities aligned with the native helper docs
- [ ] validation copy, browser validation-message behavior, masking, character counters, and server-side validation remained host-app responsibilities

Notes:

## Native browser semantics visual lane checks

Use this section when the native helper Browser semantics lane is release-critical evidence. Keep it tied to `doc/native_field_visual_reference.html`: this records static visual-reference evidence for browser-provided semantics, not a runtime sample-app behavior contract.

- Visual reference artifact: `doc/native_field_visual_reference.html`
- Lane: `Browser semantics`
- Evidence location:

- [ ] search, email, URL, telephone, money, and percent examples were checked in the Browser semantics lane when those helpers were in release scope
- [ ] the evidence note distinguished browser-provided semantics from Rails Fields Kit-owned wrapper, hint, error, affix, and accessibility wiring
- [ ] formatting, masking, browser validation-message policy, autocomplete policy, locale policy, and custom picker behavior remained host-app responsibilities
- [ ] the Browser semantics lane evidence stayed separate from runtime sample-app field behavior unless a release candidate explicitly required both
- [ ] any remaining browser-capable visual review was recorded as a blocker or follow-up instead of treating CI green as visual approval

Notes:

## `collection_select` migration checks

- [ ] documented `collection_select` to `rfk_select` swap preserved the same submitted attribute and redisplay behavior
- [ ] `include_blank:` kept the expected blank-option behavior from `doc/select_migration.md`
- [ ] representative `disabled:` options still rendered and behaved as expected
- [ ] representative grouped options still rendered correctly
- [ ] representative `option_html:` data or HTML attributes still reached the rendered options
- [ ] the migration path stayed aligned with `doc/field_helpers.md` and `doc/public_api.md`

Notes:

## `rfk_select` representative collection-backed single-value lane checks

Use this section for README first field quickstart evidence when the documented first field is an endpoint-free, server-rendered collection-backed `rfk_select`. Keep setup/import confirmation in the JavaScript setup section and keep remote search, selected preload, create-on-the-fly, and token metadata evidence in their own lanes.

- [ ] one representative `rfk_select` field covered the end-to-end collection-backed single-value lane
- [ ] the field rendered the current selected value from the documented server-rendered collection lane
- [ ] README first field quickstart evidence recorded the representative route, page, or fixture used for the endpoint-free server-rendered collection lane
- [ ] README first field quickstart evidence linked any matching idle visual reference or screenshot without treating that static artifact as runtime behavior evidence
- [ ] evidence notes confirmed the field stayed out of setup/import, remote-search, selected-preload, create-on-the-fly, and token-metadata lanes
- [ ] if that representative field enabled `allow_clear: true`, clearing the selected value returned it to the documented blank or placeholder state
- [ ] clearing the representative field still kept it in the collection-backed single-value contract rather than drifting into a remote-search, token-metadata, or create-on-the-fly lane
- [ ] an edit form or validation rerender kept the same selected value on that representative field
- [ ] representative `include_blank:` still exposed the documented blank-option behavior for that lane
- [ ] representative `disabled:` options and `option_html:` attributes remained visible on that field without drifting into a remote-search or token-metadata lane
- [ ] the representative field stayed independent from `url:`, `selected_url:`, and `create_url:`

Notes:

## Controller helper checks

- [ ] `rfk_search_with` returns remote options
- [ ] the representative selected preload lane below can load selected labels through `selected_url:` and receives any fixed `selected_query_params:` it relies on
- [ ] `rfk_create_with` creates options on the fly
- [ ] `rfk_token_suggestions_with` returns token suggestion option JSON
- [ ] at least one representative non-default `action:` route still worked from the documented route shape
- [ ] fixed `query_params:` reached representative remote search requests
- [ ] fixed `create_params:` were merged into representative create-on-the-fly requests
- [ ] validation errors return `422`
- [ ] authorization failures return `403`
- [ ] wrapped responses work with `options` / `option`
- [ ] rich fields return description and badge data
- [ ] Ransack-compatible suggestion metadata works as expected if it is part of the release surface

Notes:

## Selected preload representative lane checks

- [ ] one representative edit-form field with `selected_url:` covered the end-to-end selected preload lane
- [ ] saved ID only initial state restored the selected label through `selected_url:`
- [ ] representative fixed `selected_query_params:` still reached the selected preload request
- [ ] when package-root helper evidence was in scope, `readRenderedSelectedPreloadConfig(element)` matched the rendered `selectedUrl`, param names, and `selectedQueryParams` without counting as selected preload request execution
- [ ] `rails-fields-kit--tom-select:selected-load` was observed before the field settled into its normal selected state
- [ ] a representative failure path left user-understandable host-app fallback or visible feedback after `rails-fields-kit--tom-select:selected-load-error`
- [ ] if that field used `error_surface: true`, the selected preload failure path still exposed the expected inline placeholder through `event.detail.surface`
- [ ] a Turbo-driven validation rerender or same-form revisit still restored the label for that same representative field
- [ ] one representative multiple-value field with `selected_url:` restored visible labels for saved IDs instead of leaving a raw ID-only state
- [ ] if that multiple-value lane relied on a custom `selected_multiple_param:`, the selected preload request still used the documented key, and a comparable endpoint still accepted comma-separated `ids`

Notes:

## Create-on-the-fly representative failure lane checks

- [ ] one representative field with `create_url:` covered the end-to-end create-on-the-fly failure lane
- [ ] a failed create request dispatched `rails-fields-kit--tom-select:create-error`
- [ ] the representative failure path left host-app fallback copy or retry UI visible near the field
- [ ] if that field used `error_surface: true`, the failure path still exposed the expected inline placeholder through `event.detail.surface`
- [ ] a follow-up success or fresh interaction cleared stale inline failure UI for that same field
- [ ] retry policy and final visible copy remained a host-app responsibility rather than a built-in Rails Fields Kit behavior

Notes:

## `rfk_autocomplete` representative suggestion-only lane checks

- [ ] one representative `rfk_autocomplete` field covered the end-to-end suggestion-only lane
- [ ] remote suggestions appeared as typing assist for that field
- [ ] choosing a suggestion still left the submitted value as free text rather than a selected ID or created record payload
- [ ] a normal submit, edit-form redisplay, or validation rerender kept that same field in the free-text helper lane
- [ ] the representative field stayed independent from `selected_url:` and `create_url:`

Notes:

## `rfk_multi_select` representative collection-backed lane checks

- [ ] one representative `rfk_multi_select` field covered the end-to-end collection-backed multiple-value lane
- [ ] the field selected multiple known values from the documented collection-backed lane
- [ ] the submitted value stayed an ordinary array of selected IDs or values rather than tag-entry or free-text creation payload
- [ ] an edit form or validation rerender kept the same selected values on that representative field
- [ ] the representative field stayed independent from `create_url:` and token-style parsing

Notes:

## `rfk_tags` representative tag-entry lane checks

- [ ] one representative `rfk_tags` field covered the end-to-end tag-entry lane
- [ ] existing tags stayed visible while a new tag was typed or accepted in that same field
- [ ] when create-on-the-fly was enabled for that field, the evidence recorded either a successful created tag or the deliberate create-failure path for that same tag-entry lane
- [ ] the submitted value and evidence notes stayed in the tag-entry / create-on-the-fly lane rather than the ordinary collection-backed `rfk_multi_select` lane
- [ ] an edit form or validation rerender kept existing tags visible, including selected labels restored through `selected_url:` when that field relied on saved IDs
- [ ] endpoint authorization, created-record policy, retry UI, and final visible copy remained host-app responsibilities

Notes:

## `rfk_grouped_select` representative optgroup-preserving lane checks

- [ ] one representative `rfk_grouped_select` field covered the end-to-end optgroup-preserving lane
- [ ] the field rendered the documented grouped collection with its current optgroup structure intact
- [ ] choosing a value kept the submitted value in the ordinary selected ID or value lane rather than a remote-search or token-metadata lane
- [ ] an edit form or validation rerender kept the same selected value while preserving the grouped labels on that representative field
- [ ] the representative field stayed independent from `url:`, `selected_url:`, and `create_url:`

Notes:

## `rfk_enum_select` representative enum-backed lane checks

- [ ] one representative `rfk_enum_select` field covered the end-to-end enum-backed lane
- [ ] the field rendered the current enum labels and values from the model-backed enum lane
- [ ] choosing a value kept the submitted value in the ordinary enum-backed selected-value lane rather than a free-text or created-record lane
- [ ] an edit form or validation rerender kept the same selected enum value and redisplayed the matching label for that representative field
- [ ] the representative field stayed clearly tied to the enum-backed attribute rather than a hand-maintained collection helper lane

Notes:

## `rfk_enum_select` explicit enum source lane checks

Use this section when the release or PR changes `doc/enum_select.md`, the explicit `enum:` source contract, or release evidence for `rfk_enum_select`. Keep this lane separate from the model-backed enum lane above: this section records a Rails enum-shaped explicit hash source, not a general label/value DSL.

- Representative helper:
- Representative field:
- Evidence location:

- [ ] one representative `rfk_enum_select` field used an explicit `enum:` hash source from `doc/enum_select.md`
- [ ] the rendered options submitted the explicit hash keys, not the backing values stored in the hash
- [ ] the rendered labels followed the documented model I18n / humanized fallback boundary for those keys
- [ ] an edit form or validation rerender kept the same selected explicit enum key and redisplayed the matching label for that representative field
- [ ] evidence notes distinguished the explicit Rails enum-shaped hash source from arbitrary label/value pairs, remote enum options, Ransack filters, and table metadata adapter behavior

Notes:

## `rfk_token_search` representative token-entry lane checks

Use this section when a release or narrow PR needs evidence for the `rfk_token_search` helper entry itself. Keep it separate from suggestion metadata and table metadata: this lane records that a representative token-search field rendered and submitted token text through the host app route, not that Rails Fields Kit parsed or executed the search.

- Representative helper: `rfk_token_search(:keyword, url: "/search_suggestions.json", placeholder: "status:open keyword", max_items: 20, load_throttle: 250)`
- Representative field or route: rendered field name `dummy_model[keyword]`; submitted token text remains the value of that host form parameter
- Evidence location: `spec/rails_fields_kit/form_builder_spec.rb` (`renders a token search text input`)

- [ ] the representative `rfk_token_search` field rendered in the expected page or source-reviewed helper call
- [ ] submitted token text or the observed query param shape was recorded for the host app route under review
- [ ] if suggestions were also in scope, their `rfk_token_suggestions_with`, `TokenSuggestions.build`, or `RansackSuggestions.build` evidence was recorded separately in the metadata lane below
- [ ] the evidence note made clear that token parsing, `params[:q]` construction, saved-search resolution, Ransack execution, query authorization, table persistence, and user-visible results remain host-app responsibilities
- [ ] `SOURCE REVIEW ONLY` or `DEFERRED` was used when a browser/sample-app run was not actually performed

Notes:

### Focused result: `rfk_token_search` entry field split from #3

| Representative lane | Source reviewed | Result | Evidence notes |
| --- | --- | --- | --- |
| Token-search entry field | `rfk_token_search(:keyword, url: "/search_suggestions.json", placeholder: "status:open keyword", max_items: 20, load_throttle: 250)` | `SOURCE REVIEW ONLY` | The helper contract renders a token-search text input named `dummy_model[keyword]`; the host form submits the token text through that parameter. The suggestion URL configures option loading and is not the form submission route. No browser or host sample app was run in this environment. |

Run `bundle exec rspec spec/rails_fields_kit/form_builder_spec.rb` before promoting the helper contract to automated `PASS`, and record the exact branch / commit and workflow URL in the scoped PR comment. No inconsistency was found during source review.

Suggestion payload structure belongs in the metadata lane below; Ransack suggestion metadata and table metadata remain separate evidence lanes. Token parsing, `params[:q]` construction, query execution, authorization, Ransack relation construction, saved-search resolution or persistence, table persistence, and user-visible results remain host-app responsibilities.

## Token suggestion and Ransack suggestion metadata checks

- [ ] `rfk_token_suggestions_with(..., wrap: "options")` returns the documented wrapped suggestion payload
- [ ] operator suggestions such as `OR` or `not()` use the documented option fields
- [ ] field suggestions such as `status:` and `assignee:` match the documented labels and descriptions
- [ ] value suggestions such as `status:open` and `status:closed` are returned when configured
- [ ] saved-search suggestions such as `saved:mine` return the expected label and optional description
- [ ] the sample app still treats submitted token text as a host-app parsing concern
- [ ] Ransack field suggestions expose `ransack_predicate` and `ransack_field` when that release surface is in scope
- [ ] Ransack value suggestions preserve `ransack_value` and any documented extra metadata when that release surface is in scope
- [ ] the same allowed field list drove both the documented suggestion builder config and the host-app parser whitelist
- [ ] submitted token text was turned into `params[:q]` by the host app parser or search object, not by Rails Fields Kit
- [ ] the sample app treated Ransack suggestion payload as metadata only, not as query execution performed by the gem

Notes:

## Visible feedback checks

- [ ] `placeholder` copy reads as intended before interaction
- [ ] `loading_text` appears during remote search and clears after the response returns
- [ ] `no_results_text` appears for empty search responses
- [ ] `create_text` shows the intended affordance when create-on-the-fly is enabled
- [ ] `create-error` handling produces visible host-app feedback when create fails
- [ ] an `error_surface: true` field exposed a usable inline placeholder during a representative request failure
- [ ] a representative `error_surface_html:` field preserved its custom wrapper class or attrs without losing the shared placeholder `id`, hidden default, `role`, `aria-live`, or `aria-atomic` contract
- [ ] request-failure events for that custom placeholder field still surfaced the same inline placeholder through `event.detail.surface`
- [ ] stale inline error content cleared after success or a follow-up interaction when the message stayed inside the placeholder
- [ ] a comparable field without `error_surface: true` kept the default no-inline-placeholder behavior

Notes:

## Table metadata checks

Use this section when table metadata is part of the release surface, or when `doc/table_metadata_visual_reference.html` is release-critical evidence even though the static artifact itself did not change. When range field table metadata is in scope, use `doc/table_range_field_metadata.md` as the source-of-truth boundary for representative filter and cell editor evidence.

- Visual reference artifact:
- Viewport(s) checked:
- Table metadata lane(s) checked:
  - [ ] filters
  - [ ] Ransack token filter metadata
  - [ ] native field metadata
  - [ ] range field metadata
  - [ ] radio button filter metadata
  - [ ] cell editors
  - [ ] custom helper mapping
- Evidence location:
- [ ] `doc/table_metadata_visual_reference.html` was checked for the same representative lane(s) recorded above when visual evidence is in scope
- [ ] `RailsFieldsKit::TableFilterInput` metadata renders through the documented helper path
- [ ] `RailsFieldsKit::TableCellInput` metadata renders through the documented helper path
- [ ] `rfk_table_filters` renders collected filter metadata
- [ ] `rfk_table_cell_editors` renders collected cell editor metadata
- [ ] native field metadata such as `search_field`, `money_field`, or `text_area` rendered through the documented helper path
- [ ] range field metadata used `TableFilterInput.range_field` or `TableCellInput.range_field` and kept `min`, `max`, and `step` as ordinary native input options
- [ ] range field table metadata evidence stayed separate from native `rfk_range_field` wrapper evidence unless that wrapper lane was also in scope
- [ ] radio button filter metadata kept required `tag_value:` in the call spec and passed it as the positional radio value when `TableRenderer.render_filter` dispatched to `rfk_radio_button`
- [ ] missing radio filter `tag_value:` produced the documented `ArgumentError` before helper dispatch
- [ ] radio button filter metadata stayed separate from the `TableCellInput.radio_button` cell-editor lane and remained renderable control metadata rather than query or grouping behavior
- [ ] direct `TableRenderer` call-spec usage still matches the documented helper / method / options shape when used
- [ ] a representative `TableRenderer.register_field_helper` mapping rendered through the documented call-spec path
- [ ] `TableRenderer.reset_field_helpers!` restored the default mapping after the representative custom helper check
- [ ] table metadata remained rendering assistance only; representative query execution or persistence stayed in the host app / table integration

Notes:

### Focused result: table metadata rendering split from #3

This focused review records only two representative metadata rendering lanes. It does not record token-search helper evidence, Ransack execution, or a full sample-app pass.

| Representative lane | Source reviewed | Result | Evidence notes |
| --- | --- | --- | --- |
| Filter metadata | `TableFilterInput.date_field(:starts_on, min: "2026-01-01")` through `rfk_table_filters` / `rfk_date_field` | `SOURCE REVIEW ONLY` | Factory, renderer mapping, and direct helper path were reviewed. No browser or host sample app was run in this environment. |
| Cell editor metadata | `TableCellInput.enum_select(:status)` through `rfk_table_cell_editors` / `rfk_enum_select` | `SOURCE REVIEW ONLY` | Metadata order, renderer mapping, and safe-buffer direct helper specs were reviewed. No browser or host sample app was run in this environment. |

Run `bundle exec rspec spec/rails_fields_kit/table_metadata_spec.rb spec/rails_fields_kit/table_renderer_spec.rb spec/rails_fields_kit/form_builder_table_metadata_safe_buffer_spec.rb` before promoting either row to automated `PASS`, and record the exact branch / commit and workflow URL in the scoped PR comment. No inconsistency was found during source review. Table persistence, query execution, Ransack relation construction, authorization, sorting, pagination, visual approval, and final table layout remain host-app or table-integration responsibilities. The `rfk_token_search` entry-field lane remains separate.

### Focused result: radio button filter metadata

| Representative lane | Source reviewed | Result | Evidence notes |
| --- | --- | --- | --- |
| Radio button filter metadata | `TableFilterInput.radio_button(:status, tag_value: "published", label: "Published")` through `TableRenderer.filter_call` / `render_filter` / `rfk_radio_button` | `SOURCE REVIEW ONLY` | Factory, call-spec mapping, required `tag_value:`, positional renderer dispatch, and focused specs were source-reviewed. No browser or host sample app was run in this environment. `TableCellInput.radio_button` remains the separate #2383 cell-editor evidence lane. |

Run `bundle exec rspec spec/rails_fields_kit/table_radio_button_metadata_spec.rb spec/rails_fields_kit/table_renderer_radio_button_filter_spec.rb` before promoting this result to automated `PASS`, and record the exact branch / commit and workflow URL in the scoped PR comment. No inconsistency was found during source review. Query execution, params construction, same-name grouping, `fieldset` / `legend`, collection radio groups, table persistence, production styling, and visual approval remain host-app, table-integration, or separate evidence responsibilities.

## Turbo reconnect checks

- Evidence location:
- Tested lane(s):
  - [ ] selected preload
  - [ ] remote search
  - [ ] create-on-the-fly
  - [ ] visible request-failure feedback
  - [ ] other:
- [ ] Tom Select initializes on first render without a host-app `setupXxx()` helper
- [ ] Turbo-driven validation rerender reconnects the replaced field without duplicate Tom Select initialization
- [ ] same-form revisit through Turbo reconnects the field without duplicate Tom Select initialization
- [ ] representative selected preload, remote search, and create-on-the-fly lanes still work after reconnect when they are in scope for this release
- [ ] pending requests from a disconnected field did not leave stale success or error UI in the manually observed result; deeper request lifecycle guarantees stay in the runtime quality lane
- [ ] no separate `turbo:load` reinitializer was needed for normal `rfk_*` usage

Notes:
- Remaining caveats / follow-up:

## Event checks

- [ ] `rails-fields-kit--tom-select:load`
- [ ] `rails-fields-kit--tom-select:load-error`
- [ ] `rails-fields-kit--tom-select:selected-load`
- [ ] `rails-fields-kit--tom-select:selected-load-error`
- [ ] `rails-fields-kit--tom-select:create`
- [ ] `rails-fields-kit--tom-select:create-error`
- [ ] `rails-fields-kit--tom-select:change`
- [ ] `rails-fields-kit--tom-select:item-add`
- [ ] `rails-fields-kit--tom-select:item-remove`
- [ ] `rails-fields-kit--tom-select:clear`
- [ ] a representative selected preload success dispatched `selected-load` with the requested saved value or values and resolved options
- [ ] a representative selected preload failure dispatched `selected-load-error` separately from remote search and create-on-the-fly failures
- [ ] selected preload event evidence stayed tied to the `selected_url:` lane rather than ordinary remote search
- [ ] a representative single select or combobox dispatched `change` when the selected value changed
- [ ] a representative multiple select or tags field dispatched `item-add` and `item-remove` for add/remove actions
- [ ] a representative clearable field dispatched `clear` when its selected value was cleared
- [ ] interaction forwarding events were recorded separately from remote `load` / `load-error`, selected preload, create-on-the-fly, and visible-feedback lanes
- [ ] create-on-the-fly success dispatched the dedicated `create` event before the normal selection events continued
- [ ] `event.detail.input` matched the submitted text for the create success case
- [ ] `event.detail.option` exposed the created option payload needed by the host app
- [ ] `item-add` and `change` still matched the accepted selection after dedicated create success
- [ ] request-failure events for an `error_surface: true` field exposed `event.detail.surface`
- [ ] a comparable field without `error_surface: true` kept `event.detail.surface` at `null`
- [ ] stale inline error content cleared after a fresh request or follow-up interaction when the message stayed inside the placeholder

Notes:

## Release notes

- [ ] Version-specific release note draft reviewed or updated

Notes:

## Decision

- [ ] Ready to publish
- [ ] Needs fixes before publishing

Summary:
