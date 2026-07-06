# Table metadata release evidence

Use this guide when a release or focused PR needs sample app evidence for table metadata rendering, group-level wrappers, or the TableRenderer registry. Keep it as a narrow companion to `doc/sample_app_checklist.md` and record the actual result in `doc/sample_app_results.md` or the PR comment for the scoped change.

For direct table helper `group_html:` work, this guide is the release evidence route. It helps reviewers choose one representative group-wrapper check without turning `doc/sample_app_results.md` into a full table helper inventory or treating semantic grouping as Rails Fields Kit-owned behavior.

For TableRenderer registry work, this guide is the release evidence route. It helps reviewers choose one representative registration, introspection, and cleanup check without turning the public API docs into an exhaustive manual test checklist.

For table radio button metadata work, this guide is the release evidence route. It helps reviewers choose one representative `TableCellInput.radio_button` check without turning release evidence into a radio filter, collection group, or query-semantics checklist.

For date, time, datetime-local, or color table metadata work, this guide is the release evidence route. It helps reviewers choose one representative native table metadata check without turning evidence into browser picker, timezone, masking, custom picker, query execution, or table persistence approval.

## Source of truth

- Use `doc/public_api.md` for current public TableRenderer method names.
- Use `doc/table_adapters.md` for table metadata, call-spec, renderer registry, and host-app responsibility boundaries.
- Use `doc/table_group_html.md` for the direct FormBuilder `group_html:` wrapper boundary.
- Use `doc/table_radio_button_metadata.md` for the current `TableCellInput.radio_button` cell-editor-only boundary when radio button table metadata is in the sample evidence scope.
- Use `doc/table_date_time_color_metadata.md` for the current date, time, datetime-local, and color table metadata boundary when browser-native date/time/color metadata is in the sample evidence scope.
- Use `doc/native_contact_fields.md` for native contact/search helper ownership boundaries when contact or browser-native search metadata is in the sample evidence scope.

This guide does not define new runtime behavior. It only helps reviewers choose representative sample app checks.

## Choose the scoped lane

| Change in scope | Representative evidence | Keep out of scope |
| --- | --- | --- |
| Direct table helper group wrappers | One `rfk_table_filters` or `rfk_table_cell_editors` sample that passes `group_html:` and shows one outer group wrapper around joined output | Field-level `wrapper_html:` behavior changes, semantic `fieldset` / `legend` ownership, group-level hint/error wiring, table layout ownership, query execution, persistence, authorization |
| TableRenderer registry introspection | One custom helper registration where `registered_field_types` includes the custom type, followed by cleanup with `reset_field_helpers!` or `unregister_field_helper` | Redesigning registry return shapes, changing helper names, adding metadata persistence |
| Custom-only unregister cleanup | A custom-only mapping is removed with `unregister_field_helper`, then the type is no longer renderable | Removing built-in mappings or changing built-in factory `known_types` |
| Built-in override fallback | A built-in field type is temporarily registered to a custom helper, then `unregister_field_helper` restores the built-in default helper | Treating the override as a permanent helper remapping or changing public fallback semantics |
| Radio button table cell editor metadata | One `TableCellInput.radio_button` sample that records required `tag_value:`, checked and unchecked representative states, and the rendered call-spec path to `rfk_radio_button` | `TableFilterInput.radio_button`, same-name grouping policy, boolean or enum query semantics, `fieldset` / `legend` builders, collection radio groups, table persistence, authorization, production CSS |
| Date/time/color table metadata | One `TableFilterInput.date_field`, `time_field`, `datetime_local_field`, or `color_field` sample, or the matching `TableCellInput` sample, that records native option pass-through and the rendered call-spec path to the matching `rfk_*` helper | Browser-native picker behavior, timezone or locale formatting, masking, custom picker UI, browser validation-message policy, query execution, table persistence, authorization, production CSS |
| Native contact/search table metadata | One or two `TableFilterInput` or `TableCellInput` examples using `email_field`, `url_field`, `phone_field`, or browser-native `search_field`, with rendered wrapper and metadata notes | Email deliverability, URL normalization, phone formatting, server-side validation, remote suggestions, token parsing, query execution |

## Direct table helper group-wrapper evidence route

Use this route when a release, PR, or review question mentions `rfk_table_filters(..., group_html: ...)`, `rfk_table_cell_editors(..., group_html: ...)`, or the group-level wrapper boundary from `doc/table_group_html.md`.

