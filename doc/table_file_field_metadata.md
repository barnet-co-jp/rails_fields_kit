# Table file field metadata

`RailsFieldsKit::TableCellInput.file_field` describes a cell-editor file input that can be rendered through `RailsFieldsKit::TableRenderer` as `rfk_file_field`.

Use this when a table integration wants metadata-first editor configuration for an upload control, while keeping upload execution and persistence in the host application.

```ruby
editor = RailsFieldsKit::TableCellInput.file_field(
  :attachment,
  accept: "image/png",
  multiple: true,
  direct_upload: true
)

editor.to_table_cell_editor
# => {
#      type: "rails_fields_kit",
#      field_type: "file_field",
#      method: "attachment",
#      options: {
#        accept: "image/png",
#        multiple: true,
#        direct_upload: true
#      }
#    }
```

`TableRenderer` maps `file_field` metadata to `rfk_file_field` and passes options through unchanged:

```ruby
call = RailsFieldsKit::TableRenderer.cell_editor_call(editor)
# => {
#      helper: :rfk_file_field,
#      method: :attachment,
#      options: {
#        accept: "image/png",
#        multiple: true,
#        direct_upload: true
#      }
#    }
```

File field metadata is intentionally cell-editor-only in this slice. `TableFilterInput.file_field` is not a built-in factory because a file input does not describe a meaningful filter UI and could imply upload, query, or persistence behavior that Rails Fields Kit does not own.

`accept:`, `multiple:`, `direct_upload:`, and other Rails file-input options stay ordinary option pass-through. Rails Fields Kit owns the wrapper, hint, error, affix, accessibility wiring, metadata object, and renderer mapping. The host application owns multipart form setup, Active Storage direct upload JavaScript, preview UI, upload progress UI, file validation policy, storage configuration, virus scanning, table persistence, query execution, authorization, and production CSS.
