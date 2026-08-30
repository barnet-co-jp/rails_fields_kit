# Free-text Tom Select behavior options

Rails Fields Kit 1.0.1 exposes three field-level Tom Select behavior pass-throughs for host applications that need more explicit free-text entry behavior:

- `add_precedence:` forwards Tom Select `addPrecedence`.
- `create_on_blur:` forwards Tom Select `createOnBlur`.
- `clear_after_select:` forwards Tom Select `clearAfterSelect`.

These options are explicit opt-ins. `free_text: true` continues to enable free-text creation without automatically changing these Tom Select settings, preserving existing behavior for applications upgrading from 1.0.0.

```erb
<%= f.rfk_combobox :repository_full_name,
  url: repositories_path(format: :json),
  free_text: true,
  add_precedence: true,
  create_on_blur: true %>
```

For a multiple-value field that should clear the typed query after an item is accepted, opt in separately:

```erb
<%= f.rfk_tags :labels,
  free_text: true,
  clear_after_select: true %>
```

Rails Fields Kit only forwards these values to Tom Select for general Tom Select-backed fields. Host applications remain responsible for deciding whether create-on-blur, create-option precedence, or post-selection query clearing is appropriate for a specific field.

## Lookup selection normalization

`rfk_lookup` treats an accepted lookup candidate as a completed master selection, independently of the generic `clear_after_select:` pass-through.

When Tom Select accepts a lookup item, Rails Fields Kit synchronizes the paired lookup text and ID from the accepted option and clears the transient textbox query. A partial query such as `サ` therefore cannot remain in the editable textbox after the user selects `サポート商事（TCUST0001）`; the selected Tom Select item renders the option label while the paired hidden fields hold that label and ID.

This normalization is lookup-specific. `clear_after_select:` still controls Tom Select's general `clearAfterSelect` behavior for other field kinds and should not be required merely to prevent a stale lookup search query from surviving a successful lookup selection.

## Editable free-text lookup behavior

`rfk_lookup` has one additional interaction rule when both `free_text: true` and `create_on_blur: true` are enabled.

A value created from the user's typed text is temporarily represented by Tom Select as a selected item after blur so the text is preserved. When the same lookup receives focus again, Rails Fields Kit recognizes that user-created item, removes only that temporary selection, restores its text to the editable textbox, clears the paired lookup ID, and reuses the restored text as the remote-search query.

This means a partial lookup entry can be resumed naturally:

1. Type `やき`.
2. Click outside the field. The text remains preserved.
3. Focus the field again. `やき` becomes editable text again and lookup suggestions are filtered with that query.
4. Backspace edits one character at a time instead of deleting the whole temporary item.

Normal options returned by the lookup endpoint are not restored into the textbox on focus; they remain selected. Other field kinds such as `rfk_tags` also keep their existing behavior.

## Related existing APIs

Before replacing the Rails Fields Kit controller in a host application, check the existing public options:

- Use `dropdown_parent: "body"` when a dropdown must render outside an overflow container. Overlay positioning policy, nested-scroll close behavior, z-index, and framework-specific modal behavior remain host-app responsibilities.
- Use `depends_on:` with `clear_on_dependency_change:` for dependent remote-search query params and selection clearing.
- Use `html: { data: { action: "rails-fields-kit--tom-select:change->example#changed" } }` to subscribe an app-owned Stimulus controller to Rails Fields Kit events.
- Use `error_surface: true` and `rails-fields-kit--tom-select:selected-load-error` for selected-preload failure feedback.

These existing routes should be preferred over subclassing or replacing the Rails Fields Kit Tom Select controller when they cover the required behavior.
