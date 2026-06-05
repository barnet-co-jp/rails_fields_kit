# frozen_string_literal: true

require "spec_helper"

RSpec.describe "packaged files" do
  subject(:files) do
    Gem::Specification.load(File.expand_path("../../rails_fields_kit.gemspec", __dir__)).files
  end

  it "includes JavaScript entrypoints" do
    expect(files).to include(
      "app/javascript/rails_fields_kit/index.js",
      "app/javascript/rails_fields_kit/tom_select_controller.js"
    )
  end

  it "includes install generator files" do
    expect(files).to include(
      "lib/generators/rails_fields_kit/install_generator.rb",
      "lib/generators/rails_fields_kit/templates/rails_fields_kit.rb",
      "lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md"
    )
  end

  it "includes setup doctor files" do
    expect(files).to include(
      "lib/rails_fields_kit/setup_doctor.rb",
      "lib/tasks/rails_fields_kit.rake"
    )
  end
end
