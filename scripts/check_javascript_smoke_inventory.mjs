import assert from "node:assert/strict"
import { readdir, readFile } from "node:fs/promises"
import path from "node:path"
import { fileURLToPath } from "node:url"

const CHECK_RUNNER = "check_javascript.mjs"
const STANDALONE_REASON_MAX_LENGTH = 120
const intentionalStandaloneCheckScripts = new Map([
  // Add ["scripts/check_example.mjs", "short reason"] entries here only when a smoke is intentionally not part of check:js.
].map(([scriptPath, reason]) => [normalizeScriptPath(scriptPath), reason]))

function normalizeScriptPath(scriptPath) {
  return scriptPath.replace(/\\/g, "/").replace(/^\.\//, "")
}

function extractNodeSmokeScriptReferencesFromRunner(source) {
  return [...source.matchAll(/args:\s*\["(?<script>scripts\/check_[^"]+\.mjs)"\]/g)]
    .map((match) => match.groups.script)
    .map(normalizeScriptPath)
}

function normalizeStandaloneExclusions(excludedScripts) {
  const entries = excludedScripts instanceof Map
    ? [...excludedScripts.entries()]
    : [...excludedScripts].map((scriptPath) => [scriptPath, "self-test fixture"])

  return new Map(entries.map(([scriptPath, reason]) => [normalizeScriptPath(scriptPath), reason]))
}

function evaluateInventory({ actualScripts, runnerSource, excludedScripts = intentionalStandaloneCheckScripts }) {
  const actualSet = new Set(actualScripts.map(normalizeScriptPath))
  const referencedScripts = extractNodeSmokeScriptReferencesFromRunner(runnerSource)
  const referencedSet = new Set(referencedScripts)
  const excludedMap = normalizeStandaloneExclusions(excludedScripts)
  const excludedSet = new Set(excludedMap.keys())
  const expectedScripts = [...actualSet].filter((scriptPath) => !excludedSet.has(scriptPath)).sort()

  const missingScripts = expectedScripts.filter((scriptPath) => !referencedSet.has(scriptPath))
  const staleReferences = referencedScripts.filter((scriptPath) => !actualSet.has(scriptPath))
  const staleExclusions = [...excludedSet].filter((scriptPath) => !actualSet.has(scriptPath))
  const referencedExclusions = [...excludedSet].filter((scriptPath) => referencedSet.has(scriptPath))
  const exclusionsWithoutReasons = [...excludedMap]
    .filter(([, reason]) => typeof reason !== "string" || reason.trim().length === 0)
    .map(([scriptPath]) => scriptPath)
  const exclusionsWithMultilineReasons = [...excludedMap]
    .filter(([, reason]) => typeof reason === "string" && /\r|\n/.test(reason))
    .map(([scriptPath]) => scriptPath)
  const exclusionsWithLongReasons = [...excludedMap]
    .filter(([, reason]) => typeof reason === "string" && reason.trim().length > STANDALONE_REASON_MAX_LENGTH)
    .map(([scriptPath]) => scriptPath)

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
  assert.deepEqual(
    exclusionsWithoutReasons,
    [],
    `intentional standalone smoke script exclusions must include a short reason: ${exclusionsWithoutReasons.join(", ")}`
  )
  assert.deepEqual(
    exclusionsWithMultilineReasons,
    [],
    `intentional standalone smoke script exclusion reasons must stay on one line: ${exclusionsWithMultilineReasons.join(", ")}`
  )
  assert.deepEqual(
    exclusionsWithLongReasons,
    [],
    `intentional standalone smoke script exclusion reasons must stay within ${STANDALONE_REASON_MAX_LENGTH} characters: ${exclusionsWithLongReasons.join(", ")}`
  )

  return { expectedScripts, referencedScripts }
}

async function smokeScriptsUnder(repoRoot) {
  const scriptsDir = path.join(repoRoot, "scripts")
  const entries = await readdir(scriptsDir)

  return entries
    .filter((entry) => entry !== CHECK_RUNNER)
    .filter((entry) => /^check_.*\.mjs$/.test(entry))
    .map((entry) => normalizeScriptPath(path.join("scripts", entry)))
    .sort()
}

async function runInventoryCheck() {
  const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
  const runnerSource = await readFile(path.join(repoRoot, "scripts", CHECK_RUNNER), "utf8")
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
    excludedScripts: new Map([["scripts/check_standalone.mjs", "intentionally exercised outside check:js"]])
  })

  assertThrowsWithMessage(
    () => evaluateInventory({
      actualScripts,
      runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }]',
      excludedScripts: new Map([["scripts/check_standalone.mjs", "intentionally exercised outside check:js"]])
    }),
    /check_beta\.mjs/
  )

  assertThrowsWithMessage(
    () => evaluateInventory({
      actualScripts,
      runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }, { args: ["scripts/check_beta.mjs"] }, { args: ["scripts/check_missing.mjs"] }]',
      excludedScripts: new Map([["scripts/check_standalone.mjs", "intentionally exercised outside check:js"]])
    }),
    /check_missing\.mjs/
  )

  assertThrowsWithMessage(
    () => evaluateInventory({
      actualScripts,
      runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }, { args: ["scripts/check_beta.mjs"] }, { args: ["scripts/check_standalone.mjs"] }]',
      excludedScripts: new Map([["scripts/check_standalone.mjs", "intentionally exercised outside check:js"]])
    }),
    /check_standalone\.mjs/
  )

  assertThrowsWithMessage(
    () => evaluateInventory({
      actualScripts,
      runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }, { args: ["scripts/check_beta.mjs"] }]',
      excludedScripts: new Map([["scripts/check_standalone.mjs", ""]])
    }),
    /short reason.*check_standalone\.mjs/
  )

  assertThrowsWithMessage(
    () => evaluateInventory({
      actualScripts,
      runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }, { args: ["scripts/check_beta.mjs"] }]',
      excludedScripts: new Map([["scripts/check_standalone.mjs", "exercised outside check:js\nwith a second line"]])
    }),
    /one line.*check_standalone\.mjs/
  )

  assertThrowsWithMessage(
    () => evaluateInventory({
      actualScripts,
      runnerSource: 'const checks = [{ args: ["scripts/check_alpha.mjs"] }, { args: ["scripts/check_beta.mjs"] }]',
      excludedScripts: new Map([["scripts/check_standalone.mjs", "x".repeat(STANDALONE_REASON_MAX_LENGTH + 1)]])
    }),
    /120 characters.*check_standalone\.mjs/
  )

  console.log("rails_fields_kit JavaScript smoke inventory self-test passed")
}

if (process.argv.includes("--self-test")) {
  runSelfTests()
} else {
  await runInventoryCheck()
}
