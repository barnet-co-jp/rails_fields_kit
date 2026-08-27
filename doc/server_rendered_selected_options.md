# Server-rendered selected options

Remote Tom Select fields do not always need an extra `selected_url` request just to recover the label for an already-known selected record.

When the host application already has both the selected value and its display label while rendering the form, pass that record through `selected:` so Rails Fields Kit renders the selected `<option>` into the initial HTML.

This keeps submitted identity and display label separate, avoids redundant label-hydration requests, and still leaves `url:` available for later remote search.

## Preferred pattern when the selected record is already loaded

Hash form:

```erb
<%= f.rfk_combobox :vehicle_id,
  url: search_options_path("vehicles"),
  selected: {
    value: @vehicle.id,
    text: @vehicle.full_number
  },
  value_field: "value",
  label_field: "text" %>
```

Object form:

```erb
<%= f.rfk_combobox :vehicle_id,
  url: search_options_path("vehicles"),
  selected: @vehicle,
  value_method: :id,
  label_method: :full_number,
  value_field: "value",
  label_field: "text" %>
```

The generated select contains the selected option before Tom Select connects:

```html
<option selected="selected" value="42">大阪 100 あ 1234</option>
```

Tom Select therefore already knows both the value and label. If `selected_url:` is also configured, Rails Fields Kit only requests selected values whose option data is not already present in Tom Select.

## When to use `selected_url:`

Use `selected_url:` when the form only has an ID/value and does not already have the selected record or label available during server rendering.

```erb
<%= f.rfk_combobox :vehicle_id,
  url: search_options_path("vehicles"),
  selected_url: search_options_path("vehicles"),
  selected: @order.vehicle_id %>
```

This is useful when loading the association solely for display would be more expensive or would complicate the host application's query shape.

Do not add a database lookup inside a generic field helper just to build the label. The host application owns domain records and eager loading; Rails Fields Kit only consumes the value/label data it is given.

## Multiple values

The same pattern works for multiple-value select helpers such as `rfk_multi_select` and `rfk_tags`:

```erb
<%= f.rfk_tags :tag_ids,
  url: search_options_path("tags"),
  selected: @tags,
  value_method: :id,
  label_method: :name %>
```

Or with hashes:

```ruby
selected_tags = @tags.map { |tag| { value: tag.id, text: tag.name } }
```

Rails Fields Kit renders the known selected options and only needs selected preload for values whose option data is missing.

## Why this pattern exists

A remote select has two separate concerns:

1. **submitted identity** — usually an ID/value
2. **display label** — the operator-facing text shown in the field

When both are already known on the server, carrying both into the initial HTML is preferable to rendering only the ID and immediately making another request to rediscover the label.

Benefits:

- avoids unnecessary selected-label requests
- prevents an ID from being used as the visible label while hydration is pending
- works naturally with associations already loaded for the page
- keeps the submit contract as the ID/value
- keeps remote `url:` search available after initialization

## Boundary with `rfk_lookup`

`rfk_lookup` has a different contract: it owns a visible/editable text value and a separate optional master ID hidden field. Do not assume that the `rfk_combobox` server-rendered selected-option pattern can be copied mechanically to lookup fields.

For lookup, use its documented text + ID contract and the selected hydration behavior provided by the RFK revision in use. A future lookup optimization must preserve both editable text and ID synchronization rather than merely injecting an `<option>`.

## Host application guidance

Prefer this order when implementing an edit form:

1. If the selected association/record is already loaded, pass the record or `{ value:, text: }` through `selected:`.
2. If only the ID/value is available, use `selected_url:` to hydrate missing option data.
3. Do not query the database from a generic RFK helper.
4. Do not duplicate label hydration in a host-side Stimulus/Vue controller.

This keeps record ownership with the host application and field behavior with Rails Fields Kit.
