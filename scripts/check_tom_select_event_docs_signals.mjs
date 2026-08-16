import assert from "node:assert/strict"
import { readFileSync } from "node:fs"

const eventsDoc = readFileSync("doc/events.md", "utf8")
const developmentDoc = readFileSync("doc/development.md", "utf8")

function assertSignals(source, sourcePath, signals, context) {
  const missingSignals = signals.filter((signal) => !source.includes(signal))

  assert.deepEqual(
    missingSignals,
    [],
    `${sourcePath} is missing ${context} signal(s): ${missingSignals.join(", ")}`
  )
}

assertSignals(
  eventsDoc,
  "doc/events.md",
  [
    "rails-fields-kit--tom-select:load",
    "rails-fields-kit--tom-select:load-error",
    "rails-fields-kit--tom-select:selected-load",
    "rails-fields-kit--tom-select:selected-load-error",
    "rails-fields-kit--tom-select:create",
    "rails-fields-kit--tom-select:create-error",
    "rails-fields-kit--tom-select:dependency-change",
    "rails-fields-kit--tom-select:item-add",
    "rails-fields-kit--tom-select:item-remove",
    "rails-fields-kit--tom-select:change",
    "rails-fields-kit--tom-select:clear"
  ],
  "Tom Select event-name docs"
)

assertSignals(
  eventsDoc,
  "doc/events.md",
  [
    "Detail: `{ query, options }`",
    "Detail: `{ values, options }`",
    "Detail: `{ params, previousParams, changed }`",
    "Detail: `{ input, option }`",
    "Detail: `{ operation, input, error, response, payload, status, surface }`",
    "Detail: `{ value, values, option, options }`",
    "Detail: `{ value, item, values, option, options }`"
  ],
  "Tom Select event detail docs"
)

assertSignals(
  eventsDoc,
  "doc/events.md",
  [
    "detail.surface",
    "error_surface: true",
    "data-rfk-error-state=\"error\"",
    "data-rfk-error-operation",
    "\"load\"",
    "\"selected-load\"",
    "\"create\"",
    "data-rfk-error-status",
    "host-app follow-up signal",
    "They do not make Rails Fields Kit responsible for visible message text, retry UI, loading UI, or endpoint policy."
  ],
  "error-surface ownership docs"
)

assertSignals(
  eventsDoc,
  "doc/events.md",
  [
    "Aborted requests, disconnect-time aborts, and stale responses do not dispatch",
    "Rails Fields Kit does not dispatch a separate request-start event or render built-in loading, retry, or fallback UI.",
    "The `option` field is the Tom Select option payload for the event value, or `null` when no option exists for that value, such as free text.",
    "preserving additional fields returned by remote search, selected preload, create-on-the-fly, or collection-backed select setup",
    "For single-value fields, Tom Select's scalar cleared value is wrapped, so a clear event typically has `values: [\"\"]` and `options: [null]`.",
    "For multiple-value fields, clear keeps Tom Select's empty array shape as `values: []` and `options: []`."
  ],
  "request lifecycle and forwarded interaction boundary docs"
)

assertSignals(
  developmentDoc,
  "doc/development.md",
  [
    "request lifecycle and event payloads",
    "Tom Select forwarded interaction event payloads",
    "request success / failure details",
    "error-surface metadata",
    "smoke inventory guard"
  ],
  "JavaScript smoke family docs"
)

console.log("Tom Select event docs signals passed.")
