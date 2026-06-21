# TypeScript Declaration Release Evidence

Use this guide when a release or narrow PR needs evidence that Rails Fields Kit exposes TypeScript declaration metadata for its documented JavaScript entrypoints.

This is a package metadata and editor-assistance lane. It does not define a new runtime API, require a host app to use TypeScript, or set a host-app `tsconfig` policy.

## Source of truth

- Runtime JavaScript exports: [`public_api.md#javascript-exports`](public_api.md#javascript-exports)
- Package metadata: `package.json`
- Declaration files: `app/javascript/rails_fields_kit/*.d.ts`

Keep `public_api.md#javascript-exports` as the helper and controller inventory. Do not duplicate the full export table here.

## Representative checks

For a release candidate or declaration-focused PR, record the smallest evidence that proves declaration visibility for the changed package metadata.

- [ ] `package.json` exposes a top-level `types` entry for `rails_fields_kit`.
- [ ] `package.json` exposes `exports["."].types` for the package-root import path.
- [ ] `package.json` exposes `exports["./tom_select_controller"].types` for the direct controller import path.
- [ ] Any direct helper subpath with a documented `types` entry still matches a documented runtime subpath in `package.json`.
- [ ] Evidence notes distinguish declaration metadata from runtime import behavior and host-app TypeScript configuration.

## Evidence notes template

Use this compact shape in a PR comment, release PR, or `sample_app_results.md` when declaration visibility is in scope.

```md
TypeScript declaration metadata evidence:

- Scope: package metadata / editor assistance only
- Source checked: `package.json`
- Package-root declaration: PASS / FAIL / SKIPPED
- Direct controller declaration: PASS / FAIL / SKIPPED
- Direct helper declaration subpaths, if in scope: PASS / FAIL / SKIPPED
- Runtime import behavior checked separately: yes / no / out of scope
- Host-app `tsconfig` policy changed: no
- Notes:
```

## Boundaries

Declaration visibility evidence does not replace JavaScript runtime import checks in [`sample_app_checklist.md`](sample_app_checklist.md) or release readiness checks in [`sample_app_results.md`](sample_app_results.md). Keep runtime import resolution, Stimulus registration, Tom Select installation, bundler aliases, and importmap pins in their existing setup lanes.
