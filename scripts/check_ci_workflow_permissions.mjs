import assert from "node:assert/strict"
import { readFileSync } from "node:fs"

const workflowPath = ".github/workflows/ci.yml"
const developmentGuidePath = "doc/development.md"
const workflow = readFileSync(workflowPath, "utf8")
const developmentGuide = readFileSync(developmentGuidePath, "utf8")

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

assert.doesNotMatch(
  workflow,
  /^\s*permissions:\s*write-all\s*$/m,
  "CI workflow should not use write-all permissions; future write-permission workflows need separate review"
)

assert.match(
  workflow,
  /^\s+uses: actions\/checkout@v\d+$/m,
  "CI workflow permissions guard should continue to cover jobs that need repository checkout"
)

assert.match(
  developmentGuide,
  /The CI workflow permissions smoke keeps `.github\/workflows\/ci\.yml` on an explicit top-level `permissions: contents: read` policy/,
  "development guide should document the explicit read-only CI workflow permissions boundary"
)

assert.match(
  developmentGuide,
  /not as a replacement for GitHub branch protection, review policy, or release approval/,
  "development guide should keep CI permissions smoke separate from branch protection, review policy, and release approval"
)

console.log("[ci-permissions] workflow permissions signals passed")
