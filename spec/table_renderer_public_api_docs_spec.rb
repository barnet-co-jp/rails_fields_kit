# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TableRenderer public API docs" do
  let(:table_renderer_source) { File.read(File.expand_path("../lib/rails_fields_kit/table_renderer.rb", __dir__)) }
  let(:public_api_doc) { File.read(File.expand_path("../doc/public_api.md", __dir__)) }

  it "keeps the compact TableRenderer method list aligned with public class methods" do
    expect(documented_table_renderer_methods(public_api_doc)).to eq(public_table_renderer_methods(table_renderer_source))
  end

  def public_table_renderer_methods(source)
    class_methods = source.match(/class << self\n(?<body>.*?)^      private$/m)
    raise "TableRenderer class method block was not found" unless class_methods

    class_methods[:body].scan(/^      def ([a-z_!?]+)/).flatten
  end

  def documented_table_renderer_methods(document)
    section = document.split("### TableRenderer methods", 2).last
    raise "TableRenderer methods section was not found" unless section && section != document

    section = section.split(/\n(?=### )/, 2).first
    section.scan(/`RailsFieldsKit::TableRenderer\.([a-z_!?]+)`/).flatten
  end
end
