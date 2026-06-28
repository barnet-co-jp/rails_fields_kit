# Sample App Results Route Guide

Use this companion note when a release or PR needs manual evidence but the full `sample_app_results.md` checklist feels too broad for the change under review. It is a scanability aid for choosing the right recording lane; it does not add a release gate, change runtime behavior, or replace the full checklist.

## Choose the Evidence Location

| Review situation | Record in `sample_app_results.md` | Record in PR comment | Do not record as |
| --- | --- | --- | --- |
| Release candidate or release PR | Yes. Fill the release-wide baseline and any feature-specific lane that changed. | Optional summary only. | A feature-only spot check. |
| Narrow static visual reference PR | Only when the artifact is release-critical or the release evidence log is being refreshed. | Usually yes. Name the artifact, viewport, lane, result, and blocker. | CI success as visual approval. |
| Turbo reconnect visual reference route | Only when the release or release candidate depends on Turbo reconnect visual evidence. | Usually yes. Name the Turbo reconnect artifact, restored-wrapper lane, viewport, and whether the result is browser-run or deferred. | Turbo lifecycle, Stimulus boot policy, or Tom Select reconnect behavior approval. |
| SetupDoctor output review | Use the Setup doctor checks lane only when a release candidate, release PR, or setup-focused change depends on CLI diagnostic evidence. | Yes for a narrow setup-doctor or setup-visibility PR. Name the command, setup path, representative status lines, wrapping surface, and result. | Host-app CI pass/fail policy, auto-fix approval, Tom Select install approval, Stimulus boot policy, CSS pipeline approval, or bundler alias confirmation. |
| Source-only or connector-only visual review | Use `SOURCE REVIEW ONLY` or `DEFERRED` if the evidence log is in scope. | Yes. State what source was checked and what browser pass remains. | Browser `PASS`. |
| Package-root helper or setup visibility PR | Use the package-root helper or setup lane only if that surface changed. | Yes for narrow PR proof. | A release-wide helper inventory. |
| Runtime helper behavior PR | Use the nearest helper lane when manual sample-app evidence is required. | Yes for scoped test or CI notes. | Static visual artifact approval. |
| Selected preload ordering evidence | Use the selected preload representative lane only when the PR or release depends on preserved selected-label ordering. | Yes for a narrow `rfk_find_with preserve_order: true` docs or evidence PR. | A new ordering SQL, authorization, or endpoint scoping contract. |
| Remote search minimum query length evidence | Use the remote lifecycle lane only when the PR or release depends on endpoint-side blank-query policy. | Yes for a narrow `rfk_search_with minimum_query_length:` docs or evidence PR. Name the blank query, short query, `wrap:` shape, and result. | Field-level `min_length:` approval, authorization policy, tenant scoping, Ransack execution, Tom Select lifecycle approval, or visible feedback approval. |
| Token search entry evidence | Use the token-search representative entry lane when the PR or release depends on `rfk_token_search` helper rendering or submitted token text. | Yes for a narrow token-search sample docs PR. | Token parser behavior, query execution, Ransack execution, suggestion payload approval, or table metadata approval. |
| Token or Ransack suggestion metadata evidence | Use the token suggestion and Ransack suggestion metadata lane only when the PR or release depends on `TokenSuggestions.build`, `RansackSuggestions.build`, or `rfk_token_suggestions_with` payloads. | Yes for a narrow metadata/docs PR that names the checked builder or endpoint shape. | `rfk_token_search` helper rendering approval, submitted token parsing, query execution, Ransack execution, table persistence, or user-visible search result approval. |

## Focused Representative Lanes

Use these focused lanes when the full results checklist is too broad for the PR, but reviewers still need a named sample-app evidence shape.

### SetupDoctor output review

Record this lane when the review needs evidence for the human-readable `rails rails_fields_kit:doctor` diagnostic output rather than field UI, setup doctor JSON, generator behavior, or host-app setup policy.

A scoped evidence note should include:

- Command and setup path, such as importmap, jsbundling, bundler-managed JavaScript, or another host-app route.
- Representative status lines, such as first-run legend, `[OK]` / `[MISSING]` / `[MANUAL]` setup checks, target mismatch, Stimulus registration advisory, CSS import advisory, or unresolved import diagnostics.
- Whether the evidence belongs in a narrow PR comment or the release-wide `sample_app_results.md` Setup doctor checks lane.
- Result word: `PASS`, `FAIL`, `SOURCE REVIEW ONLY`, or `DEFERRED`, with the terminal width, GitHub PR comment code block, or Markdown preview surface when wrapping readability is in scope.
- Confirmation that `[MANUAL]` lines remain host-app responsibility checks, not automatic failures.
- Confirmation that host-app CI pass/fail policy, auto-fix behavior, Tom Select package install, Stimulus boot policy, CSS pipeline, bundler aliases, and setup doctor JSON payloads remain out of scope.

