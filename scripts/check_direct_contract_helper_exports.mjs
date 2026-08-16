import assert from "node:assert/strict"
import { cp, mkdir, mkdtemp, rm, writeFile } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"

const repoRoot = process.cwd()
const sandboxRoot = await mkdtemp(path.join(tmpdir(), "rails-fields-kit-direct-helper-exports-"))

async function writeStubPackage(packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
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
    `import {
  nativeFieldAccessibilityContract,
  nativeFieldConstraintContract,
  tomSelectTextOverrideContract
} from "rails_fields_kit"
import directNativeFieldAccessibilityContract, {
  nativeFieldAccessibilityContract as namedNativeFieldAccessibilityContract
} from "rails_fields_kit/native_field_accessibility_contract"
import directNativeFieldConstraintContract, {
  nativeFieldConstraintContract as namedNativeFieldConstraintContract
} from "rails_fields_kit/native_field_constraint_contract"
import directTomSelectTextOverrideContract, {
  tomSelectTextOverrideContract as namedTomSelectTextOverrideContract
} from "rails_fields_kit/tom_select_text_override_contract"
import assert from "node:assert/strict"

assert.equal(
  nativeFieldAccessibilityContract,
  directNativeFieldAccessibilityContract,
  "native accessibility direct default export should reuse the package-root helper"
)
assert.equal(
  nativeFieldAccessibilityContract,
  namedNativeFieldAccessibilityContract,
  "native accessibility direct named export should reuse the package-root helper"
)
assert.equal(
  nativeFieldConstraintContract,
  directNativeFieldConstraintContract,
  "native constraint direct default export should reuse the package-root helper"
)
assert.equal(
  nativeFieldConstraintContract,
  namedNativeFieldConstraintContract,
  "native constraint direct named export should reuse the package-root helper"
)
assert.equal(
  tomSelectTextOverrideContract,
  directTomSelectTextOverrideContract,
  "text override direct default export should reuse the package-root helper"
)
assert.equal(
  tomSelectTextOverrideContract,
  namedTomSelectTextOverrideContract,
  "text override direct named export should reuse the package-root helper"
)
assert.equal(typeof directNativeFieldAccessibilityContract, "function")
assert.equal(typeof directNativeFieldConstraintContract, "function")
assert.equal(typeof directTomSelectTextOverrideContract, "function")
assert.equal(directNativeFieldAccessibilityContract(null), null)
assert.equal(directNativeFieldConstraintContract(null), null)
assert.equal(directTomSelectTextOverrideContract(null), null)
`
  )

  await import(pathToFileURL(probePath).href)
  console.log("rails_fields_kit direct contract helper export smoke passed")
} finally {
  await rm(sandboxRoot, { recursive: true, force: true })
}