1. Start from `doc/table_group_html.md` for the current `<div>` attribute pass-through contract and host-app semantic grouping boundary.
2. Exercise one representative direct helper call, either `rfk_table_filters` or `rfk_table_cell_editors`, with `group_html:` adding a class plus one `data` or `aria` attribute to the outer wrapper.
3. Record that each rendered field keeps its own helper options and field-level `wrapper_html:` behavior inside the group.
4. Record whether the result belongs in the release-wide `doc/sample_app_results.md` table metadata lane or in a scoped PR comment for a narrow docs/spec change.
5. Put the final `PASS`, `FAIL`, `SOURCE REVIEW ONLY`, `DEFERRED`, or `OUT OF SCOPE` note in the chosen evidence location.

Keep this lane representative. Do not require both filter and cell-editor helpers, every table metadata type, or every possible wrapper attribute unless the release or PR actually changes those surfaces. If a screen needs `fieldset`, `legend`, group hint text, group error copy, or group-level `aria-describedby`, record that as host-app-owned surrounding markup rather than Rails Fields Kit `group_html:` evidence.

## Radio button table cell-editor evidence route

Use this route when a release, PR, or review question mentions `TableCellInput.radio_button`, `doc/table_radio_button_metadata.md`, or radio button table cell-editor metadata.

1. Start from `doc/table_radio_button_metadata.md` for the current cell-editor-only boundary and required `tag_value:` contract.
2. Exercise one representative table cell-editor metadata sample using `TableCellInput.radio_button(:status, tag_value: "published", ...)` or an equivalent app-specific method/value pair.
3. Record the checked and unchecked representative states that the sample relies on, without turning the evidence into a collection radio group or same-name grouping review.
4. Record that `TableRenderer.cell_editor_call` or `rfk_table_cell_editors` reaches the documented `rfk_radio_button(method, tag_value, **options)` rendering path.
5. Record whether the result belongs in the release-wide `doc/sample_app_results.md` table metadata lane or in a scoped PR comment for a narrow docs/spec change.
6. Put the final `PASS`, `FAIL`, `SOURCE REVIEW ONLY`, `DEFERRED`, or `OUT OF SCOPE` note in the chosen evidence location.

Keep this lane representative and tied to the current public surface. Do not add `TableFilterInput.radio_button` evidence unless that surface has landed and the scoped PR or release explicitly includes it. Query construction, enum or boolean interpretation, table persistence, authorization, `fieldset` / `legend`, collection radio groups, and production CSS remain host-app or table-integration responsibilities.

## Date/time/color table metadata evidence route

Use this route when a release, PR, or review question mentions `TableFilterInput.date_field`, `TableFilterInput.time_field`, `TableFilterInput.datetime_local_field`, `TableFilterInput.color_field`, the matching `TableCellInput` factories, or `doc/table_date_time_color_metadata.md`.

