# Styling Boundary

Rails Fields Kit renders a small set of wrapper and affordance classes so host apps can target fields consistently, but those classes are styling hooks rather than a bundled theme or layout system.

Use this document when you need the reader-facing source of truth for wrapper classes and host-app CSS ownership. Use [`configuration.md`](configuration.md#wrapper-and-affix-classes) for initializer defaults and [`visual_references.md`](visual_references.md) for static review routes.

For release or PR evidence, record what was checked in [`sample_app_results.md`](sample_app_results.md)'s native wrapper customization checks or visual reference render matrix. Link the evidence back here for the styling boundary, to [`configuration_wrapper_class_visual_reference.html`](configuration_wrapper_class_visual_reference.html) when reviewers need a rendered class pass-through lane, and to [`tom_select_class_names_visual_boundary.html`](tom_select_class_names_visual_boundary.html) when they need to compare wrapper hooks with Tom Select internal generated part class names.

## Current styling hooks

These class names come from `RailsFieldsKit::Configuration` defaults and are appended when the matching wrapper element is rendered.

| Hook | Default class | Rendered for | Override path |
| --- | --- | --- | --- |
| Field wrapper | `rfk-field` | Native and Tom Select-backed helpers when `wrapper:` renders a wrapper | `config.wrapper_class`, plus per-field `wrapper_html:` classes |
| Error-state wrapper | `rfk-field--error` | Field wrappers when the backing object has errors for the method | `config.field_error_class` |
| Label | `rfk-label` | Generated labels unless `label: false` is passed | `config.label_class`, plus per-field `label_html:` classes |
| Hint | `rfk-hint` | Generated hint copy | `config.hint_class`, plus per-field `hint_html:` classes |
| Validation error | `rfk-error` | Generated validation error copy | `config.error_class`, plus per-field `error_html:` classes |
| Affix control wrapper | `rfk-control` | The control wrapper when `prefix:` or `suffix:` is rendered | `config.control_class`, plus per-field `control_html:` classes |
| Prefix | `rfk-prefix` | Generated prefix element | `config.prefix_class`, plus per-field `prefix_html:` classes |
| Suffix | `rfk-suffix` | Generated suffix element | `config.suffix_class`, plus per-field `suffix_html:` classes |

Request-failure placeholders use `rfk-tom-select-error-surface` when a Tom Select-backed field opts into `error_surface: true`. That class identifies the generated status placeholder; visible copy, reveal timing, retry UI, and styling remain host-app responsibilities.

Tom Select internal generated parts use a separate lane. Use field-level [`tom_select_class_names:`](tom_select_class_names.md) when one Tom Select-backed helper needs to pass Tom Select's `classNames` option for generated control, dropdown, option, item, or loading states. Use [`tom_select_class_names_visual_boundary.html`](tom_select_class_names_visual_boundary.html) for a static review lane that compares that internal classNames pass-through with Rails Fields Kit wrapper hooks. That option is not an initializer-level Rails Fields Kit theme, and it does not make Rails Fields Kit own production CSS, theme presets, dark mode, density, or Tom Select internal DOM compatibility.

## Responsibility boundary

Rails Fields Kit owns these pieces:

- Rendering the documented wrapper, label, hint, error, control, prefix, and suffix hooks when the corresponding helper options ask for them.
- Appending initializer defaults and per-field `*_html:` classes instead of replacing host-app classes.
- Keeping wrapper, hint, error, affix, and accessibility wiring available to both native wrapper helpers and Tom Select-backed helpers.
- Passing field-level `tom_select_class_names:` through to Tom Select when one helper explicitly asks for internal class hooks.

Host apps own these pieces:

- Production CSS, CSS framework integration, theme tokens, dark mode, density, spacing, and responsive layout policy.
- Deciding whether the default `rfk-*` hooks are enough or whether initializer defaults should be replaced with application-specific classes.
- Deciding which Tom Select internal `classNames` values are appropriate for the host app's Tom Select version and stylesheet.
- Styling Tom Select plugin affordances, request-failure visible feedback, password-specific UX, textarea autosize behavior, browser validation copy, and table layout.

## Native and Tom Select differences

Native wrapper helpers such as `rfk_text_field`, `rfk_text_area`, and `rfk_password_field` render ordinary Rails/native inputs inside the wrapper lane. Their styling hooks surround native input semantics; Rails Fields Kit does not take over browser validation UI, masking, formatting, or password-specific behavior.

Tom Select-backed helpers such as `rfk_select`, `rfk_combobox`, and `rfk_token_search` use the same wrapper lane for labels, hints, errors, and affixes, then attach the Rails Fields Kit Stimulus controller and rendered data values for Tom Select. Host apps still own Tom Select installation, plugin assets, endpoint behavior, visible feedback copy, and any CSS required by the chosen Tom Select theme.

## What this document is not

This is not a full helper markup inventory, design system catalog, CSS preset, visual approval checklist, or release evidence log. The exact private helper methods and non-documented internal markup can change within the compatibility policy. When a review needs rendered-state readability, use the static visual reference family and record browser evidence separately instead of treating this file as screenshot approval.
