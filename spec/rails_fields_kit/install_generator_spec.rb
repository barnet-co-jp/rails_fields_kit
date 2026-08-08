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

  it "uses the setup doctor importmap pins" do
    expect(described_class::IMPORTMAP_PINS).to eq(RailsFieldsKit::SetupDoctor::IMPORTMAP_PINS)
  end

  it "keeps generated setup notes aligned with first-pass setup and follow-up boundaries" do
    setup_notes = File.read(File.join(described_class.source_root, "rails_fields_kit_setup.md"))

    expect(setup_notes).to include("rails rails_fields_kit:doctor")
    expect(setup_notes).to include("Use the doctor output as a read-only prompt")
    expect(setup_notes).to include("first Rails Fields Kit field")
    expect(setup_notes).to include("selected_url:")
    expect(setup_notes).to include("option_description_field:")
    expect(setup_notes).to include("option_badge_field:")
    expect(setup_notes).to include("rfk_search_with")
    expect(setup_notes).to include("rfk_find_with")
    expect(setup_notes).to include("rfk_create_with")
    expect(setup_notes).to include("instead of copying that setup here")
    expect(setup_notes).to include(
      "doc/tom_select_text_override_visual_reference.html",
      "doc/selected_preload_release_gate.md",
      "doc/package_root_helper_release_evidence.md"
    )
    expect(setup_notes).not_to include("value_method:")
    expect(setup_notes).not_to include("label_method:")
  end

  it "keeps terminal next steps aligned with the package-root controller registration" do
    generator = described_class.new
    messages = []
    allow(generator).to receive(:say) { |message, *_args| messages << message }

    generator.show_next_steps

    next_steps = messages.join("\n")
    expect(next_steps).to include(
      "Import { TomSelectController } from \"rails_fields_kit\"",
      "register it as \"rails-fields-kit--tom-select\""
    )
    expect(next_steps).not_to include("RailsFieldsKit::TomSelectController")
  end
end
