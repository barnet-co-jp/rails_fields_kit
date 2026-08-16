# Range Field Helper

`rfk_range_field` is the native wrapper lane for Rails' `range_field` helper. Use it when the browser-native slider is enough, but the host app wants Rails Fields Kit's shared wrapper, label, hint, error, affix, and accessibility wiring around that input.

```erb
<%= f.rfk_range_field :score,
  wrapper: true,
  label: "Score",
  hint: "Choose a value from 0 to 100",
  min: 0,
  max: 100,
  step: 5 %>
```

The helper delegates to Rails' native `range_field`, so submitted value handling and ordinary HTML attributes such as `min:`, `max:`, `step:`, `value:`, `disabled:`, `required:`, and `html:` stay in the normal Rails/native input flow.

## Release Evidence Lane

When `rfk_range_field` is in release or PR scope, record it as feature-specific native wrapper evidence rather than a new release-wide checklist family. Use the native helper representative wrapper and accessibility lane in [`sample_app_results.md`](sample_app_results.md), and use the native constraint attribute lane when the release needs explicit `min`, `max`, or `step` pass-through evidence.

A representative check should render one `rfk_range_field` with `wrapper: true`, label, hint, and a validation error state, plus ordinary range options such as `min:`, `max:`, and `step:`. Confirm the rendered input remains `type="range"`, the range attributes reach the input, and the shared wrapper / label / hint / error / `aria-describedby` wiring matches the rest of the native helper family.

For a narrow docs or helper PR, a PR comment is enough when it names the representative field, branch or commit, checked lane, and result. Use `sample_app_results.md` when preparing a release candidate or when the release depends on this lane.

## Responsibility Boundary

Rails Fields Kit owns the same native wrapper contract used by `rfk_text_field`, `rfk_number_field`, and the rest of the native helper family:

- optional `wrapper: true` field shell
- generated label, hint, and validation error output
- `aria-describedby`, `aria-invalid`, and `aria-required` wiring unless `accessibility: false` is passed
- optional prefix/suffix affix wrapper

The host app remains responsible for browser-specific range UI behavior, custom slider styling, live value previews, multi-thumb range controls, validation policy, and production CSS. Rails Fields Kit does not add JavaScript for live preview or replace the browser-native range control.

Use `rfk_number_field` instead when users need typed numeric entry rather than a browser-native range slider.
