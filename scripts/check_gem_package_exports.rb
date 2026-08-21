# frozen_string_literal: true

require "fileutils"
require "json"
require "rubygems/package"
require "stringio"
require "tmpdir"
require "zlib"

gem_path = ARGV.fetch(0) do
  abort "usage: ruby scripts/check_gem_package_exports.rb path/to/rails_fields_kit-*.gem"
end

entries = {}
data_tar_gz = nil

File.open(gem_path, "rb") do |io|
  Gem::Package::TarReader.new(io) do |gem_tar|
    gem_tar.each do |entry|
      data_tar_gz = entry.read if entry.full_name == "data.tar.gz"
    end
  end
end

abort "#{gem_path} does not contain data.tar.gz" unless data_tar_gz

Zlib::GzipReader.wrap(StringIO.new(data_tar_gz)) do |gzip|
  Gem::Package::TarReader.new(gzip) do |data_tar|
    data_tar.each do |entry|
      entries[entry.full_name] = entry.read unless entry.directory?
    end
  end
end

package_json = entries.fetch("package.json") do
  abort "built gem is missing package.json"
end

exports = JSON.parse(package_json).fetch("exports")
required_exports = [".", "./tom_select_controller"]
expected_package_root_named_exports = [
  "TomSelectController",
  "tomSelectTextOverrideContract",
  "tomSelectPluginContract",
  "tomSelectSelectionContract",
  "tomSelectRequestContract",
  "readRenderedErrorSurface",
  "readRenderedSelectedPreloadConfig",
  "nativeFieldAccessibilityContract"
]
expected_callable_helper_exports = expected_package_root_named_exports - ["TomSelectController"]
missing_exports = required_exports.reject { |export_name| exports.key?(export_name) }

abort "package.json is missing exports: #{missing_exports.join(", ")}" unless missing_exports.empty?

def export_target_path(exports, export_name)
  target = exports.fetch(export_name)
  target = target.fetch("import") if target.is_a?(Hash)
  target.to_s.delete_prefix("./")
end

missing_files = required_exports.filter_map do |export_name|
  target_path = export_target_path(exports, export_name)

  "#{export_name} -> #{target_path}" unless entries.key?(target_path)
end

abort "built gem is missing exported JavaScript files: #{missing_files.join(", ")}" unless missing_files.empty?

Dir.mktmpdir("rails-fields-kit-built-gem-import-") do |dir|
  package_root = File.join(dir, "node_modules", "rails_fields_kit")
  FileUtils.mkdir_p(package_root)

  entries.each do |path, content|
    next unless path == "package.json" || path.start_with?("app/javascript/rails_fields_kit/")

    destination = File.join(package_root, path)
    FileUtils.mkdir_p(File.dirname(destination))
    File.binwrite(destination, content)
  end

  FileUtils.mkdir_p(File.join(dir, "node_modules", "@hotwired", "stimulus"))
  File.write(
    File.join(dir, "node_modules", "@hotwired", "stimulus", "package.json"),
    "{\n  \"type\": \"module\"\n}\n"
  )
  File.write(
    File.join(dir, "node_modules", "@hotwired", "stimulus", "index.js"),
    "export class Controller {\n  static values = {}\n}\n"
  )

  FileUtils.mkdir_p(File.join(dir, "node_modules", "tom-select"))
  File.write(
    File.join(dir, "node_modules", "tom-select", "package.json"),
    "{\n  \"type\": \"module\"\n}\n"
  )
  File.write(
    File.join(dir, "node_modules", "tom-select", "index.js"),
    <<~JS
      export default class TomSelect {
        constructor(element, options = {}) {
          this.element = element
          this.options = options
        }

        destroy() {}
      }
    JS
  )

  probe_path = File.join(dir, "probe.mjs")
  File.write(
    probe_path,
    <<~JS
      import rootDefault, * as packageRoot from "rails_fields_kit"
      import directDefault from "rails_fields_kit/tom_select_controller"
      import assert from "node:assert/strict"

      const expectedNamedExports = #{JSON.generate(expected_package_root_named_exports)}
      const expectedCallableHelperExports = #{JSON.generate(expected_callable_helper_exports)}

      expectedNamedExports.forEach((exportName) => {
        assert.ok(exportName in packageRoot, `package root should expose documented export ${exportName}`)
      })
      assert.equal(rootDefault, packageRoot.TomSelectController, "package root default export should match TomSelectController")
      assert.equal(packageRoot.TomSelectController, directDefault, "package root controller export should match direct entrypoint")
      expectedCallableHelperExports.forEach((exportName) => {
        assert.equal(typeof packageRoot[exportName], "function", `package root should expose documented contract reader ${exportName} as a callable function`)
      })
    JS
  )

  unless system("node", probe_path, chdir: dir)
    abort "built gem JavaScript package import smoke failed"
  end
end

puts "rails_fields_kit built gem package exports check passed"
