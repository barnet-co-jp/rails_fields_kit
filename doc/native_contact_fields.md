# Native Contact Field Wrappers

`rfk_email_field`, `rfk_url_field`, `rfk_phone_field`, and `rfk_search_field` are thin native wrapper helpers for browser-native contact and search inputs. Use them when the native input type is enough, but the host app wants Rails Fields Kit's shared wrapper, label, hint, error, affix, and accessibility wiring.

```erb
<%= f.rfk_email_field :email,
  wrapper: true,
  label: "Email",
  autocomplete: "email" %>
```

```erb
<%= f.rfk_url_field :website_url,
  wrapper: true,
  label: "Website" %>
```

```erb
<%= f.rfk_phone_field :phone,
  wrapper: true,
  label: "Phone",
  autocomplete: "tel" %>
```

```erb
<%= f.rfk_search_field :keyword,
  wrapper: true,
  label: "Keyword",
  placeholder: "Search" %>
```

## Helper Mapping

- `rfk_email_field` delegates to Rails' native `email_field` helper.
- `rfk_url_field` delegates to Rails' native `url_field` helper.
- `rfk_phone_field` delegates to Rails' native `telephone_field` helper and defaults `autocomplete` to `tel` unless the field overrides it.
- `rfk_search_field` delegates to Rails' native `search_field` helper.

These helpers keep submitted values in the ordinary Rails form path. Options such as `placeholder:`, `required:`, `pattern:`, `autocomplete:`, `inputmode:`, `disabled:`, `readonly:`, and `html:` stay native input attributes or Rails helper options.

## Responsibility Boundary

Rails Fields Kit owns the shared native wrapper contract:

- optional `wrapper: true` field shell
- generated label, hint, validation error, prefix, and suffix output
- `aria-describedby`, `aria-invalid`, and `aria-required` wiring unless `accessibility: false` is passed
- field-level wrapper customization through `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, `suffix_html:`, and `html:`

The host app remains responsible for browser-native validation-message wording, email deliverability checks, URL normalization, phone-number formatting, country-specific phone policy, search execution, autocomplete policy, server-side validation, and persistence. Rails Fields Kit does not normalize contact values, validate deliverability, parse phone numbers, run searches, or attach remote suggestion endpoints to `rfk_search_field`.

Use `rfk_token_search` when the input should accept structured token query text and suggestion metadata. Use `rfk_autocomplete` or `rfk_combobox` when the field should call remote endpoints for suggestions or selected values. Keep `rfk_search_field` in the native wrapper lane when it is only a browser-native search input with shared wrapper and accessibility behavior.
