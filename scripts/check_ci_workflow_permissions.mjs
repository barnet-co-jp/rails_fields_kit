import assert from "node:assert/strict"
import { readFileSync } from "node:fs"

const workflowPath = ".github/workflows/ci.yml"
const workflow = readFileSync(workflowPath, "utf8")

assert.match(
  workflow,
  /^permissions:\n  contents: read\n/m,
  "CI workflow should declare top-level read-only contents permission"
)

assert.doesNotMatch(
  workflow,
  /^\s*(contents|pull-requests): write\s*$/m,
  "CI workflow should not request contents: write or pull-requests: write permissions"
)

assert.match(
  workflow,
  /^\s+uses: actions\/checkout@v\d+$/m,
  "CI workflow permissions guard should continue to cover jobs that need repository checkout"
)

console.log("[ci-permissions] workflow permissions signals passed")
