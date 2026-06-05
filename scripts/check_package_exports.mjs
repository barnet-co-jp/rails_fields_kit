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
      `expectedNamedExports.forEach((exportName) => {\n` +
      `  assert.ok(exportName in packageRoot, \`package root should expose documented export ${"${exportName}"}\`)\n` +
      `})\n` +
      `assert.equal(rootDefault, packageRoot.TomSelectController, "package root default export should match TomSelectController")\n` +
      `assert.equal(packageRoot.TomSelectController, directDefault, "package root controller export should match direct entrypoint")\n` +
      `expectedCallableHelperExports.forEach((exportName) => {\n` +
      `  assert.equal(typeof packageRoot[exportName], "function", \`package root should expose documented contract reader ${"${exportName}"} as a callable function\`)\n` +
      `})\n\n` +
      `const hintElement = {\n` +
      `  getAttribute: (name) => name === "class" ? "rfk-hint" : null,\n` +
      `  classList: { contains: (className) => className === "rfk-hint" }\n` +
      `}\n` +
      `const errorElement = {\n` +
      `  getAttribute: (name) => name === "class" ? "rfk-error" : null,\n` +
      `  classList: { contains: (className) => className === "rfk-error" }\n` +
      `}\n` +
      `const explicitLabelElement = { getAttribute: (name) => name === "for" ? "customer_email" : null }\n` +
      `const wrapperLabelElement = { getAttribute: () => null }\n` +
      `const wrapperElement = { querySelector: (selector) => selector === "label" ? wrapperLabelElement : null }\n` +
      `const ownerDocument = {\n` +
      `  getElementById: (id) => ({ "customer_email_hint": hintElement, "customer_email_error": errorElement }[id] || null),\n` +
      `  querySelectorAll: (selector) => selector === "label" ? [explicitLabelElement] : []\n` +
      `}\n` +
      `const nativeInput = {\n` +
      `  tagName: "INPUT",\n` +
      `  ownerDocument,\n` +
      `  closest: (selector) => selector === ".rfk-field" ? wrapperElement : null,\n` +
      `  getAttribute: (name) => ({\n` +
      `    id: "customer_email",\n` +
      `    "aria-describedby": "customer_email_hint customer_email_error customer_email_hint"\n` +
      `  }[name] || null)\n` +
      `}\n` +
      `const nativeContract = packageRoot.nativeFieldAccessibilityContract(nativeInput)\n` +
      `assert.deepEqual(nativeContract.describedByIds, ["customer_email_hint", "customer_email_error"], "native contract should de-duplicate described-by ids")\n` +
      `assert.equal(nativeContract.hintElement, hintElement, "native contract should expose hint element")\n` +
      `assert.equal(nativeContract.errorElement, errorElement, "native contract should expose error element")\n` +
      `assert.equal(nativeContract.wrapperElement, wrapperElement, "native contract should expose wrapper element")\n` +
      `assert.equal(nativeContract.labelElement, explicitLabelElement, "native contract should prefer explicit label[for] association")\n\n` +
      `const wrapperOnlyInput = {\n` +
      `  tagName: "TEXTAREA",\n` +
      `  ownerDocument: { getElementById: () => null, querySelectorAll: () => [] },\n` +
      `  closest: (selector) => selector === ".rfk-field" ? wrapperElement : null,\n` +
      `  getAttribute: () => null\n` +
      `}\n` +
      `assert.equal(\n` +
      `  packageRoot.nativeFieldAccessibilityContract(wrapperOnlyInput).labelElement,\n` +
      `  wrapperLabelElement,\n` +
      `  "native contract should fall back to a label inside the field wrapper"\n` +
      `)\n`
  )

  await import(pathToFileURL(probePath).href)
  console.log("rails_fields_kit package exports import smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
