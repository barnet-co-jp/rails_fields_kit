# Table group HTML for FormBuilder helpers

`rfk_table_filters(columns)` and `rfk_table_cell_editors(columns)` are the direct FormBuilder rendering path for table metadata. By default they keep the existing contract: Rails Fields Kit collects the table metadata, renders the matching controls, and returns safe-buffer output from `safe_join(...)`.

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

This option does not change the lower-level table metadata contracts. `RailsFieldsKit::TableMetadata.render_filters`, `RailsFieldsKit::TableMetadata.render_cell_editors`, `RailsFieldsKit::TableRenderer.render_filters`, and `RailsFieldsKit::TableRenderer.render_cell_editors` continue to return ordered arrays for integrations that want to inspect, reorder, or wrap controls themselves.

Rails Fields Kit still does not own table layout, query execution, persistence, authorization, pagination, or visible save/error copy. Host apps and table integrations remain responsible for those flows.
