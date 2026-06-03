import assert from "node:assert/strict"
import { readdir, readFile } from "node:fs/promises"
import path from "node:path"
import { fileURLToPath } from "node:url"

const intentionalStandaloneCheckScripts = new Set([
  // Add scripts/check_*.mjs entries here only when a smoke is intentionally not part of check:js.
].map(normalizeScriptPath))

function normalizeScriptPath(scriptPath) {
  return scriptPath.replace(/\\/g, "/").replace(/^\.\//, "")
}

function extractNodeSmokeScriptReferencesFromRunner(source) {
  return [...source.matchAll(/args:\s*\["(?<script>scripts\/check_[^"]+\.mjs)"\]/g)]
    .map((match) => match.groups.script)
    .map(normalizeScriptPath)
}

function evaluateInventory({ actualScripts, runnerSource, excludedScripts = intentionalStandaloneCheckScripts }) {
  const actualSet = new Set(actualScripts.map(normalizeScriptPath))
  const referencedScripts = extractNodeSmokeScriptReferencesFromRunner(runnerSource)
  const referencedSet = new Set(referencedScripts)
  const excludedSet = new Set([...excludedScripts].map(normalizeScriptPath))
  const expectedScripts = [...actualSet].filter((scriptPath) => !excludedSet.has(scriptPath)).sort()

  const missingScripts = expectedScripts.filter((scriptPath) => !referencedSet.has(scriptPath))
  const staleReferences = referencedScripts.filter((scriptPath) => !actualSet.has(scriptPath))
  const staleExclusions = [...excludedSet].filter((scriptPath) => !actualSet.has(scriptPath))
  const referencedExclusions = [...excludedSet].filter((scriptPath) => referencedSet.has(scriptPath))

  assert.deepEqual(
    missingScripts,
    [],
    `scripts/check_javascript.mjs must include CI-owned smoke scripts: ${missingScripts.join(", ")}`
  )
  assert.deepEqual(
    staleReferences,
    [],
    `scripts/check_javascript.mjs references missing smoke scripts: ${staleReferences.join(", ")}`
  )
  assert.deepEqual(
    staleExclusions,
    [],
    `intentional standalone smoke script exclusions must point to existing scripts: ${staleExclusions.join(", ")}`
  )
  assert.deepEqual(
    referencedExclusions,
    [],
    `intentional standalone smoke scripts should not also be referenced by check:js: ${referencedExclusions.join(", ")}`
  )

  return { expectedScripts, referencedScripts }
}

async function smokeScriptsUnder(repoRoot) {
  const scriptsDir = path.join(repoRoot, "scripts")
  const entries = await readdir(scriptsDir)

  return entries
    .filter((entry) => /^check_.*\.mjs$/.test(entry))
    .map((entry) => normalizeScriptPath(path.join("scripts", entry)))
    .sort()
}

async function runInventoryCheck() {
  const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
  const runnerSource = await readFile(path.join(repoRoot, "scripts", "check_javascript.mjs"), "utf8")
  const actualScripts = await smokeScriptsUnder(repoRoot)
  const { expectedScripts } = evaluateInventory({ actualScripts, runnerSource })

  console.log(`rails_fields_kit JavaScript smoke inventory passed (${expectedScripts.length} scripts checked)`)
}

function assertThrowsWithMessage(callback, expectedMessage) {
  assert.throws(callback, (error) => {
    assert.match(error.message, expectedMessage)
    return true
  })
}

function runSelfTests() {
  const actualScripts = [
    "scripts/check_alpha.mjs",
    "scripts/check_beta.mjs",
    "scripts/check_standalone.mjs"
  ]

  evaluateInventory({
    actualScripts,
    runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }, { args: ["scripts/check_beta.mjs"] }]',
    excludedScripts: new Set(["scripts/check_standalone.mjs"])
  })

  assertThrowsWithMessage(
    () => evaluateInventory({
      actualScripts,
      runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }]',
      excludedScripts: new Set(["scripts/check_standalone.mjs"])
    }),
    /check_beta\.mjs/
  )

  assertThrowsWithMessage(
    () => evaluateInventory({
      actualScripts,
      runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }, { args: ["scripts/check_beta.mjs"] }, { args: ["scripts/check_missing.mjs"] }]',
      excludedScripts: new Set(["scripts/check_standalone.mjs"])
    }),
    /check_missing\.mjs/
  )

  assertThrowsWithMessage(
    () => evaluateInventory({
      actualScripts,
      runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }, { args: ["scripts/check_beta.mjs"] }, { args: ["scripts/check_standalone.mjs"] }]',
      excludedScripts: new Set(["scripts/check_standalone.mjs"])
    }),
    /check_standalone\.mjs/
  )

  console.log("rails_fields_kit JavaScript smoke inventory self-test passed")
}

if (process.argv.includes("--self-test")) {
  runSelfTests()
} else {
  await runInventoryCheck()
}
