# Collection Group Helper Boundary

Rails Fields Kit does not currently provide first-class collection checkbox or collection radio group helpers.

This document defines the public boundary for collection-style checkbox and radio groups so host apps can keep using ordinary Rails form behavior while future Rails Fields Kit proposals stay reviewable.

## Current public API

Use Rails and host-app markup for collection groups today:

- `collection_check_boxes`, `collection_radio_buttons`, `check_box`, and `radio_button` keep their ordinary Rails parameter, checked-state, and same-name behavior.
- The host app owns `fieldset`, `legend`, group-level hint copy, group-level validation errors, and any `aria-describedby` wiring across those pieces.
- Rails Fields Kit may be used for nearby individual field wrappers, but that does not make the gem own collection group semantics.

Do not treat proposal branches, open PR helper names, or local wrapper experiments as public API until they are merged and listed in `public_api.md`.

## Visual and evidence lane decision

Keep collection group review in this boundary document until a collection helper becomes public API.

The visual reference family should not add a standalone collection group lane yet. A static artifact that shows collection checkbox or collection radio groups too prominently can make proposal-only helpers look like current Rails Fields Kit behavior. For now, reviewers should use this page as the source of truth and treat any collection group screenshot, sample app note, or PR comment as host-app-owned evidence rather than Rails Fields Kit rendered-state evidence.

Use the following distinction when reviewing nearby native fields:

- Single checkbox or radio wrappers can be reviewed as individual field helpers after they are merged and listed in `public_api.md`.
- Collection groups remain Rails / host-app markup, including `fieldset`, `legend`, group hint, group error, and per-option label structure.
- Group-level feedback belongs to the host app unless a future collection group helper explicitly defines that contract.
- Per-option labels and checked-state semantics should continue to follow ordinary Rails collection helper behavior.

A future visual lane is appropriate only after the helper contract is accepted, or if a PR explicitly marks the artifact as proposal-only and keeps it out of release evidence and current API inventory.

## Current boundary decision

This slice keeps collection checkbox and radio groups outside the current FormBuilder helper API. That is intentional, not an omission in the helper list.

Single-control wrappers and collection groups have different contracts:

- single checkbox or radio wrappers can delegate to one Rails input helper and reuse the field wrapper, label, hint, error, and accessibility wiring
- collection helpers must preserve a set of inputs with shared naming, selected-value semantics, per-option labels, and checked-state behavior
- collection groups need one group-level semantic boundary before any per-option wrapper details are useful
- group-level hint or validation feedback must not be confused with per-option hints, per-option disabled state, or business-specific option copy

A future helper should be planned as a separate collection group surface instead of being inferred from `rfk_check_box`, a future `rfk_radio_button`, or table metadata helpers.

## Future adoption criteria

A future Rails Fields Kit collection group helper should only become public after it can preserve the Rails defaults above and add a small, explicit wrapper contract for the group itself.

The minimum review checklist for a future helper is:

- preserve Rails collection parameter names and selected-value semantics without replacing standard Rails helper behavior
- preserve per-option checked-state behavior without redefining how Rails decides selected values
- render or accept a semantic `fieldset` and `legend` boundary for the whole group
- support group-level hint and validation feedback without confusing it with per-option labels or per-option hints
- wire group-level feedback through `aria-describedby` in a predictable way
- keep per-option label, hint, and disabled-state customization separate from group-level feedback
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
