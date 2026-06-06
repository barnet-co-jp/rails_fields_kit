# TableMetadata collection evidence

Use this note when a release or focused PR needs sample-app evidence for `RailsFieldsKit::TableMetadata` collection sources. This is an evidence guide only; it does not add a new runtime contract or make query execution, table persistence, authorization, or result rendering a Rails Fields Kit responsibility.

## When to use this lane

Record this lane in `sample_app_results.md` or a scoped PR comment when the reviewed change touches table metadata collection, table adapter docs, or release evidence around table filters and cell editors.

For ordinary releases where table metadata behavior did not change, the focused specs and [`table_adapters.md`](table_adapters.md) remain the source of truth.

## Representative checks

Choose the smallest set that matches the release surface under review:

- Hash column: a single hash with `filter:` or `cell_editor:` is treated as one column definition, not as a key/value list.
- Hash-like column: an object with `to_hash` returning a metadata-key hash is collected as one column definition.
- Object column: a public metadata reader such as `filter`, `filter_input`, `editor`, or `cell_editor` is collected without treating inherited enumerable methods as metadata.
- Table-like source: an object responding to `columns` is read first, then the same column-source rules are applied to the returned value.
- Explicit `false`: a recognized metadata key set to `false` is skipped so a host integration can disable a filter or editor without removing the rest of the column definition.

## Boundaries to record

When recording evidence, name the source shape checked, the representative helper or metadata object, and the observed result. Keep these boundaries explicit:

- Rails Fields Kit collects and normalizes metadata for rendering assistance.
- The host app or table integration owns query execution, authorization, persistence, pagination, and user-facing result copy.
- `TableRenderer` registry checks, Ransack metadata, and table preference persistence are separate evidence lanes unless the release explicitly touches them.

## Example PR comment shape

```text
TableMetadata collection evidence:
- Source shape: hash-like column and table-like object
- Disabled metadata: explicit false filter skipped as expected
- Rendering boundary: collected metadata only; query execution and persistence stayed host-owned
- Evidence: sample app branch <branch>, commit <sha>, CI <run>
```
