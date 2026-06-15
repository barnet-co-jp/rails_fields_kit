# File Field Native Wrapper

`rfk_file_field` renders Rails' native `file_field` helper through the same wrapper lane as `rfk_text_field`, `rfk_password_field`, and the other native helpers.

Use it when the host app wants Rails Fields Kit's label, hint, validation error, affix, wrapper, and accessibility wiring around an ordinary browser file input.

```erb
<%= form_with model: @document, multipart: true do |f| %>
  <%= f.rfk_file_field :attachment,
    wrapper: true,
    label: "Attachment",
    hint: "Upload one PDF",
    accept: "application/pdf" %>
<% end %>
```

Ordinary Rails `file_field` options such as `accept:`, `multiple:`, `direct_upload:`, `disabled:`, `required:`, and `html:` pass through to the rendered input. Rails Fields Kit does not change the submitted file parameter shape.

## Responsibility Boundary

Rails Fields Kit owns only the shared native wrapper contract around the file input:

- optional `wrapper: true` field shell
- generated label, hint, and validation error output
- `aria-describedby`, `aria-invalid`, and `aria-required` wiring unless `accessibility: false` is passed
- optional prefix/suffix affix wrapper

The host app remains responsible for multipart form setup, Active Storage direct upload behavior, file preview UI, upload progress UI, accepted file policy, file size and MIME validation, storage configuration, virus scanning, and production CSS. Rails Fields Kit does not add upload JavaScript or replace Rails' file upload workflow.
