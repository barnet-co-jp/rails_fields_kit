# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "README docs map package contents" do
  let(:gemspec_path) { File.expand_path("../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }

  it "ships the support boundary and table group docs linked from the README docs map" do
    docs_map_paths = [
      "doc/support_boundary.md",
      "doc/table_group_html.md"
    ]

    expect(specification.files).to include(*docs_map_paths)

    docs_map_paths.each do |path|
      expect(readme).to include("[`#{path}`](#{path})")
    end
  end
end
