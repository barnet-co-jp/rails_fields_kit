# Default allow clear

`default_allow_clear` is an app-wide semantic default for Tom Select-backed helpers that should opt into Tom Select's `clear_button` affordance when a field does not make its own choice.

Configure it from the Rails Fields Kit initializer:

```ruby
RailsFieldsKit.configure do |config|
  config.default_allow_clear = true
end
```

When `default_allow_clear` is `true`, Tom Select-backed helpers add `clear_button` to the rendered `plugins` data value unless the helper passes `allow_clear:` explicitly.

## Field-level priority

Field-level `allow_clear:` is the semantic override for one helper render:

```erb
<%= f.rfk_select :status,
  collection: Order.statuses.keys,
  allow_clear: false %>
```

Use `allow_clear: true` when one field should be clearable even though the app-wide default is off. Use `allow_clear: false` when one field should suppress the semantic app-wide clear affordance.

`allow_clear: false` only suppresses Rails Fields Kit's semantic auto-add. It does not remove plugin names that the host app supplies directly through `plugins:` or `RailsFieldsKit.configuration.default_plugins`.

## Plugin boundaries

`default_plugins` remains a raw Tom Select plugin pass-through. It is not redefined as a clear-button policy. Field-level `plugins:` keeps the existing replacement behavior for that one field, then `allow_clear:` or `default_allow_clear` can add `clear_button` to the effective list.

For helpers that already seed Tom Select plugins, the responsibilities stay separate. `rfk_tags` and `rfk_token_search` use `remove_button` for multi-item removal by default; `default_allow_clear` adds the single clear affordance as a separate Tom Select plugin. Rails Fields Kit does not define the styling, assets, empty-state wording, selection mutation, or plugin lifecycle for either plugin.

## Non-goals

This option does not add production CSS, theme presets, Tom Select plugin assets, clear-button wording, empty-state copy, or JavaScript lifecycle behavior. Host applications remain responsible for installing Tom Select plugins and styling their affordances.
