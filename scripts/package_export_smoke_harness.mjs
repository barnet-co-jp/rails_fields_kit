import assert from "node:assert/strict"
import { cp, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"

export const repoRoot = process.cwd()
export const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-package-exports-"))

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

export async function packageRootNamedExportsFromDocs() {
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

export async function preparePackageExportSandbox() {
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
}

export async function cleanupPackageExportSandbox() {
  await rm(sandboxRoot, { recursive: true, force: true })
}

export function fakeDomProbeSource() {
  return `class FakeDocument {
  constructor() {
    this.all = []
    this.elementsById = new Map()
  }

  register(element) {
    element.ownerDocument = this
    this.all.push(element)

    const id = element.getAttribute("id")
    if (id) this.elementsById.set(id, element)

    element.children.forEach((child) => this.register(child))
    return element
  }

  getElementById(id) {
    return this.elementsById.get(id) || null
  }

  querySelector(selector) {
    const match = selector.match(/^label\\[for="(.+)"\\]$/)
    if (!match) return null

    const forValue = match[1].replace(/\\\\"/g, "\\\"").replace(/\\\\\\\\/g, "\\\\")
    return this.all.find((element) => element.tagName === "LABEL" && element.getAttribute("for") === forValue) || null
  }
}

class FakeElement {
  constructor(tagName, attributes = {}, children = []) {
    this.tagName = tagName.toUpperCase()
    this.attributes = attributes
    this.children = []
    this.parentElement = null
    this.ownerDocument = null

    children.forEach((child) => this.appendChild(child))
  }

  get classList() {
    return {
      contains: (className) => (this.getAttribute("class") || "").split(/\\s+/).includes(className)
    }
  }

  appendChild(child) {
    child.parentElement = this
    this.children.push(child)
    return child
  }

  getAttribute(name) {
    return Object.hasOwn(this.attributes, name) ? this.attributes[name] : null
  }

  hasAttribute(name) {
    return Object.hasOwn(this.attributes, name)
  }

  closest(selector) {
    if (selector !== ".rfk-field") return null

    let current = this
    while (current) {
      if (current.classList.contains("rfk-field")) return current
      current = current.parentElement
    }

    return null
  }

  querySelector(selector) {
    const matches = (element) => selector === "label" && element.tagName === "LABEL"
    const visit = (element) => {
      if (matches(element)) return element

      for (const child of element.children) {
        const match = visit(child)
        if (match) return match
      }

      return null
    }

    return visit(this)
  }
}

function buildDocumentWithWrapper(children) {
  const document = new FakeDocument()
  const wrapper = document.register(new FakeElement("div", { class: "rfk-field" }, children))
  return { document, wrapper }
}
`
}
