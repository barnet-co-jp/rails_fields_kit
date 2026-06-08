# Selected preload payload contract

Selected preload resolves labels for values that are already present when an edit form loads. When a field uses `selected_url:`, the endpoint must return option objects that Rails Fields Kit can hand to Tom Select without inventing fallback options.

## Accepted shapes

Selected preload accepts the same value-field aware option shapes documented in the controller helper guide:

```json
{ "value": 1, "text": "Acme Corp" }
```

```json
{ "option": { "value": 1, "text": "Acme Corp" } }
```

```json
[{ "value": 1, "text": "Acme Corp" }]
```

```json
{ "options": [{ "value": 1, "text": "Acme Corp" }] }
```

```json
{ "results": [{ "value": 1, "text": "Acme Corp" }] }
```

When a field configures `value_field: "id"`, the same contract uses that configured key instead:

```json
{ "id": 1, "name": "Acme Corp" }
```

`label_field` should be returned whenever the endpoint knows a display label. It is not a validity requirement because the controller can fall back to the configured value field for display, but relying on that fallback makes edit forms less clear.

## Invalid success payloads

A 2xx selected preload response is treated as a payload error when it is empty or does not contain usable option objects. Examples include:

```json
null
```

```json
{}
```

```json
{ "text": "Acme Corp" }
```

```json
[{ "text": "Acme Corp" }]
```

Those responses dispatch `rails-fields-kit--tom-select:selected-load-error` and mark the optional error surface when one is configured. Rails Fields Kit does not add the requested selected value as an incomplete option, because doing so would hide endpoint drift behind a silent success.

Keep authorization, tenant scoping, missing-record policy, retry UI, and visible error copy in the host app. Rails Fields Kit only validates whether the successful JSON response contains option objects with the configured value field.
