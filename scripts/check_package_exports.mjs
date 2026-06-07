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
      `class FakeDocument {\n` +
      `  constructor() {\n` +
      `    this.all = []\n` +
      `    this.elementsById = new Map()\n` +
      `  }\n\n` +
      `  register(element) {\n` +
      `    element.ownerDocument = this\n` +
      `    this.all.push(element)\n\n` +
      `    const id = element.getAttribute("id")\n` +
      `    if (id) this.elementsById.set(id, element)\n\n` +
      `    element.children.forEach((child) => this.register(child))\n` +
      `    return element\n` +
      `  }\n\n` +
      `  getElementById(id) {\n` +
      `    return this.elementsById.get(id) || null\n` +
      `  }\n\n` +
      `  querySelector(selector) {\n` +
      `    const match = selector.match(/^label\\[for="(.+)"\\]$/)\n` +
      `    if (!match) return null\n\n` +
      `    const forValue = match[1].replace(/\\\\"/g, "\\\"").replace(/\\\\\\\\/g, "\\\\")\n` +
      `    return this.all.find((element) => element.tagName === "LABEL" && element.getAttribute("for") === forValue) || null\n` +
      `  }\n` +
      `}\n\n` +
      `class FakeElement {\n` +
      `  constructor(tagName, attributes = {}, children = []) {\n` +
      `    this.tagName = tagName.toUpperCase()\n` +
      `    this.attributes = attributes\n` +
      `    this.children = []\n` +
      `    this.parentElement = null\n` +
      `    this.ownerDocument = null\n\n` +
      `    children.forEach((child) => this.appendChild(child))\n` +
      `  }\n\n` +
      `  get classList() {\n` +
      `    return {\n` +
      `      contains: (className) => (this.getAttribute("class") || "").split(/\\s+/).includes(className)\n` +
      `    }\n` +
      `  }\n\n` +
      `  appendChild(child) {\n` +
      `    child.parentElement = this\n` +
      `    this.children.push(child)\n` +
      `    return child\n` +
      `  }\n\n` +
      `  getAttribute(name) {\n` +
      `    return Object.hasOwn(this.attributes, name) ? this.attributes[name] : null\n` +
      `  }\n\n` +
      `  hasAttribute(name) {\n` +
      `    return Object.hasOwn(this.attributes, name)\n` +
      `  }\n\n` +
      `  closest(selector) {\n` +
      `    if (selector !== ".rfk-field") return null\n\n` +
      `    let current = this\n` +
      `    while (current) {\n` +
      `      if (current.classList.contains("rfk-field")) return current\n` +
      `      current = current.parentElement\n` +
      `    }\n\n` +
      `    return null\n` +
      `  }\n\n` +
      `  querySelector(selector) {\n` +
      `    const matches = (element) => selector === "label" && element.tagName === "LABEL"\n` +
      `    const visit = (element) => {\n` +
      `      if (matches(element)) return element\n\n` +
      `      for (const child of element.children) {\n` +
      `        const match = visit(child)\n` +
      `        if (match) return match\n` +
      `      }\n\n` +
      `      return null\n` +
      `    }\n\n` +
      `    return visit(this)\n` +
      `  }\n` +
      `}\n\n` +
      `function buildDocumentWithWrapper(children) {\n` +
      `  const document = new FakeDocument()\n` +
      `  const wrapper = document.register(new FakeElement("div", { class: "rfk-field" }, children))\n` +
      `  return { document, wrapper }\n` +
      `}\n\n` +
      `expectedNamedExports.forEach((exportName) => {\n` +
      `  assert.ok(exportName in packageRoot, \`package root should expose documented export ${"${exportName}"}\`)\n` +
      `})\n` +
      `assert.equal(rootDefault, packageRoot.TomSelectController, "package root default export should match TomSelectController")\n` +
      `assert.equal(packageRoot.TomSelectController, directDefault, "package root controller export should match direct entrypoint")\n` +
      `expectedCallableHelperExports.forEach((exportName) => {\n` +
      `  assert.equal(typeof packageRoot[exportName], "function", \`package root should expose documented contract reader ${"${exportName}"} as a callable function\`)\n` +
      `})\n\n` +
      `const label = new FakeElement("label", { for: "order_customer_name" })\n` +
      `const input = new FakeElement("input", { id: "order_customer_name", "aria-describedby": "customer_hint customer_error" })\n` +
      `const hint = new FakeElement("p", { id: "customer_hint", class: "rfk-hint" })\n` +
      `const error = new FakeElement("p", { id: "customer_error", class: "rfk-error" })\n` +
      `const { wrapper } = buildDocumentWithWrapper([label, input, hint, error])\n` +
      `const accessibilityContract = packageRoot.nativeFieldAccessibilityContract(input)\n\n` +
      `assert.deepEqual(accessibilityContract.describedByIds, ["customer_hint", "customer_error"])\n` +
      `assert.deepEqual(accessibilityContract.describedByElements, [hint, error])\n` +
      `assert.equal(accessibilityContract.labelElement, label, "native accessibility contract should expose the associated label element")\n` +
      `assert.equal(accessibilityContract.hintElement, hint)\n` +
      `assert.equal(accessibilityContract.errorElement, error)\n` +
      `assert.equal(accessibilityContract.wrapperElement, wrapper)\n\n` +
      `const requiredInput = new FakeElement("input", { required: "" })\n` +
      `const { wrapper: requiredWrapper } = buildDocumentWithWrapper([requiredInput])\n` +
      `const requiredStateContract = packageRoot.nativeFieldAccessibilityContract(requiredInput)\n` +
      `assert.equal(requiredStateContract.required, true, "native input contract should expose required state")\n` +
      `assert.equal(requiredStateContract.disabled, false, "native input contract should expose false disabled state")\n` +
      `assert.equal(requiredStateContract.readonly, false, "native input contract should expose false readonly state")\n` +
      `assert.equal(requiredStateContract.wrapperElement, requiredWrapper, "native state expansion should preserve wrapperElement")\n\n` +
      `const disabledSelect = new FakeElement("select", { disabled: "" })\n` +
      `buildDocumentWithWrapper([disabledSelect])\n` +
      `assert.equal(packageRoot.nativeFieldAccessibilityContract(disabledSelect).disabled, true, "native select contract should expose disabled state")\n\n` +
      `const readonlyTextarea = new FakeElement("textarea", { readonly: "" })\n` +
      `buildDocumentWithWrapper([readonlyTextarea])\n` +
      `assert.equal(packageRoot.nativeFieldAccessibilityContract(readonlyTextarea).readonly, true, "native textarea contract should expose readonly state")\n\n` +
      `const fallbackLabel = new FakeElement("label")\n` +
      `const fallbackInput = new FakeElement("textarea")\n` +
      `buildDocumentWithWrapper([fallbackLabel, fallbackInput])\n` +
      `assert.equal(packageRoot.nativeFieldAccessibilityContract(fallbackInput).labelElement, fallbackLabel, "native accessibility contract should fall back to a wrapper label")\n\n` +
      `const missingLabelInput = new FakeElement("select")\n` +
      `buildDocumentWithWrapper([missingLabelInput])\n` +
      `assert.equal(packageRoot.nativeFieldAccessibilityContract(missingLabelInput).labelElement, null, "native accessibility contract should return null when no label exists")\n` +
      `assert.equal(packageRoot.nativeFieldAccessibilityContract(new FakeElement("div")), null, "native accessibility contract should ignore non-native elements")\n`
  )

  await import(pathToFileURL(probePath).href)
  console.log("rails_fields_kit package exports import smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
