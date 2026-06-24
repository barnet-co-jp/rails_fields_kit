# Table group HTML for FormBuilder helpers

`rfk_table_filters(columns)` and `rfk_table_cell_editors(columns)` are the direct FormBuilder rendering path for table metadata. By default they keep the existing contract: Rails Fields Kit collects the table metadata, renders the matching controls, and returns safe-buffer output from `safe_join(...)`.

The `group_html:` implementation lives in `lib/rails_fields_kit/form_builder_table_groups.rb`, where it extends `RailsFieldsKit::FormBuilder` with the table group helper overrides. Check that split definition before treating the older base helper file as the complete table helper surface.

When a host app needs one group-level container around those controls, pass `group_html:`:

```erb
<%= f.rfk_table_filters(
  columns,
  group_html: {
    class: "table-filter-group",
    data: { controller: "table-filters" },
    aria: { label: "Order filters" }
  }
) %>
```

```erb
<%= f.rfk_table_cell_editors(
  columns,
  group_html: {
    class: "table-editor-group",
    data: { role: "cell-editors" },
    aria: { label: "Cell editors" }
  }
) %>
```

`group_html:` is intentionally separate from field-level `wrapper_html:`. It adds attributes to one outer `<div>` around the joined batch output, while each rendered field keeps its own helper options and wrapper behavior.

## Semantic grouping boundary

`group_html:` does not make Rails Fields Kit generate semantic grouping elements. The outer element stays a Rails Fields Kit-owned `<div>` attribute pass-through, not a `fieldset`, `legend`, table layout component, or accessibility policy object.

When a screen needs a semantic `fieldset` / `legend`, keep that markup in the host app and render the Rails Fields Kit table group inside it:

```erb
<fieldset class="order-filter-fieldset">
  <legend>Order filters</legend>

  <%= f.rfk_table_filters(
    columns,
    group_html: {
      class: "table-filter-group",
      data: { controller: "table-filters" }
    }
  ) %>
</fieldset>
```

Use the same pattern for cell editors when a host app needs to describe a batch of editable controls:

```erb
<fieldset class="inventory-editor-fieldset">
  <legend>Inventory cell editors</legend>

  <%= f.rfk_table_cell_editors(
    columns,
    group_html: { class: "table-editor-group" }
  ) %>
</fieldset>
```

That split keeps the responsibilities distinct:

- Field-level `wrapper_html:` belongs to each rendered Rails Fields Kit control.
- Group-level `group_html:` belongs to the single wrapper around the joined table helper output.
- Semantic wrappers such as `fieldset` and `legend` belong to the host app, where the surrounding form, layout, heading structure, and accessibility copy are known.
- Group-level hint text, group-level error copy, and any `aria-describedby` relationship for a semantic group also belong to the host app today.

## Future semantic wrapper proposal boundary

If Rails Fields Kit later adopts a semantic group helper or option, treat it as a separate public surface from `group_html:`. Do not reinterpret the current `group_html:` option as a `fieldset` builder or as ownership of `legend`, group hint, group error, or group-level `aria-describedby` wiring.

A future implementation issue should be able to choose its own helper or option name, focused FormBuilder specs, docs sync, and visual/sample evidence without changing the current `<div>` wrapper contract. Until that separate surface lands and is listed in `doc/public_api.md`, host apps should keep semantic grouping markup around the Rails Fields Kit output.

This option does not change the lower-level table metadata contracts. `RailsFieldsKit::TableMetadata.render_filters`, `RailsFieldsKit::TableMetadata.render_cell_editors`, `RailsFieldsKit::TableRenderer.render_filters`, and `RailsFieldsKit::TableRenderer.render_cell_editors` continue to return ordered arrays for integrations that want to inspect, reorder, or wrap controls themselves.

Rails Fields Kit still does not own table layout, query execution, persistence, authorization, pagination, semantic group naming, group-level hint/error copy, group-level `aria-describedby` wiring, or visible save/error copy. Host apps and table integrations remain responsible for those flows.
