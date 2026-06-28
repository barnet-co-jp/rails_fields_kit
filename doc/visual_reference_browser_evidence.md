# Visual Reference Browser Evidence

Use this runbook when a static visual reference PR is otherwise current but still needs browser-capable desktop and narrow viewport evidence. It is a manual reviewer aid, not CI automation, screenshot approval, or a merge bot.

## When to use it

Use this for narrow static HTML artifact PRs such as visual reference additions or copy/layout review lanes.

Good candidates:

- `doc/native_field_visual_reference.html`
- `doc/tom_select_plugin_clearable_review.html`
- `doc/table_metadata_visual_reference.html`
- another `doc/*visual_reference*.html` or `doc/*_review.html` artifact that the PR changes

Do not use this as proof for runtime behavior, Tom Select lifecycle behavior, request execution, production CSS, host-app copy policy, or public API adoption decisions. CI success and source review are useful context, but they are not browser visual approval.

## Minimal local check

From a local checkout of the PR branch:

```bash
git checkout <pr-branch>
python3 -m http.server 4173
```

Then open the artifact through the local server, for example:

```text
http://127.0.0.1:4173/doc/native_field_visual_reference.html
```

A local file URL is acceptable for purely static references, but the local server route is preferred because it matches relative links and assets more closely.

## Viewports

Check both of these unless the PR or reviewer asks for a different width:

- Desktop: about `1280x900`
- Narrow: about `390x844`

If the browser device toolbar uses a nearby width, record the actual width in the PR comment. The goal is not pixel-perfect approval; it is evidence that the changed lane remains readable at a normal desktop width and a phone-like narrow width.

## What to inspect

Record the changed lane or state, not the whole artifact by default.

Look for:

- labels, hints, validation copy, and boundary copy remain readable
- controls, chips, badges, affixes, and metadata rows do not overlap or clip
- long labels and long selected values wrap without hiding nearby content
- the changed lane still communicates its responsibility boundary
- links or index navigation used for the check still open the intended artifact

Keep the check scoped to the PR. If the artifact reveals a broader redesign need, file or link a follow-up issue rather than expanding the current static-docs PR.

## PR comment format

Use this concise comment when the browser check passes:

```markdown
Browser-capable visual evidence

- Artifact: `doc/...html`
- Branch/head: `<sha>`
- Viewports: desktop `<width>x<height>`, narrow `<width>x<height>`
- Lane/state checked: `...`
- Result: pass. Labels, hints, validation/boundary copy, controls, and metadata remain readable without overlap or clipping.
- Boundary kept: runtime behavior, production CSS, host-app copy, and merge approval remain out of scope.
```

Use this form when something blocks approval:

```markdown
Browser-capable visual evidence

- Artifact: `doc/...html`
- Branch/head: `<sha>`
- Viewports checked: desktop `<width>x<height>`, narrow `<width>x<height>`
- Lane/state checked: `...`
- Result: blocked.
- Blocker: `...`
- Boundary kept: CI/source review did not replace visual approval; runtime behavior, production CSS, and host-app copy remain out of scope.
```

## Relation to other evidence

For release-wide checks, record the result in `doc/sample_app_results.md` or the release PR comment when that is the active evidence log. For a narrow static visual PR, a PR comment is enough.

If the environment can only do source review, say that explicitly and name the remaining browser-capable check. Do not mark a visual reference as browser-approved unless the desktop and narrow browser review actually ran.