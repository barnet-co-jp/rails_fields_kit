# Search Controller Release Evidence

Use this guide when a release or narrow PR needs representative evidence for `rfk_search_with` endpoint-side policy, especially `minimum_query_length:` or `match:`.

Keep this lane separate from FormBuilder loading hints and from host-app search execution. Rails Fields Kit owns the controller helper option contract and JSON option shape. The host app owns authentication, authorization, tenant scoping, adapter-specific SQL, case sensitivity, ranking, pagination, and final query execution policy.

## When to use this guide

Use this guide when the release scope changes or reviews one of these surfaces:

- `rfk_search_with minimum_query_length:` endpoint behavior.
- `rfk_search_with match:` strategy wording or examples.
- Documentation that explains blank-query, too-short-query, or match-strategy evidence.
- PR comments that need a compact source-of-truth for why endpoint policy evidence is enough.

Do not use this guide as a full sample app matrix. If a release candidate explicitly includes remote search endpoint behavior, record the checked route and result in `doc/sample_app_results.md`. For a narrow docs/spec PR, a PR comment can be enough when it names this guide, the helper option under review, and the verification result.

## Representative evidence lanes

### Minimum query length

For `minimum_query_length:`, record one route where the query is shorter than the endpoint minimum. The expected result is an empty options payload that preserves the configured wrapper, for example `{ "options": [] }` when `wrap: "options"` is used.

The evidence should confirm only the endpoint-side policy. It should not claim that Rails Fields Kit owns authorization, tenant scoping, query parsing, Tom Select request lifecycle, visible fallback UI, or retry behavior.

FormBuilder `min_length:` remains a browser-side loading hint. Use both `min_length:` and `minimum_query_length:` only when the UI hint and the endpoint policy intentionally match. Do not treat a browser-side loading hint as evidence that direct endpoint requests are blocked.

### Match strategy

For `match:`, record the configured strategy and one representative query result. Choose the smallest strategy that matches the PR or release question:

- `match: :contains` keeps the default substring search policy.
- `match: :prefix` confirms prefix-only suggestions.
- `match: :exact` confirms an exact query boundary.

A release does not need to execute all three strategies unless the change under review touches the strategy family itself. Source specs or PR comments can cover the non-target strategies when the release scope only needs one representative lane.

The evidence should not standardize adapter-specific SQL, case sensitivity, token parsing, search ranking, pagination, authorization, or query execution beyond the documented Rails Fields Kit helper options.

## Suggested PR comment shape

For a narrow PR, prefer a compact comment instead of editing the full sample app results log:

```text
Search controller release evidence: checked `rfk_search_with minimum_query_length:` on <route>. Query `<q>` returned wrapped empty options as expected. `min_length:` remains browser-side only; authorization, tenant scoping, adapter SQL, ranking, pagination, and visible fallback UI stayed host-app owned. See doc/search_controller_release_evidence.md.
```

For `match:`, name the strategy and the representative query/result instead of mirroring every strategy.

## Source-of-truth docs

- `doc/controller_helpers.md` documents `rfk_search_with`, `minimum_query_length:`, and the endpoint responsibility boundary.
- This guide documents the release-evidence shape for `minimum_query_length:` and `match:` without turning either option into sample-app-wide mandatory evidence.
- `doc/sample_app_results.md` records manual release-candidate evidence only when the release scope actually checks a remote search endpoint.
- `CHANGELOG.md` records shipped public surface changes, but it should not become the evidence log for every endpoint route.
