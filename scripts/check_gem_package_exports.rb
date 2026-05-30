# frozen_string_literal: true

require "json"
require "rubygems/package"
require "stringio"
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
missing_exports = required_exports.reject { |export_name| exports.key?(export_name) }

abort "package.json is missing exports: #{missing_exports.join(", ")}" unless missing_exports.empty?

missing_files = required_exports.filter_map do |export_name|
  target = exports.fetch(export_name)
  target = target.fetch("import") if target.is_a?(Hash)
  target_path = target.to_s.delete_prefix("./")

  "#{export_name} -> #{target}" unless entries.key?(target_path)
end

abort "built gem is missing exported JavaScript files: #{missing_files.join(", ")}" unless missing_files.empty?

puts "rails_fields_kit built gem package exports check passed"
