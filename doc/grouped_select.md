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
- sample app checks that need an optgroup-preserving representative lane separate from remote search, create-on-the-fly, or token metadata

## Keep Separate

Use `rfk_combobox` when options come from `url:`, selected labels need `selected_url:`, or the field creates new records with `create_url:`. Those remote workflows have endpoint authorization, scoping, request params, selected preload, and create response contracts that `rfk_grouped_select` does not take over.

Use `rfk_token_search` when the text is structured query syntax that the host app parses later. Group labels in `rfk_grouped_select` are not token metadata, Ransack predicate metadata, or a parser-owned field/operator registry.

Do not treat grouped select docs as disabled option or group-level metadata support. Per-option disabled states and `option_html:` remain the collection option lane documented in `field_helpers.md`; group-level disabled options or optgroup metadata are a separate feature gate and should not be implied here.

## Review Checklist

When reviewing a sample app or release lane for `rfk_grouped_select`, record the representative field, branch or commit, and result in the PR comment or release evidence log. Confirm that:

- the grouped collection renders with the expected optgroup labels
- choosing an option submits the ordinary selected ID or value
- edit-form redisplay or validation rerender preserves the selected value and grouped labels
- the field does not rely on `url:`, `selected_url:`, or `create_url:` to be understandable
- remote search, create-on-the-fly, token metadata, and future optgroup metadata work stay outside this lane
