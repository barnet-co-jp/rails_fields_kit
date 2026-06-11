# Grouped Select Boundary

Use `rfk_grouped_select` when the host app already has a server-rendered grouped collection and wants Rails Fields Kit to preserve that `<optgroup>` structure while keeping the submitted value in an ordinary selected ID or value lane.

```erb
<%= f.rfk_grouped_select :customer_id,
  grouped_collection: {
    "Active" => [["Acme Corp", 1]],
    "Archived" => [["Old Corp", 2]]
  } %>
```

The helper accepts `grouped_collection:` and renders it through Rails grouped select semantics before Tom Select enhances the field. The grouped labels are presentation structure for the known collection; choosing an option still submits the selected option value through the same field name that a normal Rails select would use.

## Use This Lane For

- grouped choices that are already known at render time
- preserving `<optgroup>` labels across first render, edit forms, and validation rerender
- collection-backed single-value fields where the submitted param remains an ordinary selected ID or value
- option-level disabled states or option-level HTML metadata on known grouped choices
- sample app checks that need an optgroup-preserving representative lane separate from remote search, create-on-the-fly, or token metadata

## Option Metadata Boundary

`rfk_grouped_select` supports the same rendered option metadata lane as collection-backed `rfk_select` for known choices:

```erb
<%= f.rfk_grouped_select :customer_id,
  grouped_collection: {
    "Active" => [["Acme Corp", 1], ["Beta LLC", 2]],
    "Archived" => [["Old Corp", 3]]
  },
  disabled: [3],
  option_html: {
    2 => { data: { tier: "preferred" }, class: "customer-option" }
  } %>
```

Use value-array `disabled:` when specific rendered options should be unavailable. Use boolean `disabled: true` when the whole select should be disabled. Use `option_html:` for per-option attributes keyed by rendered option value, or a callable that returns attributes for a value.

This metadata is still collection metadata for already-rendered choices. It does not decide authorization, remote visibility, dynamic grouping, or Tom Select renderer behavior. Filter unavailable records before rendering when visibility is a business policy.

Group-level optgroup metadata remains intentionally out of scope for this helper. Rails Fields Kit preserves the group labels, but it does not currently expose a public `disabled_groups:` or `group_html:` option. If a host app needs disabled optgroups, group-level classes, or group-level data attributes, use ordinary Rails helpers or host-app markup for that field until a separate optgroup metadata proposal is accepted.

## Keep Separate

Use `rfk_combobox` when options come from `url:`, selected labels need `selected_url:`, or the field creates new records with `create_url:`. Those remote workflows have endpoint authorization, scoping, request params, selected preload, and create response contracts that `rfk_grouped_select` does not take over.

Use `rfk_token_search` when the text is structured query syntax that the host app parses later. Group labels in `rfk_grouped_select` are not token metadata, Ransack predicate metadata, or a parser-owned field/operator registry.

## Review Checklist

When reviewing a sample app or release lane for `rfk_grouped_select`, record the representative field, branch or commit, and result in the PR comment or release evidence log. Confirm that:

- the grouped collection renders with the expected optgroup labels
- choosing an option submits the ordinary selected ID or value
- edit-form redisplay or validation rerender preserves the selected value and grouped labels
- option-level disabled states and `option_html:` metadata, if used, stay attached to the intended rendered values
- the field does not rely on `url:`, `selected_url:`, or `create_url:` to be understandable
- remote search, create-on-the-fly, token metadata, and group-level optgroup metadata work stay outside this lane
