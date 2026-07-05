import assert from "node:assert/strict"
import { access, readFile } from "node:fs/promises"
import path from "node:path"

const repoRoot = process.cwd()
const packageJsonPath = path.join(repoRoot, "package.json")
const indexTypesPath = "./app/javascript/rails_fields_kit/index.d.ts"
const controllerTypesPath = "./app/javascript/rails_fields_kit/tom_select_controller.d.ts"
const textOverrideTypesPath = "./app/javascript/rails_fields_kit/tom_select_text_override_contract.d.ts"
const pluginContractTypesPath = "./app/javascript/rails_fields_kit/tom_select_plugin_contract.d.ts"
const errorSurfaceTypesPath = "./app/javascript/rails_fields_kit/read_rendered_error_surface.d.ts"
const nativeAccessibilityTypesPath = "./app/javascript/rails_fields_kit/native_field_accessibility_contract.d.ts"
const nativeConstraintTypesPath = "./app/javascript/rails_fields_kit/native_field_constraint_contract.d.ts"
const indexTypes = path.join(repoRoot, indexTypesPath)
const controllerTypes = path.join(repoRoot, controllerTypesPath)
const textOverrideTypes = path.join(repoRoot, textOverrideTypesPath)
const pluginContractTypes = path.join(repoRoot, pluginContractTypesPath)
const errorSurfaceTypes = path.join(repoRoot, errorSurfaceTypesPath)
const nativeAccessibilityTypes = path.join(repoRoot, nativeAccessibilityTypesPath)
const nativeConstraintTypes = path.join(repoRoot, nativeConstraintTypesPath)

const packageJson = JSON.parse(await readFile(packageJsonPath, "utf8"))

const packageRootOnlyReaderNames = [
  "readRenderedTomSelectInteractionConfig",
  "readRenderedOptionPayloadMapping",
  "readRenderedTableFilterMetadata"
]

const packageRootOnlyReaderSubpaths = [
  "read_rendered_tom_select_interaction_config",
  "read_rendered_option_payload_mapping",
  "read_rendered_table_filter_metadata"
]

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
  packageJson.exports["./tom_select_plugin_contract"],
  {
    types: pluginContractTypesPath,
    import: "./app/javascript/rails_fields_kit/tom_select_plugin_contract.js",
    default: "./app/javascript/rails_fields_kit/tom_select_plugin_contract.js"
  },
  "direct Tom Select plugin contract export should declare thin subpath types without changing runtime paths"
)
assert.deepEqual(
  packageJson.exports["./read_rendered_error_surface"],
  {
    types: errorSurfaceTypesPath,
    import: "./app/javascript/rails_fields_kit/read_rendered_error_surface.js",
    default: "./app/javascript/rails_fields_kit/read_rendered_error_surface.js"
  },
  "direct rendered error surface export should declare thin subpath types without changing runtime paths"
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
assert.deepEqual(
  packageJson.exports["./native_field_constraint_contract"],
  {
    types: nativeConstraintTypesPath,
    import: "./app/javascript/rails_fields_kit/native_field_constraint_contract.js",
    default: "./app/javascript/rails_fields_kit/native_field_constraint_contract.js"
  },
  "direct native constraint export should declare thin subpath types without changing runtime paths"
)

for (const subpath of packageRootOnlyReaderSubpaths) {
  assert.equal(
    Object.hasOwn(packageJson.exports, `./${subpath}`),
    false,
    `${subpath} should stay package-root only unless a future issue explicitly expands the direct helper subpath surface`
  )
}

await access(indexTypes)
await access(controllerTypes)
await access(textOverrideTypes)
await access(pluginContractTypes)
await access(errorSurfaceTypes)
await access(nativeAccessibilityTypes)
await access(nativeConstraintTypes)

const indexDeclaration = await readFile(indexTypes, "utf8")
const controllerDeclaration = await readFile(controllerTypes, "utf8")
const textOverrideDeclaration = await readFile(textOverrideTypes, "utf8")
const pluginContractDeclaration = await readFile(pluginContractTypes, "utf8")
const errorSurfaceDeclaration = await readFile(errorSurfaceTypes, "utf8")
const nativeAccessibilityDeclaration = await readFile(nativeAccessibilityTypes, "utf8")
const nativeConstraintDeclaration = await readFile(nativeConstraintTypes, "utf8")

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
  "dropdownParent: string | null",
  "persist: boolean",
  "export interface SelectedPreloadConfig",
  "selectedMultipleParam: string",
  "export interface OptionPayloadMapping",
  "valueField: string",
  "searchFields: string[]",
  "optionBadgeField: string | null",
  "export interface TableFilterMetadata",
  "adapter: string",
  "paramName: string | null",
  "fields: Record<string, unknown>",
  "export interface NativeFieldAccessibilityContract",
  "labelElement: HTMLLabelElement | null",
  "prefixElement: Element | null",
  "suffixElement: Element | null",
  "export interface NativeFieldConstraintContract",
  "maxLength: string | null",
  "inputMode: string | null",
  "export function tomSelectTextOverrideContract",
  "export function tomSelectPluginContract",
  "export function tomSelectSelectionContract",
  "export function tomSelectRequestContract",
  "export function tomSelectFieldKindContract",
  "export function readRenderedTomSelectInteractionConfig",
  "export function readRenderedErrorSurface",
  "export function readRenderedSelectedPreloadConfig",
  "export function readRenderedOptionPayloadMapping",
  "export function readRenderedTableFilterMetadata",
  "export function nativeFieldAccessibilityContract",
  "export function nativeFieldConstraintContract",
  "export { TomSelectController }",
  "export default TomSelectController"
]

for (const signal of expectedIndexSignals) {
  assert.ok(indexDeclaration.includes(signal), `index.d.ts should include ${signal}`)
}

for (const readerName of packageRootOnlyReaderNames) {
  assert.ok(
    indexDeclaration.includes(`export function ${readerName}`),
    `index.d.ts should keep ${readerName} visible from the package root`
  )
}

assert.ok(controllerDeclaration.includes("export default TomSelectController"), "direct controller declaration should expose the default controller export")
assert.ok(textOverrideDeclaration.includes("tomSelectTextOverrideContract as default"), "direct text override declaration should mirror the default helper re-export")
assert.ok(textOverrideDeclaration.includes("export type { TomSelectTextOverrideContract } from \"./index.js\""), "direct text override declaration should re-export its package-root type")
assert.ok(pluginContractDeclaration.includes("tomSelectPluginContract as default"), "direct plugin contract declaration should mirror the default helper re-export")
assert.ok(pluginContractDeclaration.includes("export type { TomSelectPluginContract } from \"./index.js\""), "direct plugin contract declaration should re-export its package-root type")
assert.ok(errorSurfaceDeclaration.includes("readRenderedErrorSurface as default"), "direct rendered error surface declaration should mirror the default helper re-export")
assert.ok(nativeAccessibilityDeclaration.includes("nativeFieldAccessibilityContract as default"), "direct native accessibility declaration should mirror the default helper re-export")
assert.ok(nativeAccessibilityDeclaration.includes("export type { NativeFieldAccessibilityContract } from \"./index.js\""), "direct native accessibility declaration should re-export its package-root type")
assert.ok(nativeConstraintDeclaration.includes("nativeFieldConstraintContract as default"), "direct native constraint declaration should mirror the default helper re-export")
assert.ok(nativeConstraintDeclaration.includes("export type { NativeFieldConstraintContract } from \"./index.js\""), "direct native constraint declaration should re-export its package-root type")

console.log("rails_fields_kit TypeScript declaration metadata smoke passed")
