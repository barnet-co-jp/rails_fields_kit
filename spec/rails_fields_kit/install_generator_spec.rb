# frozen_string_literal: true

require "spec_helper"
require "generators/rails_fields_kit/install_generator"

RSpec.describe RailsFieldsKit::Generators::InstallGenerator do
  it "loads the install generator" do
    expect(described_class).to be < Rails::Generators::Base
  end

  it "uses the packaged templates directory as its source root" do
    expect(described_class.source_root.to_s).to end_with("lib/generators/rails_fields_kit/templates")
  end

  it "ships the initializer and setup note templates" do
    source_root = described_class.source_root

    expect(File.file?(File.join(source_root, "rails_fields_kit.rb"))).to be(true)
    expect(File.file?(File.join(source_root, "rails_fields_kit_setup.md"))).to be(true)
  end
end
