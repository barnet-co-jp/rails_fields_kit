# Textarea autosize release evidence

Use this guide when a release, release-candidate PR, or narrow docs/quality PR needs representative evidence for the current `rfk_text_area` autosize boundary.

`doc/textarea_autosize.md` is the source of truth for the current decision: Rails Fields Kit renders the native textarea wrapper and accessibility wiring, but autosize remains host-app owned for the 0.1.x surface.

## When to use this guide

Use this guide with `doc/sample_app_checklist.md` and record the result in `doc/sample_app_results.md` or in the PR comment for a narrow PR.

Use it when the change in scope touches:

- `rfk_text_area`
- native helper wrapper / accessibility evidence
- sample app release evidence for native helpers
- release-facing docs that mention the autosize boundary

Do not use it as evidence that Rails Fields Kit ships autosize behavior.

## Representative field setup

Choose one `rfk_text_area` field that stays in the native helper family:

```erb
<%= f.rfk_text_area :description,
  wrapper: true,
  hint: "Add the internal note shown to support staff.",
  error: @record.errors[:description].to_sentence,
  prefix: "Note",
  html: { rows: 4 } %>
```

If the host app adds autosize behavior, add it through host-owned `html:` attributes or host-owned CSS / JavaScript and record it as host-app evidence:

```erb
<%= f.rfk_text_area :description,
  wrapper: true,
  html: {
    rows: 4,
    data: { controller: "textarea-autosize" }
  } %>
```

## Evidence checklist

Record the representative field, route or page, branch/commit, and result.

- [ ] `rfk_text_area` rendered as a native textarea with the expected wrapper, label, hint, error, prefix or suffix when those options are used.
- [ ] The submitted value stayed a normal Rails textarea value and did not depend on Tom Select, remote search, selected preload, create-on-the-fly, token parsing, or table metadata lanes.
- [ ] The field kept the expected `aria-describedby` wiring for hint and error elements when accessibility wiring was enabled.
- [ ] An edit-form redisplay kept the textarea value and wrapper / accessibility wiring stable.
- [ ] A validation rerender kept the textarea value, visible error, and `aria-describedby` wiring stable.
- [ ] Any host-owned autosize controller, CSS, manual-resize policy, or Turbo reconnect sizing behavior was recorded as host-app evidence, not Rails Fields Kit behavior.
- [ ] Evidence notes explicitly confirmed that Rails Fields Kit still has no built-in `autosize:` option, bundled measurement script, production CSS preset, or Turbo reconnect sizing hook.
- [ ] Validation copy, browser validation-message behavior, masking, character counters, server-side validation, scrollbar policy, and resize handles remained host-app responsibilities.

## Evidence table

| Field or route | Scenario checked | Result | Evidence notes |
| --- | --- | --- | --- |
|  | first render |  |  |
|  | edit-form redisplay |  |  |
|  | validation rerender |  |  |
|  | optional host-owned autosize enhancement |  |  |

## Scope boundary

This guide is release evidence only. It does not add a runtime option, visual reference artifact, setup doctor check, or JavaScript helper export.

If a future issue accepts an opt-in autosize feature, update `doc/textarea_autosize.md` first, then decide whether this evidence guide should move from a host-owned boundary check to an implementation-specific release gate.
