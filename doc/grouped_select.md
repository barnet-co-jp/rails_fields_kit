# Grouped Select Helper

`rfk_grouped_select` wraps the Rails grouped select lane with Rails Fields Kit's Tom Select defaults. It keeps grouped option rendering aligned with the normal select helper while avoiding a separate public helper surface.

## Basic Usage

```erb
<%= form.rfk_grouped_select(
  :customer_id,
  grouped_collection: [
    ["North", [["Alpha LLC", "1"], ["Beta LLC", "2"]]],
    ["South", [["Gamma LLC", "3"]]]
  ]
) %>
```

The helper forwards the grouped collection to the existing select rendering path, so the generated field keeps the same wrapper classes, Tom Select data attributes, prompts, and error handling as `rfk_select`. The rendered field kind is `grouped_select` for read-only contract checks through `tomSelectFieldKindContract(element)`, while ordinary select submission, selected values, disabled values, and `<optgroup>` rendering stay in the same collection-backed select lane.

## Use This Lane For

- grouped options rendered from existing Rails option arrays
- prompts, selected values, disabled values, and field-level HTML options already supported by Rails select helpers
- Rails Fields Kit select wrappers and Tom Select initialization
- QA or integration checks that need to distinguish grouped selects from ordinary `rfk_select` fields through the rendered kind contract

## Option Metadata Boundary

The grouped helper supports option-level disabled values through the normal Rails `disabled:` option:

```erb
<%= form.rfk_grouped_select(
  :customer_id,
  grouped_collection: customer_groups,
  disabled: archived_customer_ids
) %>
```

Boolean `disabled: true` still disables the whole select element. Array, scalar, and hash `disabled:` values are treated as option-level metadata and are passed through Rails' grouped option rendering.

Per-option `option_html:` attributes and group-level optgroup metadata are intentionally outside this helper's public boundary. When a screen needs custom option attributes or optgroup attributes, render that field with the host application's existing Rails helper or custom markup instead of extending `rfk_grouped_select`.

## Review Checklist

- Confirm `rfk_grouped_select` renders `data-rails-fields-kit--tom-select-kind-value="grouped_select"` while `rfk_select` continues to render `select`.
- Confirm prompts, selected values, disabled values, and Tom Select data attributes continue to match `rfk_select` expectations.
- Treat custom per-option HTML and optgroup attributes as out of scope unless a separate public API decision is made.
