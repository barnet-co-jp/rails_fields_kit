# Tom Select Turbo lifecycle

Rails Fields Kit enhances rendered select elements through the Stimulus controller registered as `rails-fields-kit--tom-select`.

## Boundary

The controller relies on the normal Stimulus lifecycle:

- `connect()` creates one Tom Select instance for the element.
- During connect, server-rendered selected state is normalized before an optional `selected_url:` request: known value + label state is reused, while ID-only unresolved state remains eligible for selected preload.
- `disconnect()` marks the controller disconnected, aborts in-flight remote requests, destroys the Tom Select instance, and clears the instance reference.
- Reconnect creates a fresh Tom Select instance from the server-rendered element and applies the same initial-state rules again.

Turbo-enabled host apps should not add a separate `turbo:load` reinitializer for normal `rfk_*` fields. Register the controller once on the host app's existing Stimulus application and let Stimulus connect and disconnect controllers as Turbo replaces or restores DOM.

## Turbo cache note

This gem does not currently install a global `turbo:before-cache` listener. The supported boundary is the controller-local `disconnect()` cleanup plus the request abort and stale-response guards documented in the events guide.

If a host app keeps custom Tom Select markup alive outside normal Stimulus-managed DOM replacement, that app owns the additional cleanup policy for that markup. Do not duplicate Rails Fields Kit controller registration on every Turbo visit; duplicated registration can make reconnect behavior harder to reason about.

## QA checklist

- Navigate away from a page containing an `rfk_select` or `rfk_combobox`, then return with Turbo Drive enabled.
- Confirm the field reconnects with a single Tom Select wrapper.
- For a server-rendered `{ value:, text: }` selection, confirm reconnect keeps the label without an unnecessary `selected_url:` request.
- For an ID-only scalar selection with `selected_url:`, confirm reconnect still hydrates the missing label even if the initial HTML temporarily contains that ID as an option.
- For `rfk_lookup`, confirm server-rendered text + ID reconnects as the visible label + hidden ID pair, while ID-only state can still hydrate its text through `selected_url:`.
- Trigger a remote search and navigate away before it completes; the old request should not update a disconnected controller.
- Confirm selected preload and create-on-the-fly failure handlers still dispatch their documented events after reconnect.
