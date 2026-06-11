import { spawnSync } from "node:child_process"

const checks = [
  {
    name: "syntax: package entrypoint",
    args: ["--check", "app/javascript/rails_fields_kit/index.js"]
  },
  {
    name: "syntax: Tom Select controller",
    args: ["--check", "app/javascript/rails_fields_kit/tom_select_controller.js"]
  },
  {
    name: "JavaScript smoke inventory guard",
    args: ["scripts/check_javascript_smoke_inventory.mjs"]
  },
  {
    name: "package exports smoke",
    args: ["scripts/check_package_exports.mjs"]
  },
  {
    name: "Tom Select query params smoke",
    args: ["scripts/check_tom_select_query_params.mjs"]
  },
  {
    name: "Tom Select interaction events smoke",
    args: ["scripts/check_tom_select_interaction_events.mjs"]
  },
  {
    name: "Tom Select create headers and response normalization smoke",
    args: ["scripts/check_tom_select_create_headers.mjs"]
  },
  {
    name: "Tom Select error surface smoke",
    args: ["scripts/check_tom_select_error_surface.mjs"]
  },
  {
    name: "Tom Select Turbo lifecycle smoke",
    args: ["scripts/check_tom_select_turbo_lifecycle.mjs"]
  },
  {
    name: "Tom Select label fallback smoke",
    args: ["scripts/check_tom_select_label_fallback.mjs"]
  },
  {
    name: "Tom Select option value guard smoke",
    args: ["scripts/check_tom_select_option_value_guard.mjs"]
  },
  {
    name: "Tom Select render text fallback smoke",
    args: ["scripts/check_tom_select_render_text_fallback.mjs"]
  },
  {
    name: "Tom Select render text accessibility smoke",
    args: ["scripts/check_tom_select_render_text_accessibility.mjs"]
  },
  {
    name: "Tom Select plugin contract smoke",
    args: ["scripts/check_tom_select_plugin_contract.mjs"]
  },
  {
    name: "selected preload config contract smoke",
    args: ["scripts/check_selected_preload_config_contract.mjs"]
  }
]

for (const check of checks) {
  console.log(`[check:js] ${check.name}`)

  const result = spawnSync(process.execPath, check.args, { stdio: "inherit" })

  if (result.error) {
    console.error(`[check:js] ${check.name} failed: ${result.error.message}`)
    process.exit(1)
  }

  if (result.status !== 0) {
    console.error(`[check:js] ${check.name} failed with exit code ${result.status}`)
    process.exit(result.status ?? 1)
  }
}

console.log("[check:js] all checks passed")