Do not use this lane to approve frontend setup ownership. Human-readable CLI diagnostic evidence stays in `doc/setup_doctor_output_review.md`; machine-readable JSON payload evidence stays in `doc/setup_doctor_machine_readable.md`.

### Turbo reconnect focused visual reference

Record this lane when the review needs visual evidence for `doc/tom_select_turbo_reconnect_visual_reference.html` and the change is about static restored-wrapper readability rather than runtime reconnect behavior.

A scoped evidence note should include:

- Artifact: `doc/tom_select_turbo_reconnect_visual_reference.html`.
- Viewport and lane, such as desktop restored-wrapper, narrow restored-wrapper, ordinary settled field, or duplicate-wrapper caution.
- Whether the evidence was a real browser `PASS`, `SOURCE REVIEW ONLY`, or `DEFERRED`.
- Whether the evidence belongs in a narrow PR comment or the release-wide `sample_app_results.md` log.
- Confirmation that Turbo reconnect cleanup, Stimulus boot policy, Tom Select instance lifecycle, request cancellation, stale-response guards, production CSS, and screenshot approval policy remain out of scope.

Do not use this lane to approve reconnect behavior. Runtime lifecycle checks stay in `doc/tom_select_turbo_lifecycle.md`, JavaScript checks, or host-app QA notes.

### Selected preload with preserved request order

Record this lane when a selected preload endpoint uses `rfk_find_with(..., preserve_order: true)` and the review needs evidence that visible selected labels follow the requested saved ID order.

A scoped evidence note should include:

- Representative field and selected preload endpoint.
- Incoming selected ID order, such as `ids=3,1,2`.
- Observed label order after selected preload resolves.
- Whether the field is single-value or multiple-value, and any custom `selected_multiple_param:` key if relevant.
- Confirmation that ordering SQL, endpoint authorization, relation scope, retry UI, and final fallback copy remain host-app responsibilities.

Do not treat this lane as a new database-ordering contract. It records that the sample endpoint returned labels in the request order after the host app supplied the scoped records.

### Remote search minimum query length

Record this lane when a remote search endpoint uses `rfk_search_with(..., minimum_query_length: ...)` and the review needs evidence for endpoint-side blank or short query handling.

A scoped evidence note should include:

- Representative field, remote search endpoint, and query param key.
- Endpoint configuration, including `minimum_query_length:` and `wrap:` when used.
- Blank query and short-query requests that are below the endpoint minimum.
- Observed empty options payload, including whether the configured wrapper shape such as `{ "options": [] }` was preserved.
- A comparison note that field-level `min_length:` is only a browser-side load gate, while `minimum_query_length:` is the server endpoint policy for direct requests or custom Tom Select configs.
- Confirmation that authorization, tenant scoping, query parsing, Ransack integration, Tom Select request lifecycle, visible feedback copy, and retry UI remain host-app or existing-doc responsibilities.

Do not use this lane to approve field-level `min_length:` behavior or remote lifecycle UI. It records the controller helper's endpoint response boundary for too-short queries.

### `rfk_token_search` representative token entry

Record this lane when the review needs evidence for the token-search helper itself, separate from token suggestion metadata.

A scoped evidence note should include:

- Representative `rfk_token_search` field and route or page.
- Rendered helper state or source-reviewed helper call.
- Submitted token text or query param shape observed by the host app.
- Whether suggestion metadata was checked separately through `rfk_token_suggestions_with`.
- Confirmation that token parsing, saved-search resolution, query execution, authorization, Ransack execution, table filter behavior, and user-visible search results remain host-app responsibilities.

Do not use this lane to approve the suggestion payload, shared metadata source, or table metadata adapter. Those belong in the token suggestion, Ransack suggestion, or table metadata lanes.

### Token and Ransack suggestion metadata

Record this lane when the review needs evidence for suggestion payloads, separate from the `rfk_token_search` entry field.

A scoped evidence note should include:

- Representative token suggestion endpoint or source-reviewed `TokenSuggestions.build` call.
- Operator, field, value, and saved-search suggestion examples that were checked.
- Representative `RansackSuggestions.build` payload when Ransack-compatible metadata is in scope, including field, predicate, and value metadata.
- Whether the `rfk_token_search` helper entry field was checked separately through the token-entry lane.
- Confirmation that submitted token parsing, `params[:q]` construction, Ransack execution, query authorization, table persistence, and user-visible search results remain host-app responsibilities.

Do not use this lane to approve helper rendering or submitted token text. Those belong in the token-entry lane above. Do not use it to approve table filter rendering or table persistence; table metadata evidence has its own lane.

## Visual Reference Result Words

