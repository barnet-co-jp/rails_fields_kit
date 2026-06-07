# Textarea autosize boundary

`rfk_text_area` stays in the native wrapper helper family. Rails Fields Kit renders the textarea, wrapper, label, hint, error, affix, and accessibility wiring; it does not currently own textarea autosize behavior as a public runtime surface.

## Current decision

Autosize remains host-app owned for the current 0.1.x surface.

That means Rails Fields Kit does not add an `autosize:` option, bundled JavaScript measurement, production CSS preset, Turbo reconnect sizing hook, or manual-resize policy for `rfk_text_area` in this slice. The default textarea markup, submitted value, validation redisplay, hint/error wiring, and `aria-describedby` behavior remain the same as the existing native wrapper contract.

## Host-app guidance

Host apps that need autosize can layer it around the rendered textarea with their own CSS or JavaScript:

```erb
<%= f.rfk_text_area :description,
  wrapper: true,
  html: {
    rows: 4,
    data: { controller: "textarea-autosize" }
  } %>
```

Use `html:` for host-owned attributes on the textarea itself, and keep `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, and `suffix_html:` for the generated wrapper pieces.

## Responsibility boundary

Rails Fields Kit owns:

- rendering the native textarea through `rfk_text_area`
- wrapper, label, hint, error, affix, and automatic accessibility wiring
- ordinary Rails textarea options passed through the helper
- edit-form redisplay and validation rerender compatibility with normal Rails form flow

The host app owns:

- autosize measurement and resize timing
- Turbo reconnect behavior for any autosize controller
- production CSS and manual-resize policy
- browser validation-message policy, character counters, input masks, and server-side validation rules
- the final UX decision for minimum rows, maximum height, scrollbars, and resize handles

## Future opt-in path

A future feature can still introduce an opt-in autosize surface, but it should be planned separately and keep these constraints:

- default `rfk_text_area` behavior remains unchanged
- autosize is explicit and backward compatible
- layout measurement, Turbo reconnect, manual resize, and production CSS ownership are documented before runtime code lands
- focused tests prove existing native wrapper accessibility and submitted-value behavior still hold

Until that separate feature is accepted, use host-app-owned enhancement code for autosize.