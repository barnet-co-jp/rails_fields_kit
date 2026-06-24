import { writeFile } from "node:fs/promises"
import path from "node:path"
import { pathToFileURL } from "node:url"
import {
  cleanupPackageExportSandbox,
  fakeDomProbeSource,
  preparePackageExportSandbox,
  sandboxRoot
} from "./package_export_smoke_harness.mjs"

try {
  await preparePackageExportSandbox()

  const probePath = path.join(sandboxRoot, "interaction-config-probe.mjs")
  await writeFile(
    probePath,
    `import assert from "node:assert/strict"\n` +
      `import { readRenderedTomSelectInteractionConfig } from "rails_fields_kit"\n\n` +
      `${fakeDomProbeSource()}\n\n` +
      `const tomSelectController = "rails-fields-kit--tom-select"\n` +
      `const kindAttribute = "data-rails-fields-kit--tom-select-kind-value"\n` +
      `const customField = new FakeElement("select", {\n` +
      `  "data-controller": tomSelectController,\n` +
      `  [kindAttribute]: "combobox",\n` +
      `  "data-rails-fields-kit--tom-select-max-options-value": "25",\n` +
      `  "data-rails-fields-kit--tom-select-load-throttle-value": "300",\n` +
      `  "data-rails-fields-kit--tom-select-dropdown-parent-value": "body",\n` +
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
      `  dropdownParent: "body",\n` +
      `  preload: true,\n` +
      `  openOnFocus: false,\n` +
      `  closeAfterSelect: true,\n` +
      `  hideSelected: true,\n` +
      `  persist: true\n` +
      `}, "interaction config reader should expose custom rendered values")\n\n` +
      `const multipleField = new FakeElement("select", {\n` +
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
      `  dropdownParent: null,\n` +
      `  preload: null,\n` +
      `  openOnFocus: null,\n` +
      `  closeAfterSelect: null,\n` +
      `  hideSelected: null,\n` +
      `  persist: false\n` +
      `}, "interaction config reader should cover multiple-value settings")\n\n` +
      `const defaultField = new FakeElement("select", {\n` +
      `  "data-controller": tomSelectController,\n` +
      `  [kindAttribute]: "select"\n` +
      `})\n` +
      `assert.deepEqual(readRenderedTomSelectInteractionConfig(defaultField), {\n` +
      `  maxOptions: null,\n` +
      `  maxItems: null,\n` +
      `  loadThrottle: null,\n` +
      `  delimiter: null,\n` +
      `  dropdownParent: null,\n` +
      `  preload: null,\n` +
      `  openOnFocus: null,\n` +
      `  closeAfterSelect: null,\n` +
      `  hideSelected: null,\n` +
      `  persist: false\n` +
      `}, "interaction config reader should expose the default rendered shape")\n\n` +
      `assert.equal(readRenderedTomSelectInteractionConfig(new FakeElement("input")), null, "interaction config reader should ignore unrelated elements")\n` +
      `assert.equal(readRenderedTomSelectInteractionConfig(null), null, "interaction config reader should ignore null input")\n`
  )

  await import(pathToFileURL(probePath).href)
  console.log("rails_fields_kit Tom Select interaction config contract smoke passed")
} finally {
  await cleanupPackageExportSandbox()
}
