# Masked input boundary

Masked inputs are a future proposal, not current public API.

Rails Fields Kit currently keeps native wrapper helpers in the ordinary HTML input lane. Use helpers such as `rfk_text_field`, `rfk_phone_field`, `rfk_money_field`, `rfk_percent_field`, and related native wrappers when the host app wants shared labels, hints, errors, affixes, and accessibility wiring around a browser-native input.

For a static review surface that shows this boundary without adding runtime behavior, see [`masked_input_boundary_sample_evidence.html`](masked_input_boundary_sample_evidence.html). Treat that artifact as visual evidence for host-owned masking hooks, not as a new helper or public API proposal. It is focused boundary sample evidence, not a member of the maintained visual reference family or one-screen visual index.

## Current path

For mask-like behavior today, keep the Rails Fields Kit helper thin and let the host app own the masking layer:

```erb
<%= f.rfk_phone_field :phone,
  wrapper: true,
  inputmode: "tel",
  autocomplete: "tel",
  pattern: "[0-9()+ -]+",
  html: { data: { controller: "phone-mask" } } %>
```

Rails Fields Kit passes ordinary native attributes such as `pattern:`, `inputmode:`, `autocomplete:`, `maxlength:`, `required:`, `disabled:`, and `readonly:` to the rendered input. The host app can attach its preferred masking controller or library through `html:` data attributes without changing the Rails Fields Kit contract.

## Host app responsibilities

The host app remains responsible for:

- choosing and installing any masking library
- deciding locale-specific formatting, phone/currency conventions, and display copy
- normalizing submitted values before persistence
- validating values on the server
- deciding whether masked formatting is required, optional, or presentation-only
- handling browser validation messages and accessibility copy for mask-specific failures

Rails Fields Kit should not imply that masking behavior, locale formatting, server-side validation, or persistence normalization are built into the gem.

## Future feature gate

A future masked input feature should start from a separate follow-up issue. That issue should decide:

- whether the first slice is only wrapper/data hook/docs guidance or includes runtime masking behavior
- whether the feature belongs in the native wrapper family or a separate JavaScript helper lane
- which representative case comes first, such as phone, money, percent, or a custom pattern
- which mask library, if any, is allowed as a dependency

Do not add helper names such as `rfk_masked_field` to the current public API until that feature gate accepts a concrete runtime surface.

## Non-goals for the current docs slice

- no new FormBuilder helper
- no masking library dependency
- no JavaScript masking implementation
- no locale, currency, or phone formatting policy
- no server-side validation or persistence normalization
- no redesign of existing native wrapper helpers