| Result | Use it when | Evidence note should include |
| --- | --- | --- |
| `PASS` | A real browser checked the named artifact, viewport, and lane. | Browser, viewport, lane/state, and responsibility boundary. |
| `FAIL` | A real browser check found overlap, clipping, unreadable copy, or another visual issue. | The failing viewport/lane and next fix. |
| `SOURCE REVIEW ONLY` | The changed HTML/CSS or Markdown was reviewed but not rendered in a browser. | File/diff reviewed and the remaining browser-capable check. |
| `DEFERRED` | Browser-capable evidence is intentionally handed off. | Handoff owner/context, artifact, viewport, and reason. |

Do not use `PASS` for GitHub Actions success, source review, static diff review, or a successful package build. Those checks can support a PR, but they are not visual approval for a static visual reference.

## Quick PR Comment Shape

Use a short PR comment when the change is narrow and the release evidence log is not being updated.

```markdown
Visual evidence note

- Artifact or lane: `doc/...`
- Viewport: desktop / narrow / not rendered
- Checked here: source review / browser pass / CI / docs link review
- Result: PASS / FAIL / SOURCE REVIEW ONLY / DEFERRED
- Responsibility boundary: runtime behavior, production CSS, host-app copy, or release policy remains out of scope
- Remaining follow-up: ...
```

If the note says `SOURCE REVIEW ONLY` or `DEFERRED`, name the missing browser-capable check instead of treating the PR as visually approved.

### SetupDoctor evidence PR comment shape

Use this shape when SetupDoctor human-readable output evidence is narrow enough for a PR comment instead of the release evidence log.

```markdown
SetupDoctor evidence note

- Lane: setup doctor output review
- Command and setup path: `rails rails_fields_kit:doctor`, importmap / jsbundling / bundler-managed JavaScript / other
- Representative state: first-run mixed status / Stimulus registration advisory / CSS import advisory / importmap target mismatch / unresolved import diagnostics
- Checked here: source review / terminal run / wrapped Markdown review / CI / docs link review
- Result: PASS / FAIL / SOURCE REVIEW ONLY / DEFERRED
- Evidence observed: representative `[OK]`, `[MISSING]`, or `[MANUAL]` lines; width or preview surface if wrapping was checked
- Responsibility boundary: host-app CI policy, auto-fix behavior, Tom Select install, Stimulus boot policy, CSS pipeline, bundler aliases, and setup doctor JSON payloads remain out of scope
- Remaining follow-up: ...
```

If the note only reviewed source or docs, use `SOURCE REVIEW ONLY` and do not mark host-app setup execution as complete.

### Token evidence PR comment shape

Use this shape when token-search or suggestion metadata evidence is narrow enough for a PR comment instead of the release evidence log.

```markdown
Token evidence note

- Lane: token entry / token suggestion metadata / Ransack suggestion metadata / shared metadata source
- Representative field, endpoint, or builder: `...`
- Checked here: source review / sample app route / CI / docs link review
- Result: PASS / FAIL / SOURCE REVIEW ONLY / DEFERRED
- Evidence observed: rendered helper state, submitted token text, wrapped option payload, Ransack metadata, or shared source derivation
- Separate lane checked: yes/no, and link or note if the token entry field and suggestion metadata were both exercised
- Responsibility boundary: token parsing, `params[:q]` construction, Ransack execution, query authorization, table persistence, and user-visible results remain host-app responsibilities
- Remaining follow-up: ...
```

If the note only reviewed source or docs, use `SOURCE REVIEW ONLY` and do not mark sample-app execution as complete.

### Remote search minimum query length evidence PR comment shape

Use this shape when `rfk_search_with minimum_query_length:` evidence is narrow enough for a PR comment instead of the release evidence log.

```markdown
Remote search endpoint evidence note

- Lane: remote search minimum query length
- Representative field and endpoint: `...`
- Endpoint configuration: `minimum_query_length: ...`, `wrap: ...`, `query_param: ...`
- Checked here: source review / sample app route / request spec / CI / docs link review
- Result: PASS / FAIL / SOURCE REVIEW ONLY / DEFERRED
- Evidence observed: blank query result, short-query result, preserved wrapper shape such as `{ "options": [] }`, and comparison with the normal allowed query result when checked
- Separate lane checked: yes/no, and link or note if field-level `min_length:` or visible feedback was checked elsewhere
- Responsibility boundary: authorization, tenant scoping, query parsing, Ransack execution, Tom Select lifecycle, visible feedback copy, and retry UI remain host-app responsibilities
- Remaining follow-up: ...
```

If the note only reviewed source or docs, use `SOURCE REVIEW ONLY` and do not mark sample-app execution as complete.

## Boundaries

- Keep release-wide baseline evidence separate from feature-specific helper, visual, remote, token, table, or setup-doctor lanes.
- Do not turn a feature-specific lane into a release-wide requirement without a separate release policy decision.
- Do not record sample app evidence that was not actually run.
- Do not redesign visual artifacts, helper behavior, setup doctor output, or release policy from this guide.
- Use `sample_app_results.md` as the full evidence log when a release or release-critical PR needs the detailed checklist.
