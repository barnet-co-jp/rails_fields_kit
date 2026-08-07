# Token and table sample app evidence

Use this guide when a release or focused PR needs sample app evidence for token search, token suggestions, Ransack suggestion metadata, or table metadata rendering. Keep it as a narrow companion to `doc/sample_app_checklist.md` and record the actual result in `doc/sample_app_results.md` for release candidates or in a PR comment for scoped work.

This guide exists to keep token search evidence and table metadata evidence separate after the older combined sample-app issue was split. It does not define new runtime behavior, new release gates, or a broader sample app matrix.

## Source of truth

- Use `doc/token_suggestions.md` for token suggestion payload fields, operator / field / value / saved-search examples, and the host-app parser boundary.
- Use `doc/ransack_suggestions.md` for Ransack suggestion metadata and the boundary between suggestion metadata and host-app query execution.
- Use `doc/table_adapters.md` for table filter / cell editor metadata, call-spec rendering, renderer registry, and host-app table responsibility boundaries.
- Use `doc/table_metadata_release_evidence.md` when a table metadata PR needs a more detailed table-specific evidence lane.
- Use `doc/sample_app_checklist.md` to choose whether evidence belongs in a release result file or a narrow PR comment.
- Use `doc/sample_app_results.md` only as the release evidence log, not as a source of new behavior.

## Choose the scoped lane

| Change in scope | Representative evidence | Record in | Keep out of scope |
| --- | --- | --- | --- |
| `rfk_token_search` helper or token-search setup | One representative rendered token-search field plus one suggestion endpoint response shape | PR comment for narrow work; `doc/sample_app_results.md` for release candidates | token parsing, query execution, authorization, saved-search policy, result filtering |
| `rfk_token_suggestions_with` or `RailsFieldsKit::TokenSuggestions.build` | One wrapped response with operator, field, value, or saved-search suggestion metadata that matches the docs | PR comment or release evidence log, depending on scope | treating suggestions as parser output or a query execution API |
| `RailsFieldsKit::RansackSuggestions.build` | One representative field / predicate / value metadata payload that a host app parser or search object can consume | PR comment or release evidence log, depending on scope | requiring Ransack, executing `params[:q]`, or owning the host app allowlist |
| `rfk_table_filters` / `rfk_table_cell_editors` | One representative table filter or cell editor rendered through the documented helper path | PR comment for scoped metadata work; `doc/sample_app_results.md` for release candidates | table persistence, query execution, authorization, pagination, visible save/error copy |
| TableRenderer or TableMetadata collection shape | One representative call-spec or renderer registry check selected from `doc/table_metadata_release_evidence.md` | PR comment or release evidence log, depending on scope | redesigning renderer APIs, changing helper names, adding metadata persistence |

## Checklist items

When token evidence is in scope, confirm only the relevant items below:

- [ ] `rfk_token_search` rendered as a token-oriented search field without taking over host-app parsing.
- [ ] `rfk_token_suggestions_with` returned documented option JSON for the representative endpoint.
- [ ] Operator, field, value, or saved-search suggestions matched the current docs for the representative lane.
- [ ] If Ransack suggestion metadata was in scope, `ransack_predicate`, `ransack_field`, and any representative `ransack_value` metadata stayed payload metadata only.
- [ ] Evidence notes made clear that submitted token text is parsed and executed by the host app, not by Rails Fields Kit.

When table metadata evidence is in scope, confirm only the relevant items below:

- [ ] `RailsFieldsKit::TableFilterInput` metadata rendered through the documented helper path.
- [ ] `RailsFieldsKit::TableCellInput` metadata rendered through the documented helper path.
- [ ] `rfk_table_filters` or `rfk_table_cell_editors` rendered the collected metadata chosen for the representative lane.
- [ ] If custom renderer registry behavior was in scope, the evidence stayed limited to the documented call-spec and registry helper lane.
- [ ] Evidence notes made clear that query execution, preference persistence, authorization, pagination, visible save/error copy, and final table layout remain host-app or table integration responsibilities.

## RansackSuggestions focused evidence decision

For the focused `RailsFieldsKit::RansackSuggestions.build` review split from the combined sample-app queue, record the result in the narrow PR comment rather than filling the release-wide `doc/sample_app_results.md` log. This lane has no rendered field or table UI to approve: it verifies Ruby suggestion metadata that a host-app parser or search object may consume.

Use these representative signals and keep them separate from `rfk_token_search` rendering and table metadata evidence:

| Signal | Representative source | Expected evidence |
| --- | --- | --- |
| Predicate alias | `customer: { ransack_predicate: :customer_name_cont }` | The field option exposes `ransack_field: "customer"` and `ransack_predicate: "customer_name_cont"`. |
| Value metadata | `created: { predicate: :created_at_gteq, values: [{ value: "today", range: "day" }] }` | The value option preserves `ransack_value: "today"` and custom `range: "day"` metadata. |
| Custom output mapping | `value_field: "token"`, `label_field: "label"`, `description_field: "help"`, `badge_field: "kind"` | The configured output keys replace the defaults while the Ransack field and predicate metadata remain available. |

Run the focused Ruby check when recording `PASS`:

```bash
bundle exec rspec spec/rails_fields_kit/ransack_suggestions_spec.rb
```

A scoped evidence comment must name the branch or commit, command, result, and the three representative signals above. If the Ruby check was not run, use `SOURCE REVIEW ONLY` or `DEFERRED`; do not infer `PASS` from docs review. Ransack gem setup, submitted-token parsing, `params[:q]` construction, allowed-predicate enforcement, relation construction, authorization, pagination, and result rendering remain host-app responsibilities. This focused lane does not approve the `rfk_token_search` UI or any table metadata rendering lane.

## Result template

Copy the compact result into `doc/sample_app_results.md` for release candidates, or into a PR comment for a narrow docs/spec change.

| Evidence lane | Representative sample | Result | Notes |
| --- | --- | --- | --- |
| Token search rendered field |  |  |  |
| Token suggestion payload |  |  |  |
| Ransack suggestion metadata |  |  |  |
| Table filter metadata |  |  |  |
| Table cell editor metadata |  |  |  |
| TableRenderer / TableMetadata registry or call-spec |  |  |  |

Use `PASS` only for checks actually exercised. Use `OUT OF SCOPE` when the lane was reviewed and deliberately excluded from the release or PR scope. Use `DEFERRED` when a browser-capable or sample-app-capable check is intentionally handed off.
