# Native Constraint Attribute Evidence

Use this guide when a release or focused PR needs sample-app evidence for ordinary native input attributes on Rails Fields Kit native helpers.

This guide complements the `Native constraint attribute checks` section in `doc/sample_app_results.md`. It helps reviewers choose a representative helper and record evidence without turning browser-native constraints into Rails Fields Kit-owned validation UI.

## When to Use This Lane

Use this lane when the change under review affects native helper constraint pass-through, release evidence for native helper constraints, or documentation around ordinary native input attributes.

Good fits include:

- text-like native helpers that pass through `required`, `maxlength`, `minlength`, `pattern`, `autocomplete`, or `inputmode`
- range-style native helpers that pass through `min`, `max`, or `step`
- evidence updates that need to show rendered attributes on the input element while keeping wrapper and accessibility checks separate

Keep this lane out of scope when the change is about:

- browser validation message wording
- masking, formatting, character counters, or custom validation UI
- server-side validation policy
- production CSS or visual reference approval
- Tom Select remote lifecycle or package-root JavaScript helper evidence

## Representative Helper Choice

Choose one representative helper that matches the changed surface. Do not expand the release check to every native helper unless the release itself changes the native helper family broadly.

| Changed surface | Representative helper | Attribute examples | Evidence note |
| --- | --- | --- | --- |
| text-like native field constraints | `rfk_text_field`, `rfk_email_field`, or the changed helper | `required`, `maxlength`, `minlength`, `pattern`, `autocomplete`, `inputmode` | Record that the attributes reached the rendered input and remained ordinary browser-native attributes. |
| numeric or range constraints | `rfk_range_field`, `rfk_number_field`, or the changed helper | `min`, `max`, `step`, `required` | Record that numeric constraints reached the rendered input without claiming custom slider or validation behavior. |
| field with wrapper/accessibility evidence also in scope | the same representative native helper used in the wrapper lane | one or two changed constraint attributes plus wrapper/hint/error state | Record constraint attributes separately from wrapper/accessibility evidence so the lanes do not blur. |

## Evidence Template

Use this compact template in a PR comment or in `doc/sample_app_results.md`.

```markdown
Native constraint attribute evidence

- Representative helper:
- Representative field or route:
- Branch / commit:
- Attribute set checked:
- Result: PASS / FAIL / SKIPPED
- Evidence location:
- Notes:
  - Constraint attributes reached the rendered input element.
  - Wrapper, hint, error, affix, and accessibility wiring were checked separately when in scope.
  - Browser validation copy, masking, character counters, and server-side validation remained host-app responsibilities.
```

## Review Checklist

- [ ] The representative helper was chosen from the current release or PR scope.
- [ ] The checked attributes are ordinary native input attributes, not a new Rails Fields Kit validation UI.
- [ ] The evidence names the rendered field, route, branch or commit, and result.
- [ ] `required`, `disabled`, or `readonly` evidence is described as native input state only.
- [ ] Range evidence for `min`, `max`, or `step` does not imply custom slider behavior, query execution, or persistence policy.
- [ ] Wrapper, hint, error, affix, and accessibility wiring are either checked in their own lane or explicitly out of scope.
- [ ] Browser validation message wording, masking, character counters, formatting, and server-side validation remain host-app responsibilities.
- [ ] Static visual reference review, if needed, is recorded in the visual reference lane rather than this sample-app evidence lane.

## Example Notes

Text-like helper example:

```markdown
Native constraint attribute evidence

- Representative helper: `rfk_text_field`
- Representative field or route: sample app profile name field
- Branch / commit: release-candidate SHA
- Attribute set checked: `required`, `maxlength`, `pattern`, `autocomplete`
- Result: PASS
- Evidence location: release PR comment
- Notes: attributes reached the input element; browser validation wording and server-side validations stayed host-app owned.
```

Range helper example:

```markdown
Native constraint attribute evidence

- Representative helper: `rfk_range_field`
- Representative field or route: sample app rating range field
- Branch / commit: focused helper PR SHA
- Attribute set checked: `min`, `max`, `step`
- Result: PASS
- Evidence location: PR comment
- Notes: attributes reached the input element; no custom slider UI, masking, query execution, or persistence behavior was claimed.
```
