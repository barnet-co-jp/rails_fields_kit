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

Labels come from the model class through `human_attribute_name`, with the humanized enum key as fallback. By default Rails Fields Kit builds the lookup key as `"#{method}.#{key}"`.

Use model I18n translations when the enum should display localized or product-specific labels:

```yaml
en:
  activerecord:
    attributes:
      order:
        status:
          draft: Draft
          published: Published
```

If a host application already uses another `human_attribute_name` key convention, configure the key builder instead of overriding Rails Fields Kit's private FormBuilder methods:

```ruby
RailsFieldsKit.configure do |config|
  config.enum_i18n_key = ->(method, value) { "#{method}/#{value}" }
end
```

`enum_i18n_key` must respond to `#call` and receives the enum attribute method and enum key. The default callable returns `"#{method}.#{value}"`, preserving the existing behavior.

The host application still owns the translation entries and wording. Rails Fields Kit only owns how the configurable key is passed to `human_attribute_name`.

## Option Metadata

`rfk_enum_select` accepts the same rendered-option metadata lane as collection-backed `rfk_select` for choices that are already present in the enum source:

```erb
<%= f.rfk_enum_select :status,
  disabled: ["archived"],
  option_html: {
    "draft" => { data: { state: "initial" } }
  } %>
```

Use value-array `disabled:` when an enum key should render as a disabled `<option>`. Use `option_html:` when an enum key needs rendered attributes such as `data` or classes before Tom Select connects. Hash keys are matched against the rendered enum option value, so explicit `enum:` sources still submit the enum key rather than the backing integer.

This metadata lane only decorates already-rendered enum options. It does not add an arbitrary label/value DSL, remote enum lookup, authorization policy, dynamic visibility rules, endpoint payload mapping, or rich Tom Select renderer behavior. If the option list is not Rails-enum-shaped, use `rfk_select` or a remote helper instead.

## Rendered Kind

`rfk_enum_select` renders `data-rails-fields-kit--tom-select-kind-value="enum_select"` so `tomSelectFieldKindContract(element)` can distinguish enum-backed select fields from arbitrary `rfk_select` fields.

This is only a read-only rendered contract signal. It does not change the select element, submitted enum keys, selected or disabled option handling, enum collection generation, Tom Select initialization, or the package-root contract reader return shape.

## Boundary

Use explicit `enum:` for a small hash-like enum source that follows the Rails enum shape. Do not use it as a general label/value DSL.

Choose `rfk_select` instead when you need arbitrary label/value pairs, object collections, custom collection shaping, or options that are not Rails enum-style keys.

Remote enum lookup, enum validation, authorization, query execution, production CSS, dynamic option visibility, and table metadata adapter behavior stay outside `rfk_enum_select`; use the dedicated helpers and docs for those paths.
