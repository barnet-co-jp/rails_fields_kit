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

## Feature gate decision

For #1803 and #2202, Rails Fields Kit should not add `rfk_datalist_field` in the current slice. The current recommendation remains `rfk_text_field list:` plus host-owned `<datalist>` markup because that path already keeps the submitted value ordinary text while avoiding a new public helper name.

A future helper is still a reasonable candidate, but it needs its own implementation issue after repeated host apps show the same wrapper need. That follow-up should be limited to wrapper, label, hint, error, affix, accessibility wiring, and the `list` attribute around an ordinary text input. It should not add remote search, selected preload, selected IDs, hidden metadata, create-on-the-fly behavior, rich option rendering, browser UI normalization, polyfills, or production CSS.

Keep this document as the proposal boundary until a later implementation PR adds and tests a helper. Do not add `rfk_datalist_field` to `doc/public_api.md`, setup notes, package metadata, or visual reference inventory from this proposal slice alone.

## Future helper adoption criteria

Reconsider a dedicated helper only when the host-app pattern is repeated enough that the current recommendation causes avoidable duplication. The minimum signal should be more specific than "datalist might be useful": host apps should need the same Rails Fields Kit wrapper, label, hint, error, affix, and `aria-describedby` wiring around an ordinary text input that points at browser-native candidates.

Before implementation, the follow-up issue should answer these questions:

- whether the submitted value remains ordinary text with no selected ID, hidden metadata, or secondary value channel
- whether candidates are static or server-rendered at page render time
- whether Rails Fields Kit owns only input wrapper and `list` id wiring, or also renders the matching `<datalist>` element
- how repeated fields avoid id collisions when a helper-generated datalist id is involved
- how the helper name avoids implying Tom Select behavior, remote option loading, rich rendering, or create-on-the-fly support

If those answers require request lifecycles, selected preload, option payload mapping, hidden selected IDs, authorization policy, or custom popup styling, keep the use case in the existing Tom Select-backed lanes instead of making it a datalist helper.

## Helper ownership options

Use these comparison points when a future implementation issue is planned:

| Option | Rails Fields Kit would own | Host app would still own | Use only if |
| --- | --- | --- | --- |
| Current pattern: `rfk_text_field list:` plus host-owned `<datalist>` | Native wrapper, label, hint, error, affix, accessibility wiring, and pass-through `list` attribute | `<datalist>` markup, candidate scoping, authorization, ids, and all browser-native datalist behavior | The host app already has one-off or varied candidate markup needs |
| Input wiring helper | Native wrapper plus a stable `list` id convention for the text input | Candidate markup and every `<option>` value | Several apps repeat the same wiring but need full ownership of candidate rendering |
| Helper-rendered datalist | Native wrapper, `list` id wiring, and simple server-rendered `<option value>` output | Candidate source selection, authorization, browser-native filtering/display, styling limits, and submitted text handling | A later feature issue accepts a narrow static/server-rendered candidate shape |

None of these options should make Rails Fields Kit own browser-native popup rendering, keyboard behavior, datalist styling normalization, polyfills, remote endpoints, selected preload, selected IDs, rich option metadata, or create flows.

## Sample evidence

Use [`datalist_boundary_sample_evidence.html`](datalist_boundary_sample_evidence.html) as a static review artifact when comparing this proposal boundary with the existing Tom Select-backed helper lanes. The artifact is intentionally not registered as a current visual reference family member: it is evidence for the proposal boundary, not a new public helper or production CSS contract.

The sample keeps three review points visible:

- `rfk_text_field list:` remains an ordinary text input whose candidate list is owned by the host app
- browser-native datalist filtering, popup display, keyboard behavior, and styling limits are outside the gem contract
- selected IDs, preload, rich option metadata, create flows, and remote request behavior stay in the existing Tom Select-backed helper lanes

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