1. Start from `doc/table_date_time_color_metadata.md` for the current metadata object, renderer mapping, and browser-native picker ownership boundary.
2. Exercise one representative filter or cell-editor metadata sample, such as `TableFilterInput.date_field(:starts_on, min: ..., required: true)` or `TableCellInput.datetime_local_field(:published_at, step: 60)`.
3. Record the native option pass-through that matters for the scoped review, such as `min:`, `max:`, `step:`, `required:`, `disabled:`, `readonly:`, `wrapper_html:`, or `html:`.
4. Record that `TableRenderer.filter_call`, `TableRenderer.cell_editor_call`, `rfk_table_filters`, or `rfk_table_cell_editors` reaches the matching `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, or `rfk_color_field` rendering path.
5. Record whether the result belongs in the release-wide `doc/sample_app_results.md` table metadata lane or in a scoped PR comment for a narrow docs/spec change.
6. Put the final `PASS`, `FAIL`, `SOURCE REVIEW ONLY`, `DEFERRED`, or `OUT OF SCOPE` note in the chosen evidence location.

Keep this lane representative and tied to metadata rendering. Do not turn it into browser-native picker approval, timezone conversion, locale formatting, masking, custom picker UI, browser validation-message policy, query execution, table preference persistence, authorization, or production CSS evidence.

## TableRenderer registry evidence route

Use this route when a release, PR, or review question mentions `RailsFieldsKit::TableRenderer.register_field_helper`, `registered_field_types`, `unregister_field_helper`, or `reset_field_helpers!`.

1. Start from the public method list in `doc/public_api.md` and behavior examples in `doc/table_adapters.md`.
2. Exercise one representative custom field type through the documented call-spec path.
3. Record whether `registered_field_types` exposes the custom type after registration without exposing helper method names as the evidence contract.
4. Record the cleanup path that matches the scoped change: `reset_field_helpers!` for release-wide cleanup, `unregister_field_helper` for a custom-only mapping, or unregistering a built-in override to confirm default fallback restoration.
5. Put the final `PASS`, `FAIL`, `SKIPPED`, or `OUT OF SCOPE` note in `doc/sample_app_results.md` for release candidates, or in the PR comment for a narrow docs/spec change.

Keep the evidence representative. Do not require every built-in type, every helper method name, or every table integration to be rechecked just because one registry lane is in scope.

## Checklist items

When the lane is in scope, confirm only the relevant items below:

- [ ] `group_html:` adds attributes to one outer table-helper group wrapper while each rendered field keeps its own field-level wrapper behavior.
- [ ] Evidence notes distinguish group-level `group_html:` from field-level `wrapper_html:`.
- [ ] Evidence notes keep semantic `fieldset`, `legend`, group hint/error copy, and group-level `aria-describedby` wiring with the host app unless a separate future surface lands.
- [ ] Radio button table metadata evidence starts from `doc/table_radio_button_metadata.md` and stays in the `TableCellInput.radio_button` cell-editor-only lane.
- [ ] The representative radio cell-editor sample records required `tag_value:` and checked / unchecked state evidence without implying a radio filter factory.
- [ ] Radio button table metadata evidence keeps same-name grouping, boolean or enum query semantics, collection radio groups, `fieldset` / `legend`, table persistence, authorization, and production CSS outside Rails Fields Kit ownership.
- [ ] Date/time/color table metadata evidence starts from `doc/table_date_time_color_metadata.md` and stays in the filter or cell-editor metadata lane.
- [ ] The representative date/time/color sample records a current `TableFilterInput` or `TableCellInput` factory, the matching `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, or `rfk_color_field` rendering path, and any scoped native option pass-through.
- [ ] Date/time/color table metadata evidence keeps browser-native picker behavior, timezone conversion, locale formatting, masking, custom picker UI, browser validation-message policy, query execution, table persistence, authorization, and production CSS outside Rails Fields Kit ownership.
- [ ] A representative custom field helper registration is renderable through the documented call-spec path.
- [ ] `RailsFieldsKit::TableRenderer.registered_field_types` exposes renderable custom types without exposing helper method names.
- [ ] `RailsFieldsKit::TableFilterInput.known_types` and `RailsFieldsKit::TableCellInput.known_types` remain limited to the built-in factory family.
- [ ] `RailsFieldsKit::TableRenderer.unregister_field_helper` removes a custom-only mapping from the current registry.
- [ ] Unregistering a custom override for a built-in field type restores the built-in default helper.
- [ ] Native contact/search table metadata evidence stays limited to Rails Fields Kit wrapper rendering and table metadata mapping, with `doc/native_contact_fields.md` as the contact/search ownership source of truth.
- [ ] Browser-native `search_field` evidence is not described as remote suggestions, token parsing, Ransack query execution, or table query execution.
- [ ] Query execution, preference persistence, authorization, pagination, visible save/error copy, validation policy, normalization, and final table layout remain host-app or table integration responsibilities.
- [ ] Semantic group naming, group hint/error copy, and group-level accessibility policy also remain host-app responsibilities unless a separate future surface lands.

## Result template

Copy the compact result into `doc/sample_app_results.md` for release candidates, or into a PR comment for a narrow docs/spec change.

| Evidence lane | Representative sample | Result | Notes |
| --- | --- | --- | --- |
| Table helper `group_html:` |  |  |  |
| Radio button table cell editor |  |  |  |
| Date/time/color table metadata |  |  |  |
| TableRenderer custom registry |  |  |  |
| TableRenderer unregister cleanup |  |  |  |
| Built-in override fallback |  |  |  |
| Native contact/search table metadata |  |  |  |

Use `PASS` only for checks actually exercised. Use `SOURCE REVIEW ONLY` or `DEFERRED` when the evidence location only reviewed docs/source or intentionally hands off a sample-app/browser-capable check. Use `OUT OF SCOPE` when the lane was reviewed and deliberately excluded from the release or PR scope.