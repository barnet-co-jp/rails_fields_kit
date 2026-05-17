# Rails Fields Kit 0.1.0 Release Notes

Rails Fields Kit 0.1.0 is the first release candidate for a Rails 7+ form helper kit focused on Tom Select-backed fields.

## Highlights

- Tom Select-backed Rails FormBuilder helpers.
- Editable remote comboboxes.
- Tag inputs and multiple selects.
- Autocomplete text fields.
- Create-on-the-fly options.
- Selected option preload for edit forms.
- Rich option rendering with description and badge fields.
- Controller-side JSON endpoint helpers.
- Wrapper, hint, error, prefix, suffix, and accessibility support.
- Stimulus events for integration hooks.
- Install generator and setup documentation.

## Main helpers

FormBuilder helpers:

- `rfk_select`
- `rfk_combobox`
- `rfk_autocomplete`
- `rfk_tags`
- `rfk_multi_select`
- `rfk_grouped_select`
- `rfk_enum_select`
- native helpers such as `rfk_text_field`, `rfk_money_field`, and `rfk_search_field`

Controller helpers:

- `rfk_search_with`
- `rfk_find_with`
- `rfk_create_with`

## Compatibility

- Rails: `>= 7.0`, `< 9.0`
- Ruby: `>= 3.1`
- Tom Select is installed by the host application.
- JavaScript bundling/importmap setup is intentionally owned by the host application.

## Verification

The release candidate should pass:

```bash
bundle exec rspec
bundle exec rake build
```

Known good local result before these notes were added:

- 70 examples, 0 failures
- `rails_fields_kit 0.1.0 built to pkg/rails_fields_kit-0.1.0.gem`

Before publishing, also run through [`sample_app_checklist.md`](sample_app_checklist.md).

## Suggested GitHub release body

```markdown
Rails Fields Kit 0.1.0 is the first release of a Rails 7+ form helper kit for Tom Select-backed fields.

### Highlights

- Searchable and editable comboboxes for Rails forms
- Tag inputs and multiple selects
- Selected option preload for edit forms
- Create-on-the-fly options
- Rich option rendering with description and badge fields
- Controller helpers for search, selected lookup, and create endpoints
- Wrapper/accessibility support for labels, hints, errors, prefixes, and suffixes
- Stimulus events for load, selected preload, create errors, and item interaction

### Compatibility

- Rails >= 7.0, < 9.0
- Ruby >= 3.1
- Tom Select must be installed by the host application

### Verification

- `bundle exec rspec`
- `bundle exec rake build`
- sample app checklist before publishing
```
