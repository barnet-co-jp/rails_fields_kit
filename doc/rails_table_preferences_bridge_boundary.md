# Rails Table Preferences bridge boundary

This proposal note keeps the Rails Table Preferences bridge as a metadata and rendering boundary first. It does not add a runtime adapter, hard dependency, or table execution behavior.

Use this page with [`table_adapters.md`](table_adapters.md) when a host app wants Rails Table Preferences column metadata to render Rails Fields Kit controls.

## Current first route

The first supported route is duck-typing and docs recipe, not a dedicated adapter module.

Rails Fields Kit can accept column-like definitions that expose Rails Fields Kit metadata through one of the current table metadata paths:

- objects responding to `to_table_filter`
- objects responding to `to_table_cell_editor`
- hash-like metadata that can be normalized by `TableMetadata`
- table-like objects whose `columns` return those column definitions

This lets Rails Table Preferences keep its own column and saved-state contract while Rails Fields Kit only renders metadata that has already crossed the boundary.

## Ownership split

Rails Table Preferences owns:

- column keys and labels
- filter and editor metadata attached to table columns
- saved table state, including visibility, order, widths, filters, and sorts
- adapter params and renderer registry lookup
- export metadata derived from table preferences

Rails Fields Kit owns:

- `TableFilterInput`, `TableCellInput`, `TableMetadata`, and `TableRenderer` metadata normalization
- FormBuilder helper mapping and call specs
- concrete `rfk_*` helper HTML
- Tom Select and native wrapper behavior for the rendered controls

The host application owns:

- query execution and accepted query params
- authorization and scoping
- pagination, sorting execution, and result navigation
- persistence policy for table preference records
- remote option endpoints, selected-option preload policy, validation copy, retry UI, and visible success/error feedback

## Dependency policy

Do not add a `rails_table_preferences` dependency to Rails Fields Kit for this first slice. The current public contract should stay dependency-light:

- Rails Fields Kit can render metadata supplied by a table integration.
- Rails Table Preferences can carry Rails Fields Kit metadata objects or renderer type names.
- The host app decides whether both gems are installed and how they are wired together.

An optional adapter module can be considered later only after the Rails Table Preferences side has finalized which metadata contract it wants to expose. That follow-up should be limited to a small representative mapping, such as text, select, token-search, and cell editor metadata. It should not mirror the full Rails Table Preferences DSL.

## Non-goals for this issue

This issue does not add:

- a Rails Table Preferences hard dependency
- a `gemspec` or Gemfile dependency change
- table preference persistence
- query execution or Ransack execution
- authorization, pagination, sorting execution, or bulk action execution
- a full table preference DSL mirror
- docs-portal Gemfile bumps, pinned SHA changes, or downstream smoke tests

## Follow-up split

After the Rails Table Preferences side has clarified its source-of-truth metadata contract, split follow-up work by responsibility:

- optional adapter module comparison or implementation
- sample app or release evidence for a representative host-app bridge
- docs-portal pilot and browser smoke in the downstream repository
- visual review artifacts if a concrete rendered table lane needs human readability evidence

Keep each follow-up narrow enough that it can be reviewed without re-deciding persistence, query execution, authorization, or dependency policy.