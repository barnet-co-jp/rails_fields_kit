import assert from "node:assert/strict"
import { access, readFile } from "node:fs/promises"
import path from "node:path"

const repoRoot = process.cwd()
const packageJsonPath = path.join(repoRoot, "package.json")
const indexTypesPath = "./app/javascript/rails_fields_kit/index.d.ts"
const controllerTypesPath = "./app/javascript/rails_fields_kit/tom_select_controller.d.ts"
const indexTypes = path.join(repoRoot, indexTypesPath)
const controllerTypes = path.join(repoRoot, controllerTypesPath)

const packageJson = JSON.parse(await readFile(packageJsonPath, "utf8"))

assert.equal(packageJson.types, indexTypesPath, "package root should point TypeScript users at the package-root declaration")
assert.equal(packageJson.exports["."].types, indexTypesPath, "package root export should declare package-root types")
assert.equal(packageJson.exports["."].import, "./app/javascript/rails_fields_kit/index.js", "package root import path should remain the runtime entrypoint")
assert.equal(packageJson.exports["./tom_select_controller"].types, controllerTypesPath, "direct controller export should declare controller types")
assert.equal(packageJson.exports["./tom_select_controller"].import, "./app/javascript/rails_fields_kit/tom_select_controller.js", "direct controller import path should remain the runtime entrypoint")

await access(indexTypes)
await access(controllerTypes)

const indexDeclaration = await readFile(indexTypes, "utf8")
const controllerDeclaration = await readFile(controllerTypes, "utf8")

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

console.log("rails_fields_kit TypeScript declaration metadata smoke passed")
