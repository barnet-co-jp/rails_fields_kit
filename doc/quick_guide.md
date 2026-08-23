# Rails Fields Kit Quick Guide

Read this before the individual helper references.

This guide is about choosing the right field contract first. It is intentionally not an API reference. Once the field semantics are decided, use [`field_helpers.md`](field_helpers.md) and [`public_api.md`](public_api.md) for the exact options supported by the installed Rails Fields Kit version.

## Start from the final data semantics

Do not choose a helper only because it is the simplest thing that can render the first version of the screen.

In business applications, a field that starts as a plain select often grows into requirements such as:

- code and name search
- kana normalization
- half-width / full-width normalization
- alias search
- tenant or authorization scope
- active / inactive filtering
- remote result limits
- exact match by selected master ID
- free-text fallback when no master record exists
- restoring the selected label on edit forms

Changing the helper later can affect the submitted params, query objects, strong parameters, selected-value restoration, remote endpoints, and tests. If the finished semantics are already known, implement that contract from the start.

## Default decision order

For master-related business inputs, consider `rfk_lookup` first when the text itself is meaningful business data and a master record is optional.

Use this order:

1. **Does the field store a meaningful text value and optionally link a master record?**
   - Use `rfk_lookup`.
2. **Must the field select an existing master record and submit its stable ID/value?**
   - Use `rfk_combobox` for remote candidates.
3. **Should suggestions help typing, but the submitted value is always text?**
   - Use `rfk_autocomplete`.
4. **Is the candidate set fixed and already rendered by Rails?**
   - Use `rfk_select` or the matching collection helper.
5. **Is this just an ordinary text/search input with host-owned query execution?**
   - Use `rfk_search_field` or another native wrapper helper.

## Decision tree

```text
                         Field requirement
                                |
                    Fixed rendered candidates?
                       /                 \
                     yes                  no
                     |                    |
             rfk_select / enum       Store meaningful text?
                                           /         \
                                         yes          no
                                         |            |
                              Optional master ID?   Existing master
                                  /       \          required?
                                yes       no             |
                                |         |              |
                           rfk_lookup  autocomplete   rfk_combobox
```

The candidate count is not the primary decision rule. Search semantics and submitted semantics are.

## Prefer `rfk_lookup` for business text plus an optional master link

`rfk_lookup` fits a common business-system model:

```text
item_name   = "On-site adjustment work"
product_id  = nil
```

or, after selecting a master candidate:

```text
item_name   = "Server setup"
product_id  = 123
```

The text remains the business value while the master ID is additional identity when available.

Typical examples include:

- order or estimate line item name + optional product ID
- delivery destination text + optional address/master ID
- free-form work name + optional service master ID
- search filters where a selected candidate means exact ID matching but manual text means LIKE matching

For this shape, do not collapse the text and ID into one `value_field:`. Keep them separate.

Example:

```erb
<%= f.rfk_lookup :item_name,
  id_field: :product_id,
  url: search_options_path("products"),
  selected_url: search_options_path("products"),
  placeholder: "Search or enter an item" %>
```

See [`field_helpers.md`](field_helpers.md) for the current lookup options and exact behavior.

## Use `rfk_combobox` when an existing master is mandatory

If the persisted attribute is the foreign key or stable master value itself, use `rfk_combobox` for remote search.

Examples:

```text
user_id
customer_id
warehouse_id
```

These fields mean "choose an existing record". Arbitrary text is not a valid saved state.

```erb
<%= f.rfk_combobox :customer_id,
  url: search_options_path("customers"),
  selected_url: search_options_path("customers") %>
```

Do not use `rfk_lookup` merely because it has more features. The helper should match the persistence contract.

## Use remote search when search semantics belong on the server

Do not decide between local and remote search only from the number of candidates.

Even a small master may deserve remote search when the server owns behavior such as:

- kana normalization
- Unicode / NFKC normalization
- half-width / full-width normalization
- code + name cross-field search
- aliases or alternative names
- tenant or department scope
- authorization
- active-state filtering
- dynamic availability

Conversely, a larger fixed enum or stable collection can still be a normal `rfk_select` if simple client-side selection is sufficient.

A useful rule is:

> Use remote search when the search result depends on server-side business semantics, not merely when the table is large.

The host application owns those search semantics. Rails Fields Kit owns the field contract and request wiring.

## Search filters: selected identity and manual text are different meanings

A common filter requirement is:

```text
selected master candidate -> exact match by ID
manual text               -> text / LIKE search
```

Use `rfk_lookup` so both meanings remain explicit:

```text
customer_text = "Acme"
customer_id   = 42     # selected candidate
```

or:

```text
customer_text = "acm"
customer_id   = nil    # manual free text
```

The query layer can branch on `customer_id.present?` instead of inferring identity from a formatted label.

See [`host_app_integration.md`](host_app_integration.md) for the public contract and integration boundary.

## When the simpler helpers are better

Use the simpler helper when the requirement is genuinely simpler, not as a temporary implementation shortcut.

| Requirement | Preferred helper |
| --- | --- |
| Fixed status / type / enum | `rfk_select` / `rfk_enum_select` |
| Remote existing-master selection by ID/value | `rfk_combobox` |
| Meaningful business text + optional master ID | `rfk_lookup` |
| Suggestions but text is always the saved value | `rfk_autocomplete` |
| Ordinary query text | `rfk_search_field` |
| Multiple fixed selections | `rfk_multi_select` |
| Tag-style multiple entry | `rfk_tags` |

## Keep app-specific behavior outside the gem contract

Rails Fields Kit should describe reusable field semantics. Host applications should still own:

- endpoint names and routes
- domain-specific normalization rules
- authorization and tenant scope
- query-object behavior
- result ranking
- initial blank-query policy
- result limits
- app-specific CSS and overlay policy
- what to do with option metadata after selection

For example, selecting a product may also copy its unit or default price into an order line. That is a host-app workflow. Use Rails Fields Kit events and option metadata rather than replacing the core field contract with an app-specific helper when the public extension points are sufficient.

## Read next

After choosing the contract, continue with:

1. [`field_helpers.md`](field_helpers.md) — helper behavior and options
2. [`public_api.md`](public_api.md) — compact public API index
3. [`controller_helpers.md`](controller_helpers.md) — remote endpoint helpers
4. [`free_text_behavior.md`](free_text_behavior.md) — explicit free-text Tom Select behavior
5. [`host_app_integration.md`](host_app_integration.md) — host-app ownership and integration rules

For a host application, always read the documentation shipped with the installed gem version rather than assuming repository `main` matches the resolved dependency.