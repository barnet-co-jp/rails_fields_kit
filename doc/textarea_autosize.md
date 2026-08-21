# Textarea autosize boundary

`rfk_text_area` stays in the native wrapper helper family. Rails Fields Kit renders the textarea, wrapper, label, hint, error, affix, and accessibility wiring; it does not currently own textarea autosize behavior as a public runtime surface.

## Current decision

Autosize remains host-app owned for the current 0.1.x surface.

That means Rails Fields Kit does not add an `autosize:` option, bundled JavaScript measurement, production CSS preset, Turbo reconnect sizing hook, or manual-resize policy for `rfk_text_area` in this slice. The default textarea markup, submitted value, validation redisplay, hint/error wiring, and `aria-describedby` behavior remain the same as the existing native wrapper contract.

## Visual review route

Use `doc/native_field_visual_reference.html`'s multiline textarea lane for visual review of the current Rails Fields Kit-owned surface. That lane is the right place to check long textarea content, long hint copy, validation copy, affix density, generated accessibility wiring, and desktop/narrow viewport readability.

Do not create a separate autosize visual lane unless a future issue accepts an opt-in autosize feature or a host-app sample needs evidence for its own enhancement. When host-owned autosize is present in a sample app, record it as host-app evidence beside the native wrapper check, not as Rails Fields Kit behavior.

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

## Release evidence guidance

When a release or narrow PR needs evidence for `rfk_text_area`, record it in the native helper representative wrapper and accessibility lane, not as a new autosize behavior lane. Use this page as the source of truth for the autosize boundary.

For a focused sample-app or release-gate checklist, use [`textarea_autosize_release_evidence.md`](textarea_autosize_release_evidence.md). It gives a representative `rfk_text_area` evidence table for first render, edit-form redisplay, validation rerender, and optional host-owned autosize enhancement notes.

Representative evidence should confirm:

- a rendered `rfk_text_area` keeps the native wrapper, label, hint, error, affix, submitted value, and automatic accessibility wiring expected from the native helper family
- edit-form redisplay or validation rerender keeps the textarea value and accessibility wiring stable
- any host-owned autosize controller, CSS, or manual-resize policy is described as sample-app or host-app evidence, not as Rails Fields Kit behavior
- the evidence notes explicitly say that Rails Fields Kit still has no built-in `autosize:` option, bundled measurement script, production CSS preset, or Turbo reconnect sizing hook

Do not use release evidence to imply that Rails Fields Kit owns textarea height calculation, autosize timing, scrollbar policy, resize handles, validation-message copy, input masks, character counters, or server-side validation. If the release needs those behaviors, split them into a separate feature issue before recording them as package behavior.

## Future opt-in path

A future feature can still introduce an opt-in autosize surface, but it should be planned separately and keep these constraints:

- default `rfk_text_area` behavior remains unchanged
- autosize is explicit and backward compatible
- layout measurement, Turbo reconnect, manual resize, and production CSS ownership are documented before runtime code lands
- focused tests prove existing native wrapper accessibility and submitted-value behavior still hold

Until that separate feature is accepted, use host-app-owned enhancement code for autosize.
