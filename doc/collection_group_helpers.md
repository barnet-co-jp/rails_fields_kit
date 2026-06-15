# Collection Group Helper Boundary

Rails Fields Kit does not currently provide first-class collection checkbox or collection radio group helpers.

This document defines the public boundary for collection-style checkbox and radio groups so host apps can keep using ordinary Rails form behavior while future Rails Fields Kit proposals stay reviewable.

## Current public API

Use Rails and host-app markup for collection groups today:

- `collection_check_boxes`, `collection_radio_buttons`, `check_box`, and `radio_button` keep their ordinary Rails parameter, checked-state, and same-name behavior.
- The host app owns `fieldset`, `legend`, group-level hint copy, group-level validation errors, and any `aria-describedby` wiring across those pieces.
- Rails Fields Kit may be used for nearby individual field wrappers, but that does not make the gem own collection group semantics.

Do not treat proposal branches, open PR helper names, or local wrapper experiments as public API until they are merged and listed in `public_api.md`.

## Future adoption criteria

A future Rails Fields Kit collection group helper should only become public after it can preserve the Rails defaults above and add a small, explicit wrapper contract for the group itself.

The minimum review checklist for a future helper is:

- preserve Rails collection parameter names and selected-value semantics without replacing standard Rails helper behavior
- render or accept a semantic `fieldset` and `legend` boundary for the whole group
- support group-level hint and validation feedback without confusing it with per-option labels or per-option hints
- wire group-level feedback through `aria-describedby` in a predictable way
- keep option querying, authorization, persistence, and custom filtering in the host app
- document migration guidance separately from single checkbox or single radio wrapper guidance

## Non-goals for this slice

This boundary slice intentionally does not add:

- a collection checkbox DSL
- a collection radio DSL
- a fieldset builder
- production CSS
- validation UI behavior
- authorization or persistence policy
- collection querying, filtering, or endpoint behavior

The goal is to make the current boundary explicit before any helper implementation work begins.