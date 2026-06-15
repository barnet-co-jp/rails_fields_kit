# Slug Helper Boundary

Rails Fields Kit does not currently provide a dedicated title-to-slug helper such as `rfk_slug_field`. Host apps should keep slug workflows on the existing native wrapper lane until a future feature issue accepts a narrower public surface.

Use current helpers like `rfk_text_field` when the title or slug value is an ordinary text input that benefits from shared labels, hints, errors, affixes, and accessibility wiring:

```erb
<%= f.rfk_text_field :title,
  wrapper: true,
  hint: "Used as the source for this app's slug policy" %>

<%= f.rfk_text_field :slug,
  wrapper: true,
  hint: "Generated and validated by the host app" %>
```

That pairing keeps Rails Fields Kit in the native wrapper role. The gem owns the rendered input wrapper contract, while the host app owns the workflow that turns a title into a persisted slug.

## Current Boundary

Rails Fields Kit currently owns:

- ordinary native text field rendering through the existing helper family
- label, hint, error, affix, and accessibility wiring for those fields
- documentation that separates current public helpers from roadmap proposals

The host app owns:

- slug generation and normalization
- transliteration and locale-specific character handling
- reserved word policy
- uniqueness checks and conflict resolution
- model validation and persistence
- deciding whether the slug updates automatically, manually, or only before first save
- any preview, lock, or regeneration UI

## Future Slice

If this proposal moves beyond docs, the first feature issue should decide the smallest accepted surface before implementation. Reasonable candidates include:

- a title field and slug field data contract that lets host JavaScript connect the two fields
- a lightweight event hook that tells host code when the source title changed
- a helper wrapper that renders title/slug pair markup while leaving slug generation to the host app

A future slice should not add database changes, model validations, uniqueness checks, transliteration policy, or a Tom Select redesign. Those choices are application-specific and should stay outside Rails Fields Kit.

## Non-Goals

- no current `rfk_slug_field` public helper
- no built-in slugify algorithm
- no uniqueness or reserved-word policy
- no persistence or model validation behavior
- no JavaScript controller for automatic slug updates in the current public API
