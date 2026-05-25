# Practical `rfk_select` Migration Guide

Use this guide when you want to replace an existing server-rendered Rails `collection_select` with `rfk_select` while keeping the same model attribute, submitted params, and normal validation rerender behavior.

## Start from the existing Rails select

A typical admin form often starts here:

```erb
<%= form_with model: @document_set do |f| %>
  <%= f.collection_select :owner_id,
    @owners,
    :id,
    :name,
    { include_blank: "Select an owner" } %>
<% end %>
```

This keeps Rails responsible for the field name, submitted value, and redisplay from the model attribute.

## Move to `rfk_select`

The smallest migration keeps the same attribute and the same option sources, then swaps only the helper:

```erb
<%= form_with model: @document_set do |f| %>
  <%= f.rfk_select :owner_id,
    collection: @owners,
    collection_value_method: :id,
    collection_label_method: :name,
    include_blank: "Select an owner",
    placeholder: "Search owners",
    allow_clear: true %>
<% end %>
```

What stays the same:

- `:owner_id` is still the submitted param name.
- The selected value still comes from `@document_set.owner_id` on edit and validation rerender.
- `include_blank:` keeps using Rails select semantics.
- The Tom Select controller reconnects on normal Turbo-driven form replacement or revisit, so a standard server-rendered form does not need an extra reinitializer just because it changed from `collection_select` to `rfk_select`.

## Use an explicit `[[label, id]]` collection when shaping labels yourself

If the host app already builds labels with extra context, pass an array of pairs directly:

```erb
<%= f.rfk_select :owner_id,
  collection: @owners.map { |owner| ["#{owner.name} (#{owner.code})", owner.id] },
  include_blank: "Select an owner",
  placeholder: "Search by owner name or code",
  allow_clear: true %>
```

This is useful when the app wants to decide label text in Ruby instead of adding custom controller code or frontend rendering.

## Option guidelines

Use these options with the same responsibility split as an ordinary Rails form:

- `label:` changes the visible form label rendered by Rails Fields Kit's wrapper.
- `include_blank:` keeps the ordinary Rails blank option contract and is the safest default when the field can stay empty.
- `placeholder:` sets the Tom Select input placeholder for the search box experience.
- `allow_clear: true` adds a clear button plugin on top of the existing select behavior.

A common wrapped admin-form example looks like this:

```erb
<%= f.rfk_select :owner_id,
  collection: @owners,
  collection_value_method: :id,
  collection_label_method: :name,
  wrapper: true,
  label: "Owner",
  include_blank: "Select an owner",
  placeholder: "Search owners",
  allow_clear: true,
  hint: "You can leave this blank until the reviewer is assigned." %>
```

## When to reach for `selected:`

Do not add `selected:` for an ordinary collection-backed select just to preserve the current value. Rails already redisplays the assigned model attribute for normal edit and invalid-rerender flows.

Use `selected:` only when the current label is not already present in the rendered collection, such as remote comboboxes or values loaded later.

## What Rails Fields Kit does not take over

This migration pattern keeps the gem focused on the field helper and Tom Select wiring. The host app still owns:

- strong params and save flow
- controller and policy behavior
- app-specific CSS and page layout
- any custom search semantics behind the option source

For the helper reference, including grouped, remote, and multi-value variants, see [`field_helpers.md`](field_helpers.md).
