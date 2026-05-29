# Rails Fields Kit 0.1.1 Release Notes (Draft)

This draft assumes the next release after `0.1.0` will be `0.1.1`.

If release planning chooses a different version number, rename this file and keep the contents aligned with `CHANGELOG.md` instead of editing the `0.1.0` historical notes in place.

Rails Fields Kit 0.1.1 is a follow-up release that expands the documented public surface around token-oriented search, Ransack-compatible suggestion metadata, table metadata adapters, controller/helper integration details, a dedicated create-success event for create-on-the-fly flows, package-root rendered-field contract helpers, and opt-in inline request-failure placeholders while keeping query execution, visible copy ownership, and JavaScript package ownership in the host application.

## Highlights

- `rfk_token_search` for token-oriented search inputs such as `status:open keyword`.
- `rfk_token_suggestions_with` and `RailsFieldsKit::TokenSuggestions.build` for lightweight token suggestion JSON endpoints.
- `RailsFieldsKit::RansackSuggestions.build` for Ransack-compatible token suggestion metadata without requiring or executing Ransack.
- `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer` for table-oriented metadata integration.
- `rfk_table_filters` and `rfk_table_cell_editors` for rendering documented table metadata through a FormBuilder.
- `tomSelectTextOverrideContract(element)` for reading rendered Tom Select text override values from package-root JavaScript imports.
- `action:` support for `rfk_search_with`, `rfk_find_with`, and `rfk_create_with` so controller helpers can match custom routes.
- Fixed remote request params with `query_params:`, `selected_query_params:`, and `create_params:`.
- `rails-fields-kit--tom-select:create` as a dedicated create-on-the-fly success hook with `event.detail.input` and `event.detail.option`.
- Opt-in `error_surface:` / `error_surface_html:` helper options so request-failure events can expose a nearby placeholder as `event.detail.surface`.
- A normalized Tom Select failure event detail shape across remote search, selected preload, and create-on-the-fly failures.

## Main helpers and builders

FormBuilder helpers:

- `rfk_select`
- `rfk_combobox`
- `rfk_autocomplete`
- `rfk_tags`
- `rfk_multi_select`
- `rfk_grouped_select`
- `rfk_enum_select`
- `rfk_token_search`
- `rfk_table_filters`
- `rfk_table_cell_editors`
- native helpers such as `rfk_text_field`, `rfk_money_field`, and `rfk_search_field`

Controller helpers:

- `rfk_search_with`
- `rfk_find_with`
- `rfk_create_with`
- `rfk_token_suggestions_with`

Metadata and builder APIs:

- `RailsFieldsKit::TokenSuggestions.build`
- `RailsFieldsKit::RansackSuggestions.build`
- `RailsFieldsKit::TableFilterInput`
- `RailsFieldsKit::TableCellInput`
- `RailsFieldsKit::TableMetadata`
- `RailsFieldsKit::TableRenderer`

JavaScript package-root exports:

- `TomSelectController`
- `tomSelectTextOverrideContract(element)` for rendered text override values: `noResultsText`, `loadingText`, and `createText`

## Compatibility and responsibility boundary

- Rails: `>= 7.0`, `< 9.0`
- Ruby: `>= 3.1`
- Tom Select must still be installed by the host application.
- The host application still owns bundler or importmap setup for JavaScript entrypoints.
- Package-root rendered-field contract helpers only read data attributes already rendered by Rails Fields Kit; visible copy ownership, locale resolution, request execution, query parsing, retry UI, and validation feedback remain host-app responsibilities.
- Submitted token text parsing, `params[:q]` construction, authorization, scoping, pagination, and result execution remain host-app responsibilities.
- Visible success UI, toast copy, and follow-up app behavior after `rails-fields-kit--tom-select:create` remain host-app responsibilities.
- `error_surface:` only renders an opt-in nearby placeholder; visible error copy and retry behavior for that surface remain host-app responsibilities.
- Table metadata helpers expose rendering metadata only; they do not take over table preference persistence or query execution.

## Verification expectations

The release candidate should pass:

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
```

Before publishing, also confirm:

- GitHub Actions CI is green for the exact release commit.
- `doc/sample_app_results.md` is completed for the same branch head.
- documented JavaScript import paths resolve in the sample app.
- package-root helper exports such as `tomSelectTextOverrideContract(element)` can be imported from `rails_fields_kit` when that release surface is in scope.
- the sample app confirms `rails-fields-kit--tom-select:create`, `event.detail.input`, and `event.detail.option` when that release surface is in scope.
- representative request-failure flows confirm `event.detail.surface` when `error_surface:` is in scope for the release, and any visible inline error copy still belongs to the host app.
- `rails-fields-kit--tom-select:item-add` and `rails-fields-kit--tom-select:change` still describe the accepted selection after create succeeds.
- token suggestion and Ransack suggestion metadata checks pass if those surfaces are in scope for the release.
- table metadata helpers or `TableRenderer` call-spec paths are covered if they are in scope for the release.
- remote search, selected preload, create-on-the-fly, and failure event handling still match the current docs.

## Suggested GitHub release body

```markdown
Rails Fields Kit 0.1.1 expands the gem beyond the first 0.1.0 release with token-oriented search helpers, metadata-only Ransack suggestion builders, table adapter metadata for rendering documented field helpers through existing host-app table definitions, package-root rendered-field contract helpers, a dedicated create-success event for create-on-the-fly flows, and opt-in inline request-failure placeholder hooks.

### Highlights

- `rfk_token_search` for token-style query inputs
- `rfk_token_suggestions_with` and `RailsFieldsKit::TokenSuggestions.build`
- `RailsFieldsKit::RansackSuggestions.build` for metadata-only Ransack-compatible suggestions
- `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer`
- `rfk_table_filters` and `rfk_table_cell_editors`
- `tomSelectTextOverrideContract(element)` for rendered Tom Select text override values
- controller helper `action:` support and fixed request params
- `rails-fields-kit--tom-select:create` with `event.detail.input` / `event.detail.option`
- `error_surface:` / `error_surface_html:` with request-failure `event.detail.surface`
- normalized Tom Select failure event detail payloads

### Compatibility

- Rails >= 7.0, < 9.0
- Ruby >= 3.1
- Tom Select must still be installed by the host application

### Responsibility boundary

Rails Fields Kit still stops at UI helpers and metadata. Host applications remain responsible for token parsing, search execution, authorization, pagination, JavaScript package manager or importmap choices, visible copy and locale policy for rendered text overrides, visible success UI after create-on-the-fly succeeds, and visible error or retry UI around any opt-in `error_surface:` placeholder.

### Verification

- `bundle exec standardrb`
- `bundle exec rspec`
- `bundle exec rake build`
- sample app checklist and CI confirmation for the exact release commit
```
