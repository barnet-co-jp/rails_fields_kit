# Table direct helper boundary

`rfk_table_filters(columns, group_html: nil)` and `rfk_table_cell_editors(columns, group_html: nil)` are the direct FormBuilder rendering path for table metadata. They accept the column metadata source, render the Rails Fields Kit controls in order, and `safe_join` the rendered pieces into normal view output.

By default, these helpers stay thin and return the joined controls directly. When a host app needs one group-level container around the joined batch output, `group_html:` adds attributes to a single Rails Fields Kit-owned outer `<div>` around that output. It is documented in [`table_group_html.md`](table_group_html.md) and indexed in [`public_api.md`](public_api.md).

`group_html:` is intentionally narrower than a general batch layout API. It does not make Rails Fields Kit own semantic `fieldset` / `legend` generation, group-level hint or error copy, table layout, empty states, query execution, table preference persistence, authorization, or user-visible success or error copy.

The helpers still do not own batch-level item layout options such as `wrapper_html:`, `item_html:`, or `empty:`. Keeping those future options out of the current helper contract prevents batch layout concerns from colliding with field-level metadata options passed through `TableFilterInput`, `TableCellInput`, and `TableRenderer`.

When an integration needs to inspect, reorder, wrap, or selectively join controls, use the lower-level array-returning lane instead:

```erb
<% filter_controls = RailsFieldsKit::TableMetadata.render_filters(f, columns) %>
<%= tag.div(class: "filters") do %>
  <%= safe_join(filter_controls.map { |control| tag.div(control, class: "filter") }) %>
<% end %>
```

```ruby
filter_calls = RailsFieldsKit::TableMetadata.filter_calls(columns)
filter_calls.each do |call|
  # inspect helper, method, and options before choosing how to render them
  call.fetch(:helper)
  call.fetch(:method)
  call.fetch(:options)
end
```

This boundary keeps Rails Fields Kit responsible for field metadata, helper mapping, safe-buffer joining, and the optional single outer `group_html:` wrapper only. The host application or table integration owns page layout, empty states, semantic grouping, query execution, table preference persistence, authorization, and user-visible success or error copy.

If future direct-helper batch options such as `wrapper_html:`, `item_html:`, or `empty:` are needed, they should be introduced as separate public API decisions rather than inferred from the current `group_html:` wrapper.