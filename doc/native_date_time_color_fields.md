# Native date, time, datetime, and color fields

Rails Fields Kit provides thin native wrapper helpers for browser-native date, time, datetime-local, and color inputs:

```erb
<%= f.rfk_date_field :starts_on,
  wrapper: true,
  label: "Start date",
  hint: "Use the project timezone",
  min: Date.current %>

<%= f.rfk_time_field :starts_at,
  step: 900 %>

<%= f.rfk_datetime_local_field :published_at %>

<%= f.rfk_color_field :accent_color %>
```

These helpers stay in the same native wrapper lane as `rfk_text_field`, `rfk_number_field`, and `rfk_range_field`. They delegate to Rails' native FormBuilder helpers and reuse Rails Fields Kit's wrapper, label, hint, error, affix, and accessibility wiring.

## Public helper mapping

| Rails Fields Kit helper | Rails helper | Rendered input family |
| --- | --- | --- |
| `rfk_date_field` | `date_field` | `type="date"` |
| `rfk_time_field` | `time_field` | `type="time"` |
| `rfk_datetime_local_field` | `datetime_local_field` | `type="datetime-local"` |
| `rfk_color_field` | `color_field` | `type="color"` |

Ordinary Rails options such as `min:`, `max:`, `step:`, `required:`, `disabled:`, and `readonly:` pass through to the rendered input. Use `html:` when you want to group input attributes next to wrapper customization.

## Responsibility boundary

Rails Fields Kit owns only the shared native wrapper contract around these inputs. The host app remains responsible for:

- browser-native picker behavior and browser support differences
- locale-specific formatting or parsing policy
- custom date picker, time picker, or color picker integrations
- masking, polyfills, and production CSS for picker controls
- server-side validation rules and validation copy
- timezone conversion and storage semantics

Use these helpers when the browser-native control is already the right input and the app wants Rails Fields Kit's wrapper and accessibility conventions around it. Choose a host-app component instead when the product needs custom calendars, time-zone-specific scheduling UI, masked input behavior, or a non-native color picker workflow.
