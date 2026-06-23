# Dropdown parent release evidence

Use this focused evidence note when a release or sample-app review needs to confirm the Tom Select-backed `dropdown_parent:` option added by #1944. Keep the lane limited to selector pass-through and no-config behavior; do not turn the sample-app checklist into an exhaustive Tom Select option inventory.

## Current source of truth

- Ruby helper source: `lib/rails_fields_kit/form_builder.rb` assigns the field-level `dropdown_parent:` option to the rendered `data-rails-fields-kit--tom-select-dropdown-parent-value` contract.
- JavaScript source: `app/javascript/rails_fields_kit/tom_select_controller.js` exposes the `dropdownParent` Stimulus value and passes it to Tom Select only when the rendered value exists.
- Existing behavior guards: `spec/rails_fields_kit/tom_select_dropdown_parent_spec.rb` and `scripts/check_tom_select_dropdown_parent.mjs` cover `dropdown_parent: "body"` and omitted-option behavior.

## Representative release lanes

| Lane | Representative check | Rails Fields Kit responsibility | Host app responsibility |
| --- | --- | --- | --- |
| Selector pass-through | Render a Tom Select-backed helper with `dropdown_parent: "body"`; confirm the rendered data value reaches Tom Select as `dropdownParent: "body"`. | Preserve the string selector and pass it through when the rendered value is present. | Choose a valid selector and own the surrounding modal, drawer, or portal markup. |
| No-config boundary | Render the same helper without `dropdown_parent:`; confirm `dropdownParent` is absent from Tom Select options. | Omit `dropdownParent` unless the host app explicitly renders the option. | Treat default dropdown placement and any overlay integration as app-owned behavior. |

## Evidence location

For a release PR or sample-app pass, record the representative result in `doc/sample_app_results.md` or the release PR comment and link back to this note. The evidence only needs to show the selector pass-through lane and the no-config lane above.

Do not use this lane as proof of browser positioning, modal layout, portal implementation, z-index policy, or production CSS. Those remain host-app responsibilities and need separate host-app evidence when they matter.
