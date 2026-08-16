import { writeFile } from "node:fs/promises"
import path from "node:path"
import { pathToFileURL } from "node:url"
import {
  cleanupPackageExportSandbox,
  fakeDomProbeSource,
  packageRootNamedExportsFromDocs,
  preparePackageExportSandbox,
  sandboxRoot
} from "./package_export_smoke_harness.mjs"

function packageExportProbeSource({ expectedPackageRootNamedExports, expectedCallableHelperExports }) {
  return `import rootDefault, * as packageRoot from "rails_fields_kit"
import directDefault from "rails_fields_kit/tom_select_controller"
import assert from "node:assert/strict"

const expectedNamedExports = ${JSON.stringify(expectedPackageRootNamedExports)}
const expectedCallableHelperExports = ${JSON.stringify(expectedCallableHelperExports)}

${fakeDomProbeSource()}
const actualNamedExports = Object.keys(packageRoot).filter((exportName) => exportName !== "default").sort()
assert.deepEqual(
  actualNamedExports,
  [...expectedNamedExports].sort(),
  "package root named exports should match doc/public_api.md#javascript-exports without undocumented additions or missing documented entries"
)
expectedNamedExports.forEach((exportName) => {
  assert.ok(exportName in packageRoot, \`package root should expose documented export ${"${exportName}"}\`)
})
assert.equal(rootDefault, packageRoot.TomSelectController, "package root default export should match TomSelectController")
assert.equal(packageRoot.TomSelectController, directDefault, "package root controller export should match direct entrypoint")
expectedCallableHelperExports.forEach((exportName) => {
  assert.equal(typeof packageRoot[exportName], "function", \`package root should expose documented contract reader ${"${exportName}"} as a callable function\`)
})

assert.equal(packageRoot.tomSelectRequestContract(null), null, "request contract reader should ignore missing elements")
assert.equal(packageRoot.tomSelectRequestContract(new FakeElement("input", { "data-controller": "other" })), null, "request contract reader should ignore non-Rails Fields Kit Tom Select elements")
assert.deepEqual(
  packageRoot.tomSelectRequestContract(new FakeElement("select", {
    "data-controller": "other rails-fields-kit--tom-select",
    "data-rails-fields-kit--tom-select-url-value": "/people",
    "data-rails-fields-kit--tom-select-selected-url-value": "/people/selected",
    "data-rails-fields-kit--tom-select-create-url-value": "/people",
    "data-rails-fields-kit--tom-select-query-param-value": "term",
    "data-rails-fields-kit--tom-select-query-params-value": JSON.stringify({ active: "1", scope: "internal" }),
    "data-rails-fields-kit--tom-select-selected-param-value": "person_id",
    "data-rails-fields-kit--tom-select-selected-multiple-param-value": "person_ids",
    "data-rails-fields-kit--tom-select-create-param-value": "name",
    "data-rails-fields-kit--tom-select-create-params-value": JSON.stringify({ source: "rfk", audit: "manual" }),
    "data-rails-fields-kit--tom-select-min-length-value": "2",
    "data-rails-fields-kit--tom-select-error-surface-id-value": "person-error"
  })),
  {
    controller: "rails-fields-kit--tom-select",
    hasRemoteSearch: true,
    hasSelectedPreload: true,
    hasCreateEndpoint: true,
    url: "/people",
    selectedUrl: "/people/selected",
    createUrl: "/people",
    queryParam: "term",
    queryParams: { active: "1", scope: "internal" },
    selectedParam: "person_id",
    selectedMultipleParam: "person_ids",
    createParam: "name",
    createParams: { source: "rfk", audit: "manual" },
    minLength: 2,
    errorSurfaceId: "person-error"
  },
  "request contract reader should expose rendered request lanes and fixed params without executing requests"
)
assert.deepEqual(
  packageRoot.tomSelectRequestContract(new FakeElement("select", { "data-controller": "rails-fields-kit--tom-select" })),
  {
    controller: "rails-fields-kit--tom-select",
    hasRemoteSearch: false,
    hasSelectedPreload: false,
    hasCreateEndpoint: false,
    url: null,
    selectedUrl: null,
    createUrl: null,
    queryParam: "q",
    queryParams: {},
    selectedParam: "id",
    selectedMultipleParam: "ids",
    createParam: "text",
    createParams: {},
    minLength: 0,
    errorSurfaceId: null
  },
  "request contract reader should expose safe defaults for local Tom Select-backed fields"
)
assert.deepEqual(
  packageRoot.tomSelectRequestContract(new FakeElement("select", {
    "data-controller": "rails-fields-kit--tom-select",
    "data-rails-fields-kit--tom-select-query-params-value": "not-json",
    "data-rails-fields-kit--tom-select-create-params-value": JSON.stringify(["not", "object"])
  })),
  {
    controller: "rails-fields-kit--tom-select",
    hasRemoteSearch: false,
    hasSelectedPreload: false,
    hasCreateEndpoint: false,
    url: null,
    selectedUrl: null,
    createUrl: null,
    queryParam: "q",
    queryParams: {},
    selectedParam: "id",
    selectedMultipleParam: "ids",
    createParam: "text",
    createParams: {},
    minLength: 0,
    errorSurfaceId: null
  },
  "request contract reader should treat invalid or non-object fixed params as empty objects"
)

const label = new FakeElement("label", { for: "order_customer_name" })
const input = new FakeElement("input", { id: "order_customer_name", "aria-describedby": "customer_hint customer_error" })
const hint = new FakeElement("p", { id: "customer_hint", class: "rfk-hint" })
const error = new FakeElement("p", { id: "customer_error", class: "rfk-error" })
const { wrapper } = buildDocumentWithWrapper([label, input, hint, error])
const accessibilityContract = packageRoot.nativeFieldAccessibilityContract(input)

assert.deepEqual(accessibilityContract.describedByIds, ["customer_hint", "customer_error"])
assert.deepEqual(accessibilityContract.describedByElements, [hint, error])
assert.equal(accessibilityContract.labelElement, label, "native accessibility contract should expose the associated label element")
assert.equal(accessibilityContract.hintElement, hint)
assert.equal(accessibilityContract.errorElement, error)
assert.equal(accessibilityContract.wrapperElement, wrapper)

const fallbackLabel = new FakeElement("label")
const fallbackInput = new FakeElement("textarea")
buildDocumentWithWrapper([fallbackLabel, fallbackInput])
assert.equal(packageRoot.nativeFieldAccessibilityContract(fallbackInput).labelElement, fallbackLabel, "native accessibility contract should fall back to a wrapper label")

const missingLabelInput = new FakeElement("select")
buildDocumentWithWrapper([missingLabelInput])
assert.equal(packageRoot.nativeFieldAccessibilityContract(missingLabelInput).labelElement, null, "native accessibility contract should return null when no label exists")
assert.equal(packageRoot.nativeFieldAccessibilityContract(new FakeElement("div")), null, "native accessibility contract should ignore non-native elements")

assert.deepEqual(
  packageRoot.nativeFieldConstraintContract(new FakeElement("input", {
    maxlength: "12",
    minlength: "2",
    pattern: "[A-Z0-9-]+",
    autocomplete: "off",
    inputmode: "numeric"
  })),
  {
    maxLength: "12",
    minLength: "2",
    pattern: "[A-Z0-9-]+",
    autocomplete: "off",
    inputMode: "numeric"
  },
  "native constraint contract should expose rendered native constraint attributes as strings"
)
assert.deepEqual(
  packageRoot.nativeFieldConstraintContract(new FakeElement("textarea")),
  {
    maxLength: null,
    minLength: null,
    pattern: null,
    autocomplete: null,
    inputMode: null
  },
  "native constraint contract should return null values for absent constraint attributes"
)
assert.equal(packageRoot.nativeFieldConstraintContract(new FakeElement("div")), null, "native constraint contract should ignore non-native elements")
assert.equal(packageRoot.nativeFieldConstraintContract(null), null, "native constraint contract should ignore missing elements")
`
}

try {
  const {
    documentedExports: expectedPackageRootNamedExports,
    callableHelperExports: expectedCallableHelperExports
  } = await packageRootNamedExportsFromDocs()

  await preparePackageExportSandbox()

  const probePath = path.join(sandboxRoot, "probe.mjs")
  await writeFile(
    probePath,
    packageExportProbeSource({ expectedPackageRootNamedExports, expectedCallableHelperExports })
  )

  await import(pathToFileURL(probePath).href)
  console.log("rails_fields_kit package exports import smoke passed")
} finally {
  await cleanupPackageExportSandbox()
}
