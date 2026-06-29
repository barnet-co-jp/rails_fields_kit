# Selected Preload Release Gate

Use this narrow gate when validating Tom Select selected preload behavior before a release or release-prep PR.

## Scope

This page guards the current selected preload request contract. It does not add a new endpoint shape and does not change host-app query semantics.

Use [`selected_preload_contract.md`](selected_preload_contract.md) when validating endpoint payload shapes, especially the boundary where empty or unusable 2xx selected preload payloads dispatch `selected-load-error` instead of becoming incomplete options. Keep this page focused on release evidence, and keep payload examples and invalid-shape details in the contract doc.

## Single-value lane

- Render one edit-form field with `selected_url:` and a saved scalar ID.
- Confirm the field starts from an ID-only value and restores the visible label through the selected preload endpoint.
- Confirm the request uses the documented single-value parameter, usually `id`.
- Confirm the endpoint returns a usable option object with the configured value field; use [`selected_preload_contract.md`](selected_preload_contract.md) for accepted and invalid payload shapes.
- Confirm `rails-fields-kit--tom-select:selected-load` fires before the field settles into the selected state.
- Confirm a failure response or invalid success payload still dispatches `rails-fields-kit--tom-select:selected-load-error` and leaves any visible fallback UI or `error_surface:` handling to the host app.

## Multiple-value lane

- Render one edit-form field with `selected_url:` and multiple saved IDs.
- Confirm the field starts from ID-only values and restores visible labels for each saved ID.
- Confirm the request uses the configured `selected_multiple_param:` key.
- With the default configuration, confirm that outgoing JavaScript request key is `ids` and its value is comma-separated, for example `ids=1,2,3`.
- Confirm the endpoint accepts comma-separated `ids`, matching `rfk_find_with` documentation.
- Confirm the endpoint helper also accepts Rails-parsed Array input for the configured `ids_param:`, such as `params[:ids] == ["1", "2"]` or a custom `params[:customer_ids] == ["1", "2"]`.
- Treat raw repeated query keys or `ids[]` URLs as supported only after the host app request stack has normalized them to the configured param as an Array. Do not describe the bundled Tom Select request as sending repeated params unless the JavaScript request encoding changes in a separate feature.
- Confirm blank or whitespace-only values do not become lookup IDs when either comma-separated or Array input is used.
- Confirm the endpoint returns usable option objects with the configured value field for each restored ID; use [`selected_preload_contract.md`](selected_preload_contract.md) for accepted and invalid payload shapes.
- Keep changing the outgoing selected preload request encoding as a separate feature discussion unless release planning explicitly changes the public contract.

## Drift Checks

Before marking the gate complete, compare these sources:

- `README.md` for the default `selected_multiple_param: "ids"` guidance.
- `doc/controller_helpers.md` for `rfk_find_with` accepted params and selected preload output shapes.
- `doc/selected_preload_contract.md` for usable selected preload payloads and invalid 2xx payload handling.
- `app/javascript/rails_fields_kit/tom_select_controller.js` for the selected preload request encoding and payload validation.
- `doc/sample_app_checklist.md` and `doc/final_release_checklist.md` for the broader release checklist entries.

The release is ready only when JavaScript behavior, controller helper docs, selected preload payload contract docs, and release checklist expectations all describe the same selected preload request and payload boundary.