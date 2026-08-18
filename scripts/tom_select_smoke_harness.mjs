import { mkdtemp, mkdir, cp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"

const repoRoot = process.cwd()

async function writeStubPackage(sandboxRoot, packageName, source) {
  const packageRoot = path.join(sandboxRoot, "node_modules", ...packageName.split("/"))

  await mkdir(packageRoot, { recursive: true })
  await writeFile(path.join(packageRoot, "package.json"), "{\n  \"type\": \"module\",\n  \"exports\": \"./index.js\"\n}\n")
  await writeFile(path.join(packageRoot, "index.js"), source)
}

async function installTomSelectControllerStubs(sandboxRoot) {
  await writeStubPackage(
    sandboxRoot,
    "@hotwired/stimulus",
    "export class Controller {\n  static values = {}\n}\n"
  )
  await writeStubPackage(
    sandboxRoot,
    "tom-select",
    "export default class TomSelect {\n  constructor(element, options = {}) {\n    this.element = element\n    this.options = options\n  }\n\n  destroy() {}\n}\n"
  )
}

export async function withTomSelectControllerSandbox(prefix, assertion) {
  const sandboxRoot = await mkdtemp(path.join(tmpdir(), prefix))

  try {
    await installTomSelectControllerStubs(sandboxRoot)

    const controllerDirectory = path.join(repoRoot, "app", "javascript", "rails_fields_kit")
    await cp(path.join(controllerDirectory, "tom_select_controller.js"), path.join(sandboxRoot, "tom_select_controller.js"))
    await cp(path.join(controllerDirectory, "tom_select_controller_base.js"), path.join(sandboxRoot, "tom_select_controller_base.js"))

    const controllerPath = path.join(sandboxRoot, "tom_select_controller.js")
    const { default: TomSelectController } = await import(pathToFileURL(controllerPath).href)
    await assertion({ TomSelectController, sandboxRoot })
  } finally {
    await rm(sandboxRoot, { recursive: true, force: true })
  }
}
