# Native datalist boundary

This document records the proposal boundary for HTML `datalist` support in Rails Fields Kit. It does not add `rfk_datalist_field` to the current public API.

## Current recommendation

When a host app only needs browser-native suggestions for a plain text value, keep the submitted field as an ordinary text input and let the host app own the `<datalist>` markup:

```erb
<%= f.rfk_text_field :city,
  wrapper: true,
  list: "city-suggestions",
  hint: "Choose an existing city or type a new one" %>

<datalist id="city-suggestions">
  <% @cities.each do |city| %>
    <option value="<%= city.name %>"></option>
  <% end %>
</datalist>
```

This keeps the value contract identical to a normal text field. The submitted value is just `params[:model][:city]`; Rails Fields Kit does not add selected IDs, hidden metadata, selected preload, or a second value channel.

## Responsibility split

Use this lane only when the host app has static or server-rendered candidates and accepts browser-native datalist behavior:

- the host app owns the candidate list and any authorization or scoping behind it
- the browser owns filtering, option display, keyboard behavior, and styling limits
- Rails Fields Kit owns only the native text wrapper, hint, error, affix, and accessibility wiring around the input
- submitted values remain ordinary text values, including values the user typed that did not match an option

Move to existing Tom Select-backed helpers when the field needs richer behavior:

- use `rfk_autocomplete` for remote suggestions where the submitted value stays free text
- use `rfk_combobox` when the field submits a selected ID or value and may need selected preload
- use `rfk_tags` for tag entry or create-on-the-fly tag creation
- use `rfk_token_search` when the text is structured query syntax that the host app parses later

## Future helper gate

A dedicated datalist helper should remain a follow-up decision, not current API. It is worth reconsidering only if repeated host apps need the same small wrapper around a text input plus a server-rendered `<datalist>`.

If that helper is adopted later, keep the first slice narrow:

- render an ordinary text input with a `list` attribute and a matching host-provided or helper-rendered datalist id
- keep the submitted value shape identical to `rfk_text_field`
- support only static or server-rendered candidates
- keep browser-native filtering, option display, and styling differences outside the gem contract
- keep remote search, create-on-the-fly, rich option rendering, selected preload, selected IDs, hidden metadata, and endpoint contracts in the existing Tom Select-backed lanes

Do not list `rfk_datalist_field` in `doc/public_api.md` unless a later implementation PR actually adds and tests the helper.
