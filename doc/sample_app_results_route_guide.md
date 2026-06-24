# Sample App Results Route Guide

Use this companion note when a release or PR needs manual evidence but the full `sample_app_results.md` checklist feels too broad for the change under review. It is a scanability aid for choosing the right recording lane; it does not add a release gate, change runtime behavior, or replace the full checklist.

## Choose the Evidence Location

| Review situation | Record in `sample_app_results.md` | Record in PR comment | Do not record as |
| --- | --- | --- | --- |
| Release candidate or release PR | Yes. Fill the release-wide baseline and any feature-specific lane that changed. | Optional summary only. | A feature-only spot check. |
| Narrow static visual reference PR | Only when the artifact is release-critical or the release evidence log is being refreshed. | Usually yes. Name the artifact, viewport, lane, result, and blocker. | CI success as visual approval. |
| Source-only or connector-only visual review | Use `SOURCE REVIEW ONLY` or `DEFERRED` if the evidence log is in scope. | Yes. State what source was checked and what browser pass remains. | Browser `PASS`. |
| Package-root helper or setup visibility PR | Use the package-root helper or setup lane only if that surface changed. | Yes for narrow PR proof. | A release-wide helper inventory. |
| Runtime helper behavior PR | Use the nearest helper lane when manual sample-app evidence is required. | Yes for scoped test or CI notes. | Static visual artifact approval. |
| Selected preload ordering evidence | Use the selected preload representative lane only when the PR or release depends on preserved selected-label ordering. | Yes for a narrow `rfk_find_with preserve_order: true` docs or evidence PR. | A new ordering SQL, authorization, or endpoint scoping contract. |
| Token search entry evidence | Use the token-search representative entry lane when the PR or release depends on `rfk_token_search` helper rendering or submitted token text. | Yes for a narrow token-search sample docs PR. | Token parser behavior, query execution, Ransack execution, or table metadata approval. |

## Focused Representative Lanes

Use these focused lanes when the full results checklist is too broad for the PR, but reviewers still need a named sample-app evidence shape.

### Selected preload with preserved request order

Record this lane when a selected preload endpoint uses `rfk_find_with(..., preserve_order: true)` and the review needs evidence that visible selected labels follow the requested saved ID order.

A scoped evidence note should include:

- Representative field and selected preload endpoint.
- Incoming selected ID order, such as `ids=3,1,2`.
- Observed label order after selected preload resolves.
- Whether the field is single-value or multiple-value, and any custom `selected_multiple_param:` key if relevant.
- Confirmation that ordering SQL, endpoint authorization, relation scope, retry UI, and final fallback copy remain host-app responsibilities.

Do not treat this lane as a new database-ordering contract. It records that the sample endpoint returned labels in the request order after the host app supplied the scoped records.

### `rfk_token_search` representative token entry

Record this lane when the review needs evidence for the token-search helper itself, separate from token suggestion metadata.

A scoped evidence note should include:

- Representative `rfk_token_search` field and route or page.
- Rendered helper state or source-reviewed helper call.
- Submitted token text or query param shape observed by the host app.
- Whether suggestion metadata was checked separately through `rfk_token_suggestions_with`.
- Confirmation that token parsing, saved-search resolution, query execution, authorization, Ransack execution, table filter behavior, and user-visible search results remain host-app responsibilities.

Do not use this lane to approve the suggestion payload, shared metadata source, or table metadata adapter. Those belong in the token suggestion, Ransack suggestion, or table metadata lanes.

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

## Boundaries

- Keep release-wide baseline evidence separate from feature-specific helper, visual, remote, token, or table lanes.
- Do not turn a feature-specific lane into a release-wide requirement without a separate release policy decision.
- Do not record sample app evidence that was not actually run.
- Do not redesign visual artifacts, helper behavior, setup doctor output, or release policy from this guide.
- Use `sample_app_results.md` as the full evidence log when a release or release-critical PR needs the detailed checklist.
