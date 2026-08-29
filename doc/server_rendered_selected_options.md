# Server-rendered selected options

Remote Tom Select fields do not always need an extra `selected_url` request just to recover the label for an already-known selected record.

When the host application already has both the selected value and its display label while rendering the form, pass that record through `selected:` so Rails Fields Kit renders the selected state into the initial HTML.

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

Tom Select therefore already knows both the value and label. If `selected_url:` is also configured, Rails Fields Kit does not request a label that is already available in the rendered option.

## When to use `selected_url:`

Use `selected_url:` when the form only has an ID/value and does not already have the selected record or label available during server rendering.

```erb
<%= f.rfk_combobox :vehicle_id,
  url: search_options_path("vehicles"),
  selected_url: search_options_path("vehicles"),
  selected: @order.vehicle_id %>
```

An ID-only scalar `selected:` is treated as unresolved label state. Rails Fields Kit may render a temporary option so Tom Select retains the selected value during initialization, but that temporary option does not suppress `selected_url:`. The selected preload response replaces the temporary ID label with the returned display label.

If the scalar selected value is outside a purely static collection and there is no `url:` or `selected_url:` that can resolve it, Rails Fields Kit ignores that invalid scalar instead of manufacturing an out-of-collection option. An explicit `{ value:, text: }` pair or selected record remains authoritative because the caller supplied both identity and display data deliberately.

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

Rails Fields Kit renders known selected options immediately. Scalar IDs without labels can still use `selected_url:` for hydration.

## `rfk_lookup` initial state

`rfk_lookup` has a different submit contract from a select-backed helper: it owns editable text and a separate optional master ID.

When both are already known, pass both through one selected record/hash:

```erb
<%= f.rfk_lookup :vehicle_number,
  id_field: :vehicle_id,
  url: search_options_path("vehicles"),
  selected: {
    value: params[:vehicle_id],
    text: params[:vehicle_number]
  } %>
```

This also works for objectless/scoped GET filter forms. Rails Fields Kit restores the text field and ID field together, uses the rendered text as the initial visible label, and does not need a selected preload request merely to rediscover that label.

When only the lookup ID is available, pass the scalar ID with `selected_url:`:

```erb
<%= f.rfk_lookup :vehicle_number,
  id_field: :vehicle_id,
  selected: params[:vehicle_id],
  selected_url: search_options_path("vehicles") %>
```

The ID is retained as unresolved initial state. After selected preload returns the option, Rails Fields Kit synchronizes the returned label into the lookup text field while retaining the ID.

Keep the lookup text and ID as separate submitted values. Do not replace this with a host-app hidden-field bridge or a second controller just to restore GET parameters.

## Placeholder before Tom Select connects

For single select-backed helpers, `placeholder:` also renders a blank native `<option>` when the caller did not already provide `include_blank:` or `prompt:`. This gives the server-rendered `<select>` the same empty-state text before Stimulus/Tom Select initializes instead of briefly showing the first real option.

Explicit Rails `include_blank:` or `prompt:` still wins when supplied.

## Why this pattern exists

A remote select has two separate concerns:

1. **submitted identity** — usually an ID/value
2. **display label** — the operator-facing text shown in the field

When both are already known on the server, carrying both into the initial HTML is preferable to rendering only the ID and immediately making another request to rediscover the label. When only the identity is known, `selected_url:` must remain able to hydrate the missing label.

Benefits:

- avoids unnecessary selected-label requests
- prevents an ID from becoming the permanent visible label
- works naturally with associations already loaded for the page
- restores objectless GET lookup state without host-app glue code
- keeps the submit contract as the ID/value, or text + ID for `rfk_lookup`
- keeps remote `url:` search available after initialization

## Host application guidance

Prefer this order when implementing an edit form or filter:

1. If the selected association/record or both lookup text + ID are already known, pass the record or `{ value:, text: }` through `selected:`.
2. If only the ID/value is available, combine scalar `selected:` with `selected_url:` so Rails Fields Kit hydrates the label.
3. For a purely static collection, do not pre-filter invalid scalar `selected:` values in every host app; Rails Fields Kit ignores values it cannot resolve from the collection.
4. Do not query the database from a generic RFK helper.
5. Do not duplicate initial-label hydration in a host-side Stimulus/Vue controller.

This keeps record ownership with the host application and reusable field behavior with Rails Fields Kit.
