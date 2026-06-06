# Final release checklist

Use this checklist immediately before cutting a release.

## Public API and docs

- [ ] CHANGELOG documents all public API changes and migration notes.
- [ ] README references only current public helpers and import paths.
- [ ] `doc/public_api.md` matches the package-root export surface.
- [ ] Package-root export matrix includes every supported JavaScript helper.
- [ ] readRenderedSelectedPreloadConfig(element) resolves from rails_fields_kit, reads rendered selected preload config values such as selectedUrl, param names, and selectedQueryParams, and keeps selected preload request execution, endpoint authorization, visible fallback, and retry UI as host-app responsibilities.
- [ ] Deprecated helpers are absent from generated docs and examples.

## JavaScript package

- [ ] `package.json` exports field matches shipped files.
- [ ] ESM and CJS entrypoints are built and smoke-tested.
- [ ] Type declarations, if present, match runtime exports.
- [ ] Package tarball contents include only intended runtime files, docs, and metadata.
- [ ] No local build artifacts or cache directories are included.

## Rails integration

- [ ] Dummy app boots in the supported Rails versions.
- [ ] Engine initializers load without warnings.
- [ ] Request/helper specs cover documented integration paths.
- [ ] Generated assets are compatible with the supported bundling paths.

## Compatibility and verification

- [ ] Test matrix is green for supported Ruby, Rails, and Node versions.
- [ ] Lint, typecheck, and package smoke checks have been run.
- [ ] CI failures, if any, are confirmed unrelated to release changes and documented.
- [ ] Version bump is consistent across gem/package metadata.

## Release artifacts

- [ ] Gem build succeeds and contents are inspected.
- [ ] npm package build succeeds and tarball contents are inspected.
- [ ] Release notes mention any migration or compatibility guidance.
- [ ] Tag, gem, and npm package versions are aligned.
