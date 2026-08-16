# Practical `rfk_select` Migration Guide

Use this guide when you want to replace existing server-rendered Rails select fields with Rails Fields Kit helpers while keeping the same model attribute, submitted params, and normal validation rerender behavior.

The first lane covers a single-value `collection_select` to `rfk_select` migration. The multi-value lane later in this guide covers ordinary multiple select or checkbox-style collections moving to `rfk_multi_select`, with a short boundary note for `rfk_tags`.

## Release and sample evidence route

When a release or PR depends on this migration route, use the `Verify collection_select migration path` lane in [`sample_app_checklist.md`](sample_app_checklist.md) and record the result in the `collection_select` migration checks lane in [`sample_app_results.md`](sample_app_results.md), or in a scoped PR comment for a narrow docs/spec change.

Keep the evidence representative: confirm the same model attribute and submitted params, edit-form redisplay or validation rerender, `include_blank:`, and any scoped `disabled:`, grouped option, or `option_html:` behavior that the release surface depends on. Do not turn this lane into a full helper inventory, remote search check, selected preload check, create-on-the-fly check, or Tom Select configuration review.

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

## Move an ordinary multiple select to `rfk_multi_select`

When the existing field already submits an array of IDs or values, keep that same array-backed attribute and switch only the rendered helper lane:

```erb
<%= form_with model: @document_set do |f| %>
  <%= f.collection_select :category_ids,
    @categories,
    :id,
    :name,
    {},
    multiple: true %>
<% end %>
```

```erb
<%= form_with model: @document_set do |f| %>
  <%= f.rfk_multi_select :category_ids,
    collection: @categories,
    collection_value_method: :id,
    collection_label_method: :name,
    placeholder: "Choose categories" %>
<% end %>
```

What should stay explicit in the host app:

- `:category_ids` still submits multiple values, so the controller should permit an array, such as `category_ids: []`.
- Edit forms and validation rerenders should continue to assign the model or form object with the selected IDs before rendering.
- The collection remains the source of valid options. Use `rfk_combobox` or another remote helper when choices should come from endpoint-backed search.
- `rfk_multi_select` is not a tag creation workflow. It keeps ordinary multiple selection over a known collection.

## Move checkbox-style collections only when the interaction should become select-like

A checkbox collection and `rfk_multi_select` can both submit arrays, but they are different interactions. Use `rfk_multi_select` when the form should become a compact select-style control over a known collection:

```erb
<%= f.rfk_multi_select :role_ids,
  collection: @roles,
  collection_value_method: :id,
  collection_label_method: :name,
  label: "Roles",
  hint: "Choose one or more roles for this account." %>
```

Keep checkbox UI when the host app needs all options visible without opening a control, when each option needs custom inline explanation, or when the page layout relies on separate checkbox elements.

## Use `rfk_tags` only for tag-entry workflows

Reach for `rfk_tags` when the same field should feel like tag entry, keep selected tags visible inline, or optionally create missing tags through a host-owned endpoint:

```erb
<%= f.rfk_tags :tag_ids,
  collection: @tags,
  collection_value_method: :id,
  collection_label_method: :name,
  selected: @post.tag_ids,
  placeholder: "Add tags" %>
```

For tags, the host app still owns tag persistence, authorization, duplicate handling, and any `create_url:` endpoint. Rails Fields Kit wires the field and Tom Select behavior; it does not decide which tags may be created or how created tags are saved.

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

Use `selected:` only when the current label is not already present in the rendered collection, such as remote comboboxes, tag fields that start from IDs without labels, or values loaded later.

## What Rails Fields Kit does not take over

This migration pattern keeps the gem focused on the field helper and Tom Select wiring. The host app still owns:

- strong params and save flow
- controller and policy behavior
- app-specific CSS and page layout
- any custom search semantics behind the option source
- tag creation, authorization, and persistence rules

For the helper reference, including grouped, remote, and multi-value variants, see [`field_helpers.md`](field_helpers.md).
