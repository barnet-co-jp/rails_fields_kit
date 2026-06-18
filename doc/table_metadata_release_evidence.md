# Table metadata release evidence

Use this guide when a release or focused PR needs sample app evidence for table metadata rendering, group-level wrappers, or the TableRenderer registry. Keep it as a narrow companion to `doc/sample_app_checklist.md` and record the actual result in `doc/sample_app_results.md` or the PR comment for the scoped change.

## Source of truth

- Use `doc/public_api.md` for current public TableRenderer method names.
- Use `doc/table_adapters.md` for table metadata, call-spec, renderer registry, and host-app responsibility boundaries.
- Use `doc/table_group_html.md` for the direct FormBuilder `group_html:` wrapper boundary.

This guide does not define new runtime behavior. It only helps reviewers choose representative sample app checks.

## Choose the scoped lane

| Change in scope | Representative evidence | Keep out of scope |
| --- | --- | --- |
| Direct table helper group wrappers | One `rfk_table_filters` or `rfk_table_cell_editors` sample that passes `group_html:` and shows one outer group wrapper around joined output | Field-level `wrapper_html:` behavior changes, table layout ownership, query execution, persistence, authorization |
| TableRenderer registry introspection | One custom helper registration where `registered_field_types` includes the custom type, followed by cleanup with `reset_field_helpers!` or `unregister_field_helper` | Redesigning registry return shapes, changing helper names, adding metadata persistence |
| Custom-only unregister cleanup | A custom-only mapping is removed with `unregister_field_helper`, then the type is no longer renderable | Removing built-in mappings or changing built-in factory `known_types` |
| Built-in override fallback | A built-in field type is temporarily registered to a custom helper, then `unregister_field_helper` restores the built-in default helper | Treating the override as a permanent helper remapping or changing public fallback semantics |

## Checklist items

When the lane is in scope, confirm only the relevant items below:

- [ ] `group_html:` adds attributes to one outer table-helper group wrapper while each rendered field keeps its own field-level wrapper behavior.
- [ ] Evidence notes distinguish group-level `group_html:` from field-level `wrapper_html:`.
- [ ] A representative custom field helper registration is renderable through the documented call-spec path.
- [ ] `RailsFieldsKit::TableRenderer.registered_field_types` exposes renderable custom types without exposing helper method names.
- [ ] `RailsFieldsKit::TableFilterInput.known_types` and `RailsFieldsKit::TableCellInput.known_types` remain limited to the built-in factory family.
- [ ] `RailsFieldsKit::TableRenderer.unregister_field_helper` removes a custom-only mapping from the current registry.
- [ ] Unregistering a custom override for a built-in field type restores the built-in default helper.
- [ ] Query execution, preference persistence, authorization, pagination, visible save/error copy, and final table layout remain host-app or table integration responsibilities.

## Result template

Copy the compact result into `doc/sample_app_results.md` for release candidates, or into a PR comment for a narrow docs/spec change.

| Evidence lane | Representative sample | Result | Notes |
| --- | --- | --- | --- |
| Table helper `group_html:` |  |  |  |
| TableRenderer custom registry |  |  |  |
| TableRenderer unregister cleanup |  |  |  |
| Built-in override fallback |  |  |  |

Use `PASS` only for checks actually exercised. Use `OUT OF SCOPE` when the lane was reviewed and deliberately excluded from the release or PR scope.
