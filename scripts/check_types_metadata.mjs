import assert from "node:assert/strict"
import { access, readFile } from "node:fs/promises"
import path from "node:path"

const repoRoot = process.cwd()
const packageJsonPath = path.join(repoRoot, "package.json")
const indexTypesPath = "./app/javascript/rails_fields_kit/index.d.ts"
const controllerTypesPath = "./app/javascript/rails_fields_kit/tom_select_controller.d.ts"
const textOverrideTypesPath = "./app/javascript/rails_fields_kit/tom_select_text_override_contract.d.ts"
const nativeAccessibilityTypesPath = "./app/javascript/rails_fields_kit/native_field_accessibility_contract.d.ts"
const indexTypes = path.join(repoRoot, indexTypesPath)
const controllerTypes = path.join(repoRoot, controllerTypesPath)
const textOverrideTypes = path.join(repoRoot, textOverrideTypesPath)
const nativeAccessibilityTypes = path.join(repoRoot, nativeAccessibilityTypesPath)

const packageJson = JSON.parse(await readFile(packageJsonPath, "utf8"))

assert.equal(packageJson.types, indexTypesPath, "package root should point TypeScript users at the package-root declaration")
assert.equal(packageJson.exports["."].types, indexTypesPath, "package root export should declare package-root types")
assert.equal(packageJson.exports["."].import, "./app/javascript/rails_fields_kit/index.js", "package root import path should remain the runtime entrypoint")
assert.equal(packageJson.exports["./tom_select_controller"].types, controllerTypesPath, "direct controller export should declare controller types")
assert.equal(packageJson.exports["./tom_select_controller"].import, "./app/javascript/rails_fields_kit/tom_select_controller.js", "direct controller import path should remain the runtime entrypoint")
assert.deepEqual(
  packageJson.exports["./tom_select_text_override_contract"],
  {
    types: textOverrideTypesPath,
    import: "./app/javascript/rails_fields_kit/tom_select_text_override_contract.js",
    default: "./app/javascript/rails_fields_kit/tom_select_text_override_contract.js"
  },
  "direct Tom Select text override export should declare thin subpath types without changing runtime paths"
)
assert.deepEqual(
  packageJson.exports["./native_field_accessibility_contract"],
  {
    types: nativeAccessibilityTypesPath,
    import: "./app/javascript/rails_fields_kit/native_field_accessibility_contract.js",
    default: "./app/javascript/rails_fields_kit/native_field_accessibility_contract.js"
  },
  "direct native accessibility export should declare thin subpath types without changing runtime paths"
)

await access(indexTypes)
await access(controllerTypes)
await access(textOverrideTypes)
await access(nativeAccessibilityTypes)

const indexDeclaration = await readFile(indexTypes, "utf8")
const controllerDeclaration = await readFile(controllerTypes, "utf8")
const textOverrideDeclaration = await readFile(textOverrideTypes, "utf8")
const nativeAccessibilityDeclaration = await readFile(nativeAccessibilityTypes, "utf8")

const expectedIndexSignals = [
  "export interface TomSelectTextOverrideContract",
  "noResultsText: string | null",
  "export interface TomSelectPluginContract",
  "plugins: string[]",
  "export interface TomSelectSelectionContract",
  "values: unknown[]",
  "export interface TomSelectRequestContract",
  "hasRemoteSearch: boolean",
  "queryParam: string",
  "errorSurfaceId: string | null",
  "export interface TomSelectFieldKindContract",
  "kind: string",
  "export interface TomSelectInteractionConfig",
  "maxOptions: number | null",
  "delimiter: string | null",
  "persist: boolean",
  "export interface SelectedPreloadConfig",
  "selectedMultipleParam: string",
  "export interface NativeFieldAccessibilityContract",
  "labelElement: HTMLLabelElement | null",
  "prefixElement: Element | null",
  "suffixElement: Element | null",
  "export function tomSelectTextOverrideContract",
  "export function tomSelectPluginContract",
  "export function tomSelectSelectionContract",
  "export function tomSelectRequestContract",
  "export function tomSelectFieldKindContract",
  "export function readRenderedTomSelectInteractionConfig",
  "export function readRenderedErrorSurface",
  "export function readRenderedSelectedPreloadConfig",
  "export function nativeFieldAccessibilityContract",
  "export { TomSelectController }",
  "export default TomSelectController"
]

for (const signal of expectedIndexSignals) {
  assert.ok(indexDeclaration.includes(signal), `index.d.ts should include ${signal}`)
}

assert.ok(controllerDeclaration.includes("export default TomSelectController"), "direct controller declaration should expose the default controller export")
assert.ok(textOverrideDeclaration.includes("tomSelectTextOverrideContract as default"), "direct text override declaration should mirror the default helper re-export")
assert.ok(textOverrideDeclaration.includes("export type { TomSelectTextOverrideContract } from \"./index.js\""), "direct text override declaration should re-export its package-root type")
assert.ok(nativeAccessibilityDeclaration.includes("nativeFieldAccessibilityContract as default"), "direct native accessibility declaration should mirror the default helper re-export")
assert.ok(nativeAccessibilityDeclaration.includes("export type { NativeFieldAccessibilityContract } from \"./index.js\""), "direct native accessibility declaration should re-export its package-root type")

console.log("rails_fields_kit TypeScript declaration metadata smoke passed")
