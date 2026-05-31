import { mkdtemp, mkdir, cp, writeFile, rm, readFile } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"
import assert from "node:assert/strict"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-package-exports-"))

function documentedPackageRootExports(markdown) {
  const javascriptExportsSection = markdown.split("## JavaScript exports", 2)[1] ?? ""

  return javascriptExportsSection
    .split("\n")
    .map((line) => line.match(/^\| `(?<exportName>[^`]+)` \|/)?.groups?.exportName)
    .filter(Boolean)
    .map((exportName) => exportName.replace(/\(.*\)$/, ""))
}

async function packageRootNamedExportsFromDocs() {
  const publicApiDocs = await readFile(path.join(repoRoot, "doc", "public_api.md"), "utf8")
  const documentedExports = documentedPackageRootExports(publicApiDocs)

  assert.ok(
    documentedExports.length > 0,
    "doc/public_api.md JavaScript exports table must document at least one package-root export"
  )
  assert.equal(
    new Set(documentedExports).size,
    documentedExports.length,
    "doc/public_api.md JavaScript exports table must not document duplicate package-root exports"
  )

  return documentedExports
}

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

try {
  const expectedPackageRootNamedExports = await packageRootNamedExportsFromDocs()
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
      `const expectedNamedExports = ${JSON.stringify(expectedPackageRootNamedExports)}\n\n` +
      `expectedNamedExports.forEach((exportName) => {\n` +
      `  assert.ok(exportName in packageRoot, \`package root should expose documented export ${"${exportName}"}\`)\n` +
      `})\n` +
      `assert.equal(rootDefault, packageRoot.TomSelectController, "package root default export should match TomSelectController")\n` +
      `assert.equal(packageRoot.TomSelectController, directDefault, "package root controller export should match direct entrypoint")\n` +
      `assert.equal(typeof packageRoot.tomSelectTextOverrideContract, "function", "package root should expose documented text override helper")\n`
  )

  await import(pathToFileURL(probePath).href)
  console.log("rails_fields_kit package exports import smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
