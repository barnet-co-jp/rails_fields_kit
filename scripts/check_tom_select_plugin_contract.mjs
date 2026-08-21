import assert from "node:assert/strict"
import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"

const TOM_SELECT_CONTROLLER = "rails-fields-kit--tom-select"
const PLUGINS_ATTRIBUTE = "data-rails-fields-kit--tom-select-plugins-value"
const repoRoot = process.cwd()

function element(attributes = {}) {
  return {
    getAttribute(name) {
      return Object.prototype.hasOwnProperty.call(attributes, name) ? attributes[name] : null
    },
    hasAttribute(name) {
      return Object.prototype.hasOwnProperty.call(attributes, name)
    }
  }
}

async function writeStubPackage(sandboxRoot, packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\",\n  \"exports\": \"./index.js\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

async function withPackageRootSandbox(assertion) {
  const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-plugin-contract-"))

  try {
    await writeStubPackage(
      sandboxRoot,
      "@hotwired/stimulus",
      "export class Controller {\n  static values = {}\n}\n"
    )
    await writeStubPackage(
      sandboxRoot,
      "tom-select",
      "export default class TomSelect {\n  constructor(element, options = {}) {\n    this.element = element\n    this.options = options\n  }\n\n  destroy() {}\n}\n"
    )

    const sourceRoot = path.join(repoRoot, "app", "javascript", "rails_fields_kit")
    const packageRoot = path.join(sandboxRoot, "rails_fields_kit")
    await cp(sourceRoot, packageRoot, { recursive: true })

    const packageRootModule = await import(pathToFileURL(path.join(packageRoot, "index.js")).href)
    await assertion(packageRootModule)
  } finally {
    await rm(sandboxRoot, { recursive: true, force: true })
  }
}

await withPackageRootSandbox(({ tomSelectPluginContract }) => {
  assert.deepEqual(
    tomSelectPluginContract(element({
      "data-controller": TOM_SELECT_CONTROLLER,
      [PLUGINS_ATTRIBUTE]: JSON.stringify(["clear_button"])
    })),
    { plugins: ["clear_button"], hasClearButton: true, hasRemoveButton: false },
    "allow_clear rendered plugin data should expose clear_button"
  )

  assert.deepEqual(
    tomSelectPluginContract(element({
      "data-controller": TOM_SELECT_CONTROLLER,
      [PLUGINS_ATTRIBUTE]: JSON.stringify(["dropdown_input"])
    })),
    { plugins: ["dropdown_input"], hasClearButton: false, hasRemoveButton: false },
    "explicit plugins should be readable without derived clear/remove flags"
  )

  assert.deepEqual(
    tomSelectPluginContract(element({
      "data-controller": TOM_SELECT_CONTROLLER,
      [PLUGINS_ATTRIBUTE]: JSON.stringify(["remove_button"])
    })),
    { plugins: ["remove_button"], hasClearButton: false, hasRemoveButton: true },
    "token_search and tags rendered plugin data should expose remove_button"
  )

  assert.deepEqual(
    tomSelectPluginContract(element({ "data-controller": TOM_SELECT_CONTROLLER })),
    { plugins: [], hasClearButton: false, hasRemoveButton: false },
    "Tom Select elements without plugin data should expose an empty plugin contract"
  )

  assert.equal(
    tomSelectPluginContract(element({ class: "unrelated" })),
    null,
    "non Rails Fields Kit Tom Select elements should not expose a plugin contract"
  )
})

console.log("rails_fields_kit Tom Select plugin contract smoke passed")
