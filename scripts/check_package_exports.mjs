import { mkdtemp, mkdir, cp, writeFile, rm, readFile } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"
import assert from "node:assert/strict"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-package-exports-"))

function markdownSection(markdown, heading) {
  const headingLine = `${heading}\n`
  const headingIndex = markdown.indexOf(headingLine)
  if (headingIndex === -1) return ""

  const sectionRemainder = markdown.slice(headingIndex + headingLine.length)
  const nextHeadingIndex = sectionRemainder.search(/\n##\s+/)

  return nextHeadingIndex === -1 ? sectionRemainder : sectionRemainder.slice(0, nextHeadingIndex)
}

function documentedPackageRootExportRows(markdown) {
  const javascriptExportsSection = markdownSection(markdown, "## JavaScript exports")

  return javascriptExportsSection
    .split("\n")
    .map((line) => {
      const match = line.match(/^\| `(?<exportName>[^`]+)` \| (?<kind>[^|]+) \|/)
      if (!match?.groups) return null

      return {
        exportName: match.groups.exportName.replace(/\(.*\)$/, ""),
        kind: match.groups.kind.trim()
      }
    })
    .filter(Boolean)
}

function documentedCallableHelperExports(exportRows) {
  return exportRows
    .filter(({ kind }) => /\bcontract reader\b/i.test(kind))
    .map(({ exportName }) => exportName)
}

async function packageRootNamedExportsFromDocs() {
  const publicApiDocs = await readFile(path.join(repoRoot, "doc", "public_api.md"), "utf8")
  const documentedExportRows = documentedPackageRootExportRows(publicApiDocs)
  const documentedExports = documentedExportRows.map(({ exportName }) => exportName)

  assert.ok(
    documentedExports.length > 0,
    "doc/public_api.md JavaScript exports table must document at least one package-root export"
  )
  assert.equal(
    new Set(documentedExports).size,
    documentedExports.length,
    "doc/public_api.md JavaScript exports table must not document duplicate package-root exports"
  )

  const callableHelperExports = documentedCallableHelperExports(documentedExportRows)
  assert.ok(
    callableHelperExports.length > 0,
    "doc/public_api.md JavaScript exports table must document at least one callable contract reader"
  )

  return {
    documentedExports,
    callableHelperExports
  }
}

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

try {
  const {
    documentedExports: expectedPackageRootNamedExports,
    callableHelperExports: expectedCallableHelperExports
  } = await packageRootNamedExportsFromDocs()
  const packageRoot = path.join(sandboxRoot, "node_modules", "rails_fields_kit")

  await mkdir(packageRoot, { recursive: true })
  await cp(path.join(repoRoot, "package.json"), path.join(packageRoot, "package.json"))
  await cp(
    path.join(repoRoot, "app", "javascript", "rails_fields_kit"),
    path.join(packageRoot, "app", "javascript", "rails_fields_kit"),
    { recursive: true }
  )

  await writeStubPackage(
    "@hotwired/stimulus",
    "export class Controller {\n  static values = {}\n}\n"
  )
  await writeStubPackage(
    "tom-select",
    "export default class TomSelect {\n  constructor(element, options = {}) {\n    this.element = element\n    this.options = options\n  }\n\n  destroy() {}\n}\n"
  )

  const probePath = path.join(sandboxRoot, "probe.mjs")
  await writeFile(
    probePath,
    `import rootDefault, * as packageRoot from "rails_fields_kit"\n` +
      `import directDefault from "rails_fields_kit/tom_select_controller"\n` +
      `import assert from "node:assert/strict"\n\n` +
      `const expectedNamedExports = ${JSON.stringify(expectedPackageRootNamedExports)}\n` +
      `const expectedCallableHelperExports = ${JSON.stringify(expectedCallableHelperExports)}\n\n` +
      `function elementWithAttributes(attributes = {}) {\n` +
      `  return {\n` +
      `    getAttribute(name) { return attributes[name] ?? null },\n` +
      `    hasAttribute(name) { return Object.prototype.hasOwnProperty.call(attributes, name) }\n` +
      `  }\n` +
      `}\n\n` +
      `expectedNamedExports.forEach((exportName) => {\n` +
      `  assert.ok(exportName in packageRoot, \`package root should expose documented export ${"${exportName}"}\`)\n` +
      `})\n` +
      `assert.equal(rootDefault, packageRoot.TomSelectController, "package root default export should match TomSelectController")\n` +
      `assert.equal(packageRoot.TomSelectController, directDefault, "package root controller export should match direct entrypoint")\n` +
      `expectedCallableHelperExports.forEach((exportName) => {\n` +
      `  assert.equal(typeof packageRoot[exportName], "function", \`package root should expose documented contract reader ${"${exportName}"} as a callable function\`)\n` +
      `})\n` +
      `assert.equal(packageRoot.tomSelectRequestContract(null), null, "request contract reader should ignore missing elements")\n` +
      `assert.equal(packageRoot.tomSelectRequestContract(elementWithAttributes({ "data-controller": "other" })), null, "request contract reader should ignore non-Rails Fields Kit Tom Select elements")\n` +
      `assert.deepEqual(\n` +
      `  packageRoot.tomSelectRequestContract(elementWithAttributes({\n` +
      `    "data-controller": "other rails-fields-kit--tom-select",\n` +
      `    "data-rails-fields-kit--tom-select-url-value": "/people",\n` +
      `    "data-rails-fields-kit--tom-select-selected-url-value": "/people/selected",\n` +
      `    "data-rails-fields-kit--tom-select-create-url-value": "/people",\n` +
      `    "data-rails-fields-kit--tom-select-query-param-value": "term",\n` +
      `    "data-rails-fields-kit--tom-select-selected-param-value": "person_id",\n` +
      `    "data-rails-fields-kit--tom-select-selected-multiple-param-value": "person_ids",\n` +
      `    "data-rails-fields-kit--tom-select-create-param-value": "name",\n` +
      `    "data-rails-fields-kit--tom-select-min-length-value": "2",\n` +
      `    "data-rails-fields-kit--tom-select-error-surface-id-value": "person-error"\n` +
      `  })),\n` +
      `  {\n` +
      `    controller: "rails-fields-kit--tom-select",\n` +
      `    hasRemoteSearch: true,\n` +
      `    hasSelectedPreload: true,\n` +
      `    hasCreateEndpoint: true,\n` +
      `    url: "/people",\n` +
      `    selectedUrl: "/people/selected",\n` +
      `    createUrl: "/people",\n` +
      `    queryParam: "term",\n` +
      `    selectedParam: "person_id",\n` +
      `    selectedMultipleParam: "person_ids",\n` +
      `    createParam: "name",\n` +
      `    minLength: 2,\n` +
      `    errorSurfaceId: "person-error"\n` +
      `  },\n` +
      `  "request contract reader should expose rendered request lanes without executing requests"\n` +
      `)\n` +
      `assert.deepEqual(\n` +
      `  packageRoot.tomSelectRequestContract(elementWithAttributes({ "data-controller": "rails-fields-kit--tom-select" })),\n` +
      `  {\n` +
      `    controller: "rails-fields-kit--tom-select",\n` +
      `    hasRemoteSearch: false,\n` +
      `    hasSelectedPreload: false,\n` +
      `    hasCreateEndpoint: false,\n` +
      `    url: null,\n` +
      `    selectedUrl: null,\n` +
      `    createUrl: null,\n` +
      `    queryParam: "q",\n` +
      `    selectedParam: "id",\n` +
      `    selectedMultipleParam: "ids",\n` +
      `    createParam: "text",\n` +
      `    minLength: 0,\n` +
      `    errorSurfaceId: null\n` +
      `  },\n` +
      `  "request contract reader should expose safe defaults for local Tom Select-backed fields"\n` +
      `)\n`
  )

  await import(pathToFileURL(probePath).href)
  console.log("rails_fields_kit package exports import smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
