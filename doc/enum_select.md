# rfk_enum_select enum source boundary

`rfk_enum_select` is the Rails enum-oriented select helper. By default it reads the enum-like source from the model class method that matches the pluralized attribute name, such as `Order.statuses` for `:status`.

An explicit `enum:` hash is also supported for the same Rails enum-shaped contract:

```erb
<%= f.rfk_enum_select :status,
  enum: { "draft" => 0, "published" => 1 } %>
```

## Submitted Values

The hash keys are the submitted option values. The values in the hash are treated as the enum backing values and are not submitted by the rendered select.

For example, `enum: { "draft" => 0, "published" => 1 }` renders options with `value="draft"` and `value="published"`.

This keeps the explicit source aligned with Rails enum params, where the symbolic/string enum key is the public form value.

## Labels

Labels still come from the model class via `human_attribute_name("#{method}.#{key}")`, with the humanized key as fallback.

Use model I18n translations when the explicit hash should display localized or product-specific labels:

```yaml
en:
  activerecord:
    attributes:
      order:
        status:
          draft: Draft
          published: Published
```

## Rendered Kind

`rfk_enum_select` renders `data-rails-fields-kit--tom-select-kind-value="enum_select"` so `tomSelectFieldKindContract(element)` can distinguish enum-backed select fields from arbitrary `rfk_select` fields.

This is only a read-only rendered contract signal. It does not change the select element, submitted enum keys, selected or disabled option handling, enum collection generation, Tom Select initialization, or the package-root contract reader return shape.

## Boundary

Use explicit `enum:` for a small hash-like enum source that follows the Rails enum shape. Do not use it as a general label/value DSL.

Choose `rfk_select` instead when you need arbitrary label/value pairs, object collections, disabled options with custom grouping semantics, or options that are not Rails enum-style keys.

Remote enum lookup, Ransack filters, enum i18n policy, enum validation, authorization, query execution, production CSS, and table metadata adapter behavior stay outside `rfk_enum_select`; use the dedicated helpers and docs for those paths.
