# Checkbox table metadata

`TableFilterInput.check_box` and `TableCellInput.check_box` describe a single Rails Fields Kit checkbox control in table metadata. They map to the final `rfk_check_box` FormBuilder helper through `TableRenderer`.

Use this metadata when a table integration wants to render the ordinary Rails checkbox submission contract while keeping the table definition metadata-first.

```ruby
filter = RailsFieldsKit::TableFilterInput.check_box(
  :active,
  checked_value: "1",
  unchecked_value: "0",
  label: "Active only"
)

editor = RailsFieldsKit::TableCellInput.check_box(
  :active,
  checked_value: "yes",
  unchecked_value: "no"
)
```

Both objects normalize to the same metadata protocol as the other built-in table field types:

```ruby
filter.to_table_filter
# => {
#      type: "rails_fields_kit",
#      field_type: "check_box",
#      method: "active",
#      options: {
#        checked_value: "1",
#        unchecked_value: "0",
#        label: "Active only"
#      }
#    }
```

`TableRenderer` dispatches this field type to `rfk_check_box`:

```ruby
RailsFieldsKit::TableRenderer.filter_call(filter)
# => {
#      helper: :rfk_check_box,
#      method: :active,
#      options: {
#        checked_value: "1",
#        unchecked_value: "0",
#        label: "Active only"
#      }
#    }
```

## Boundary

Checkbox table metadata stays in the same renderer lane as the other native table metadata types. It does not add boolean query semantics or table persistence behavior.

Rails Fields Kit owns:

- the metadata factory type, `check_box`
- the built-in renderer mapping to `rfk_check_box`
- pass-through of `checked_value:`, `unchecked_value:`, and ordinary wrapper options

The host app or table integration owns:

- interpreting submitted checked and unchecked values
- query construction, including Ransack predicates
- tri-state filtering or indeterminate-state UI
- bulk edit behavior and persistence
- authorization and table execution policy

Use `TableRenderer.register_field_helper` for custom boolean controls that need host-specific semantics instead of Rails Fields Kit's built-in single checkbox wrapper.
