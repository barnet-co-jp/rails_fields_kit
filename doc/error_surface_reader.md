# Rendered error surface reader

`readRenderedErrorSurface(element)` is a package-root helper for host-app JavaScript that needs to find the same opt-in request-failure placeholder Rails Fields Kit already rendered for a Tom Select-backed field.

Use it when a Stimulus controller, integration test, or lightweight feedback adapter starts from the rendered field element and wants the `error_surface:` placeholder without re-implementing generated id or DOM lookup rules.

```js
import { readRenderedErrorSurface } from "rails_fields_kit"

const surface = readRenderedErrorSurface(fieldElement)
if (surface) {
  surface.hidden = false
  surface.textContent = "Unable to load options"
}
```

## Return value

The helper returns:

- the configured placeholder element when the field has `data-rails-fields-kit--tom-select-error-surface-id-value` and the element exists in the same document
- `null` when the field did not opt into `error_surface:`
- `null` when the configured placeholder id no longer exists
- `null` for non-element or missing inputs

The same lookup works when the field uses `error_surface_html:` with a custom id or wrapper element, because Rails Fields Kit renders that custom id into the field's data value.

## Boundary

This helper is read-only. It does not create an error surface, generate ids, dispatch events, reveal or hide feedback, mutate Tom Select, retry requests, or decide visible error copy.

Request-failure events still expose `event.detail.surface` for the active failure path. Use `readRenderedErrorSurface(element)` when the host app needs the placeholder before or outside a failure event, and use `events.md` for the request lifecycle event contract.
