# frozen_string_literal: true

require "spec_helper"

RSpec.describe "gemspec validation" do
  subject(:specification) do
    Gem::Specification.load(File.expand_path("../../rails_fields_kit.gemspec", __dir__))
  end

  it "is valid according to RubyGems" do
    expect { specification.validate }.not_to raise_error
  end

  it "has a non-empty file list" do
    expect(specification.files).not_to be_empty
  end

  it "includes only existing files" do
    missing_files = specification.files.reject { |path| File.file?(File.expand_path("../../#{path}", __dir__)) }

    expect(missing_files).to be_empty
  end
end
