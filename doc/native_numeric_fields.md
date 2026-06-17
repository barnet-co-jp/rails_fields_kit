# Native Numeric Field Wrappers

`rfk_number_field`, `rfk_money_field`, and `rfk_percent_field` are thin native wrapper helpers for numeric-looking inputs. Use them when the browser-native input flow is enough, but the host app wants Rails Fields Kit's shared wrapper, label, hint, error, affix, and accessibility wiring around that input.

```erb
<%= f.rfk_number_field :quantity,
  wrapper: true,
  label: "Quantity",
  hint: "Use whole units",
  min: 0,
  step: 1 %>
```

```erb
<%= f.rfk_money_field :amount,
  wrapper: true,
  label: "Amount",
  currency: "JPY",
  inputmode: "decimal" %>
```

```erb
<%= f.rfk_percent_field :tax_rate,
  wrapper: true,
  label: "Tax rate",
  min: 0,
  max: 100,
  step: 0.1 %>
```

## Helper Mapping

- `rfk_number_field` delegates to Rails' native `number_field` helper.
- `rfk_money_field` delegates to Rails' native `text_field` helper, defaults `inputmode` to `decimal`, and uses `currency:` as the prefix when provided.
- `rfk_percent_field` delegates to Rails' native `number_field` helper, defaults `inputmode` to `decimal`, and defaults the suffix to `%` unless `suffix:` is explicitly provided.

All three helpers keep submitted value handling in the ordinary Rails form path. Options such as `min:`, `max:`, `step:`, `value:`, `required:`, `disabled:`, `readonly:`, `inputmode:`, `autocomplete:`, and `html:` stay native input attributes or Rails helper options.

## Responsibility Boundary

Rails Fields Kit owns the shared native wrapper contract:

- optional `wrapper: true` field shell
- generated label, hint, validation error, prefix, and suffix output
- `aria-describedby`, `aria-invalid`, and `aria-required` wiring unless `accessibility: false` is passed
- field-level wrapper customization through `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, `suffix_html:`, and `html:`

The host app remains responsible for number formatting, locale-specific separators, rounding, currency conversion, currency display policy, decimal precision, browser validation-message wording, server-side validation, and persistence. Rails Fields Kit does not normalize numeric strings, parse currency values, format submitted params, or add masking JavaScript.

Use `rfk_range_field` instead when the user should manipulate a browser-native slider rather than type a numeric value. Use ordinary Rails helpers or host-app markup when a custom formatter, masked input, or locale-aware numeric component owns the field behavior.
