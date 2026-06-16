# Table direct helper boundary

`rfk_table_filters(columns)` and `rfk_table_cell_editors(columns)` are the direct FormBuilder rendering path for table metadata. They intentionally accept only the column metadata source, render the Rails Fields Kit controls in order, and `safe_join` the rendered pieces into normal view output.

They do not own batch-level layout options such as `wrapper_html:`, `item_html:`, or `empty:`. Keeping the direct helpers thin prevents those batch options from colliding with field-level metadata options passed through `TableFilterInput`, `TableCellInput`, and `TableRenderer`.

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

This boundary keeps Rails Fields Kit responsible for field metadata and helper mapping only. The host application or table integration owns page layout, empty states, query execution, table preference persistence, authorization, and user-visible success or error copy.

If a future direct-helper batch option is needed, it should be introduced as a separate public API decision rather than added implicitly to the current `columns`-only helpers.
