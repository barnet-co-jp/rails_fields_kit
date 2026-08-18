# Host application integration contract

Rails Fields Kit is a versioned library. Host applications should treat the public API and documentation shipped with the installed gem as the source of truth instead of reproducing Rails Fields Kit behavior in app-local guides.

## Read the installed version first

Before implementing or changing an `rfk_*` field, identify the Rails Fields Kit version, tag, or commit used by the host application and inspect that same version of the documentation.

Prefer the installed gem because it is guaranteed to match the code Bundler resolved:

```bash
bundle show rails_fields_kit
```

Then read the relevant files under that directory, especially:

- `README.md`
- `doc/public_api.md`
- `doc/field_helpers.md`
- `doc/controller_helpers.md`
- `doc/configuration.md`

If the private GitHub repository is used instead, inspect the exact tag or commit from `Gemfile.lock`. Do not use `main` as the specification for a host application pinned to an older version.

## Do not redefine public API semantics

Host applications should not reinterpret Rails Fields Kit options to make a particular screen appear to work. In particular:

- `value_field:` is the remote option value submitted for a selected candidate.
- `label_field:` is the remote option label used for display.
- `selected_url:` hydrates the display for already-selected values; it does not change the submitted identity.
- `free_text:` controls free-text creation behavior; it does not turn a display label into a stable identifier.
- `rfk_lookup` exists for a text value that may also have a separately selected master ID.

Do not set `value_field:` to a display label merely so a selected candidate can be reused as LIKE-search text. When selected candidates must filter by ID while manual text must filter by text, keep those values separate with `rfk_lookup`.

## Choose the helper by submitted semantics

| Requirement | Helper | Submitted semantics |
| --- | --- | --- |
| Select a remote candidate by stable ID/value | `rfk_combobox` | Submit the configured `value_field` and use it as the selected identity. |
| Keep a text value with remote suggestions | `rfk_autocomplete` | Submit text. |
| Search with an ordinary native text/search input | `rfk_search_field` | Submit text; the host app owns query execution. |
| Allow either free text or a selected master record | `rfk_lookup` | Submit the text field and a separate `id_field`; manual text editing clears the ID by default. |

For a filter that means “selected candidate = exact ID match, manual input = LIKE text match”, `rfk_lookup` is the preferred contract. The host application branches on the presence of the ID rather than inferring identity from a formatted label.

## Keep host customization on public extension points

Do not depend on private `rfk_*` implementation methods, generated Tom Select internals, or undocumented Stimulus data attributes from host code.

If a required behavior cannot be expressed through the documented public API, add or request a public Rails Fields Kit extension point before introducing a host-side monkey patch. For example, enum label I18n key construction is configurable through `config.enum_i18n_key` rather than overriding the private enum-label helper.

Before replacing or subclassing the Rails Fields Kit Tom Select controller, check these existing public routes:

- `dropdown_parent:` passes Tom Select's `dropdownParent` selector for overflow/portal placement. Framework-specific overlay positioning, z-index, and nested-scroll policy remain host-app concerns.
- `depends_on:` and `clear_on_dependency_change:` provide dependent remote-search params, cache clearing, optional selection clearing, and open-dropdown reload behavior.
- `html: { data: { action: "..." } }` can subscribe app-owned Stimulus controllers to Rails Fields Kit events without replacing the built-in controller.
- `selected-load-error` and `error_surface: true` provide selected-preload failure hooks and an accessible field-adjacent feedback surface.
- `add_precedence:`, `create_on_blur:`, and `clear_after_select:` explicitly pass Tom Select behavior settings through when a field needs them. They remain opt-in; `free_text: true` does not implicitly change these settings.

See [`free_text_behavior.md`](free_text_behavior.md) for the free-text behavior options and the related existing integration routes.

## Keep app-local guidance thin

Host-app AI/agent skills and implementation notes should link or point to this gem-owned documentation instead of copying option semantics into multiple local documents. App-local documentation should contain only host-specific decisions such as endpoint names, authorization rules, query behavior, and project conventions.

A useful host-app rule is:

> Before changing Rails Fields Kit usage, resolve the installed gem version, read that version's public documentation, and use only documented public APIs. If the public API is insufficient, change Rails Fields Kit before patching its internals in the host application.
