# Dropdown parent guide

Use `dropdown_parent:` when a Tom Select-backed helper needs to render its dropdown inside a host-app chosen container, such as `body`, a modal shell, a drawer root, or another stable portal target.

This option is a selector pass-through. Rails Fields Kit renders the selector string into the Tom Select interaction configuration as `dropdownParent`; the host app still owns the target element, overlay layout, stacking context, focus policy, and production CSS.

## Use it for host-owned overlays

A common case is a select inside a modal where the dropdown would otherwise be clipped by an overflow boundary:

```erb
<%= form_with model: @order do |f| %>
  <%= f.rfk_combobox :customer_id,
    url: customers_path(format: :json),
    selected_url: selected_customers_path(format: :json),
    dropdown_parent: "body" %>
<% end %>
```

Use a selector that is stable for the page where the field renders. Examples include:

- `"body"` when the app intentionally mounts dropdowns at the document level.
- `"#customer-modal"` when the modal element is the intended dropdown boundary.
- `"[data-dropdown-root]"` when the app provides a dedicated portal root.

Rails Fields Kit does not resolve Ruby objects, DOM elements, Procs, or wrapper-relative selectors for this option. Pass the selector string that the browser page can find when Tom Select initializes.

## Responsibility boundary

| Concern | Rails Fields Kit owns | Host app owns |
| --- | --- | --- |
| Selector rendering | Writes the provided `dropdown_parent:` string to the rendered Tom Select config. | Chooses a selector that exists in the current page. |
| Omitted option | Leaves `dropdownParent` absent when `dropdown_parent:` is not provided. | Decides whether the default Tom Select placement is acceptable. |
| Modal or drawer markup | Nothing beyond the selector pass-through. | Provides modal, drawer, portal, or overlay DOM. |
| Layout and stacking | No z-index, positioning, focus trap, or portal policy. | Owns z-index, overflow, focus behavior, viewport constraints, and production CSS. |
| Evidence | Keeps the option visible in public docs and release evidence routes. | Supplies browser evidence for app-specific modal or drawer behavior when needed. |

If the selector is missing, too broad, or points at an element with unsuitable layout, that is a host-app integration issue rather than a Rails Fields Kit fallback policy.

## Pair it with the normal helper lane

`dropdown_parent:` does not change which helper to choose:

- Use `rfk_select` for a server-rendered collection that keeps ordinary Rails select params.
- Use `rfk_combobox` when options come from remote search, selected preload, or create-on-the-fly endpoints.
- Use `rfk_autocomplete`, `rfk_tags`, `rfk_multi_select`, `rfk_grouped_select`, `rfk_enum_select`, or `rfk_token_search` according to the same boundaries in `field_helpers.md`.

The option also does not change endpoint behavior, selected preload, create-on-the-fly behavior, query parsing, authorization, error feedback, or visible loading/retry UI.

## Evidence and related docs

Use `dropdown_parent_release_evidence.md` when a release or sample-app review needs to record selector pass-through and omitted-option behavior. That evidence guide is not a modal layout approval checklist.

Use `public_api.md#javascript-exports` when inspecting the package-root contract reader that reports rendered Tom Select interaction config, including `dropdownParent`. That reader is diagnostic and read-only; it does not initialize Tom Select or validate selector reachability.

Use `field_helpers.md#remote-option-options` for the shared Tom Select-backed option list and neighboring request-shaping options.

## Non-goals

`dropdown_parent:` does not add or standardize:

- modal, drawer, or portal implementation
- z-index or overflow policy
- focus trap behavior
- production CSS
- browser positioning approval
- Element object, Proc, or wrapper-relative target resolution
- screenshot approval CI or browser automation
