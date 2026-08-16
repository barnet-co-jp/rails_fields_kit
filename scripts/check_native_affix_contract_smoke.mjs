import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"
import assert from "node:assert/strict"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-native-affix-"))

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

class FakeDocument {
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
    const match = selector.match(/^label\[for="(.+)"\]$/)
    if (!match) return null

    const forValue = match[1].replace(/\\"/g, "\"").replace(/\\\\/g, "\\")
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
      contains: (className) => (this.getAttribute("class") || "").split(/\s+/).includes(className)
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
    const matches = (element) => {
      if (selector === "label") return element.tagName === "LABEL"
      if (selector.startsWith(".")) return element.classList.contains(selector.slice(1))
      return false
    }
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

  const { nativeFieldAccessibilityContract } = await import(pathToFileURL(path.join(packageRoot, "app", "javascript", "rails_fields_kit", "index.js")).href)

  const prefix = new FakeElement("span", { class: "rfk-prefix" })
  const input = new FakeElement("input", { id: "invoice_amount" })
  const suffix = new FakeElement("span", { class: "rfk-suffix" })
  buildDocumentWithWrapper([prefix, input, suffix])

  const affixContract = nativeFieldAccessibilityContract(input)
  assert.equal(affixContract.prefixElement, prefix, "native field contract should expose the rendered prefix element")
  assert.equal(affixContract.suffixElement, suffix, "native field contract should expose the rendered suffix element")

  const suffixOnlyInput = new FakeElement("input", { id: "discount_rate" })
  const suffixOnly = new FakeElement("span", { class: "rfk-suffix" })
  buildDocumentWithWrapper([suffixOnlyInput, suffixOnly])
  const suffixOnlyContract = nativeFieldAccessibilityContract(suffixOnlyInput)
  assert.equal(suffixOnlyContract.prefixElement, null, "native field contract should return null when no prefix is rendered")
  assert.equal(suffixOnlyContract.suffixElement, suffixOnly, "native field contract should expose a suffix-only lane")

  const plainInput = new FakeElement("input", { id: "customer_name" })
  buildDocumentWithWrapper([plainInput])
  const plainContract = nativeFieldAccessibilityContract(plainInput)
  assert.equal(plainContract.prefixElement, null, "native field contract should return null when no prefix exists")
  assert.equal(plainContract.suffixElement, null, "native field contract should return null when no suffix exists")

  const hintElement = new FakeElement("p", { id: "customer_email_hint", class: "rfk-hint" })
  const errorElement = new FakeElement("p", { id: "customer_email_error", class: "rfk-error" })
  const describedInput = new FakeElement("input", {
    id: "customer_email",
    "aria-describedby": "customer_email_hint customer_email_error customer_email_hint missing_description"
  })
  buildDocumentWithWrapper([describedInput, hintElement, errorElement])

  const describedContract = nativeFieldAccessibilityContract(describedInput)
  assert.deepEqual(
    describedContract.describedByIds,
    ["customer_email_hint", "customer_email_error", "missing_description"],
    "native field contract should expose deduplicated aria-describedby ids while preserving order"
  )
  assert.deepEqual(
    describedContract.describedByElements,
    [hintElement, errorElement],
    "native field contract should resolve existing described-by elements and skip missing ids"
  )
  assert.equal(describedContract.hintElement, hintElement, "native field contract should expose the rendered hint element")
  assert.equal(describedContract.errorElement, errorElement, "native field contract should expose the rendered error element")

  assert.equal(nativeFieldAccessibilityContract(new FakeElement("div")), null, "native field contract should ignore non-native elements")

  console.log("rails_fields_kit native affix contract smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
