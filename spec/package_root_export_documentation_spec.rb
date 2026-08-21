# frozen_string_literal: true

require "spec_helper"

RSpec.describe "package-root JavaScript export documentation" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:package_root_source) { File.read(File.join(repo_root, "app/javascript/rails_fields_kit/index.js")) }
  let(:public_api_docs) { File.read(File.join(repo_root, "doc/public_api.md")) }

  def markdown_section(markdown, heading)
    heading_line = "#{heading}\n"
    heading_index = markdown.index(heading_line)
    return "" unless heading_index

    section_remainder = markdown[(heading_index + heading_line.length)..]
    next_heading_index = section_remainder.index(/\n##\s/)

    next_heading_index ? section_remainder[..next_heading_index] : section_remainder
  end

  def actual_package_root_named_exports(source)
    function_exports = source.scan(/^export function ([A-Za-z][A-Za-z0-9_]*)/).flatten
    list_exports = source.scan(/^export \{([^}]+)\}/).flatten.flat_map do |export_list|
      export_list.split(",").map do |export_name|
        export_name.strip.split(/\s+as\s+/).last
      end
    end

    (function_exports + list_exports).uniq
  end

  def documented_package_root_exports(markdown)
    javascript_exports_section = markdown_section(markdown, "## JavaScript exports")

    javascript_exports_section
      .scan(/^\| `([^`]+)` \| [^|]+ \|/)
      .flatten
      .map { |export_name| export_name.sub(/\(.*\)$/, "") }
      .uniq
  end

  it "keeps every package-root named export listed in the public API table" do
    actual_exports = actual_package_root_named_exports(package_root_source)
    documented_exports = documented_package_root_exports(public_api_docs)

    expect(actual_exports).to contain_exactly(*documented_exports)
  end
end
