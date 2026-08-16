# PR freshness queue note

Use this note when an open pull request needs a current reviewer-facing freshness summary. Keep it manual and evidence-based. Do not use this template as a merge decision, stale-PR automation, branch-refresh automation, or visual approval substitute.

## Template

```markdown
PR freshness queue note:

- head: `<head-sha>`
- workflow run: CI #<run-number> / run `<run-id>`: `<success|failure|pending|not found>`
- combined status: `<empty|success|failure|pending>`; if empty, workflow runs were checked separately
- compare: `ahead_by:<n>` / `behind_by:<n>` / `status:<ahead|behind|diverged|identical>`
- mergeability: `<mergeable true|mergeable false|unknown>`
- changed files: `<file count>`; scope matches `<intended files or reason it does not>`
- classification: `<review-ready|needs-refresh|needs-browser-evidence|needs-human>`
- remaining gate: `<none|browser-capable desktop/narrow viewport evidence|human API/product decision|replacement/supersede choice|other>`
- next reviewer action: `<review/merge candidate|refresh against main|add visual evidence|human decision needed>`
```

## Classification guide

- `review-ready`: the head workflow is green, the compare is `behind_by:0`, the PR is mergeable, changed files match the intended scope, and no unresolved browser-capable or public API adoption review remains.
- `needs-refresh`: CI may be green, but it ran before the latest `main`, the compare shows `behind_by > 0` or `status:diverged`, the PR is not mergeable, or changed files include stale main-side noise.
- `needs-browser-evidence`: docs or static visual artifact scope is otherwise current, but desktop or narrow viewport evidence is still missing. CI success and source review do not replace this. Use `doc/visual_reference_browser_evidence.md` for the browser check runbook and `doc/visual_references.md#recording-browser-evidence` for the handoff template.
- `needs-human`: duplicate closing PR choice, helper naming, return shape, public adoption boundary, product surface decision, or another review decision cannot be resolved from CI and docs alone.

## Notes

- When the combined status list is empty, check the head commit's GitHub Actions workflow runs before saying CI is absent.
- For static visual PRs, record browser evidence separately from source review. A green CI run only confirms repository checks.
- When `classification` is `needs-browser-evidence`, link the exact artifact and changed lane, then point the next reviewer to `doc/visual_reference_browser_evidence.md` before asking for desktop or narrow viewport proof.
- For replacement PRs, link the superseded PR and say whether the old branch should be closed or left for human review.
- Keep the note short enough to paste into a PR comment without turning the PR body into a full audit log.
