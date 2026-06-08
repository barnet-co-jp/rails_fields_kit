import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"
import assert from "node:assert/strict"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-interaction-config-"))

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

class FakeElement {
  constructor(attributes = {}) {
    this.attributes = attributes
  }

  getAttribute(name) {
    return Object.hasOwn(this.attributes, name) ? this.attributes[name] : null
  }

  hasAttribute(name) {
    return Object.hasOwn(this.attributes, name)
  }
}

try {
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
    `import assert from "node:assert/strict"\n` +
      `import { readRenderedTomSelectInteractionConfig } from "rails_fields_kit"\n\n` +
      `${FakeElement.toString()}\n\n` +
      `const tomSelectController = "rails-fields-kit--tom-select"\n` +
      `const kindAttribute = "data-rails-fields-kit--tom-select-kind-value"\n` +
      `const customField = new FakeElement({\n` +
      `  "data-controller": tomSelectController,\n` +
      `  [kindAttribute]: "combobox",\n` +
      `  "data-rails-fields-kit--tom-select-max-options-value": "25",\n` +
      `  "data-rails-fields-kit--tom-select-load-throttle-value": "300",\n` +
      `  "data-rails-fields-kit--tom-select-preload-value": "true",\n` +
      `  "data-rails-fields-kit--tom-select-open-on-focus-value": "false",\n` +
      `  "data-rails-fields-kit--tom-select-close-after-select-value": "true",\n` +
      `  "data-rails-fields-kit--tom-select-hide-selected-value": "true",\n` +
      `  "data-rails-fields-kit--tom-select-persist-value": "true"\n` +
      `})\n\n` +
      `assert.deepEqual(readRenderedTomSelectInteractionConfig(customField), {\n` +
      `  maxOptions: 25,\n` +
      `  maxItems: null,\n` +
      `  loadThrottle: 300,\n` +
      `  delimiter: null,\n` +
      `  preload: true,\n` +
      `  openOnFocus: false,\n` +
      `  closeAfterSelect: true,\n` +
      `  hideSelected: true,\n` +
      `  persist: true\n` +
      `}, "interaction config reader should expose custom rendered values")\n\n` +
      `const multipleField = new FakeElement({\n` +
      `  "data-controller": tomSelectController,\n` +
      `  [kindAttribute]: "token_search",\n` +
      `  "data-rails-fields-kit--tom-select-max-items-value": "20",\n` +
      `  "data-rails-fields-kit--tom-select-delimiter-value": " ",\n` +
      `  "data-rails-fields-kit--tom-select-persist-value": "false"\n` +
      `})\n` +
      `assert.deepEqual(readRenderedTomSelectInteractionConfig(multipleField), {\n` +
      `  maxOptions: null,\n` +
      `  maxItems: 20,\n` +
      `  loadThrottle: null,\n` +
      `  delimiter: " ",\n` +
      `  preload: null,\n` +
      `  openOnFocus: null,\n` +
      `  closeAfterSelect: null,\n` +
      `  hideSelected: null,\n` +
      `  persist: false\n` +
      `}, "interaction config reader should cover multiple-value settings")\n\n` +
      `const defaultField = new FakeElement({\n` +
      `  "data-controller": tomSelectController,\n` +
      `  [kindAttribute]: "select"\n` +
      `})\n` +
      `assert.deepEqual(readRenderedTomSelectInteractionConfig(defaultField), {\n` +
      `  maxOptions: null,\n` +
      `  maxItems: null,\n` +
      `  loadThrottle: null,\n` +
      `  delimiter: null,\n` +
      `  preload: null,\n` +
      `  openOnFocus: null,\n` +
      `  closeAfterSelect: null,\n` +
      `  hideSelected: null,\n` +
      `  persist: false\n` +
      `}, "interaction config reader should expose the default rendered shape")\n\n` +
      `assert.equal(readRenderedTomSelectInteractionConfig(new FakeElement()), null, "interaction config reader should ignore unrelated elements")\n` +
      `assert.equal(readRenderedTomSelectInteractionConfig(null), null, "interaction config reader should ignore null input")\n`
  )

  await import(pathToFileURL(probePath).href)
  console.log("rails_fields_kit Tom Select interaction config contract smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
