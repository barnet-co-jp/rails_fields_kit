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
      `function tomSelectElement(value) {\n` +
      `  return {\n` +
      `    getAttribute(name) { return name === "data-controller" ? "rails-fields-kit--tom-select" : null },\n` +
      `    tomselect: { getValue() { return value } }\n` +
      `  }\n` +
      `}\n\n` +
      `expectedNamedExports.forEach((exportName) => {\n` +
      `  assert.ok(exportName in packageRoot, \`package root should expose documented export ${"${exportName}"}\`)\n` +
      `})\n` +
      `assert.equal(rootDefault, packageRoot.TomSelectController, "package root default export should match TomSelectController")\n` +
      `assert.equal(packageRoot.TomSelectController, directDefault, "package root controller export should match direct entrypoint")\n` +
      `expectedCallableHelperExports.forEach((exportName) => {\n` +
      `  assert.equal(typeof packageRoot[exportName], "function", \`package root should expose documented contract reader ${"${exportName}"} as a callable function\`)\n` +
      `})\n\n` +
      `assert.deepEqual(packageRoot.tomSelectSelectionContract(tomSelectElement("42")), { values: ["42"] })\n` +
      `assert.deepEqual(packageRoot.tomSelectSelectionContract(tomSelectElement(["1", "2"])), { values: ["1", "2"] })\n` +
      `assert.deepEqual(packageRoot.tomSelectSelectionContract(tomSelectElement("")), { values: [""] })\n\n` +
      `const sourceValues = ["a", "b"]\n` +
      `const selectionContract = packageRoot.tomSelectSelectionContract(tomSelectElement(sourceValues))\n` +
      `selectionContract.values.push("c")\n` +
      `assert.deepEqual(sourceValues, ["a", "b"], "selection contract should not expose Tom Select's value array for mutation")\n\n` +
      `assert.equal(packageRoot.tomSelectSelectionContract(null), null)\n` +
      `assert.equal(packageRoot.tomSelectSelectionContract({ getAttribute() { return "rails-fields-kit--tom-select" } }), null)\n` +
      `assert.equal(packageRoot.tomSelectSelectionContract({ getAttribute() { return "other-controller" }, tomselect: { getValue() { return "42" } } }), null)\n`
  )

  await import(pathToFileURL(probePath).href)
  console.log("rails_fields_kit package exports import smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
