# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "stringio"
require "tmpdir"

RSpec.describe RailsFieldsKit::SetupDoctor do
  def write_file(root, path, content = "")
    absolute_path = File.join(root, path)
    FileUtils.mkdir_p(File.dirname(absolute_path))
    File.write(absolute_path, content)
  end

  def check_for(doctor, key)
    doctor.checks.find { |check| check.key == key }
  end

  it "reports whether the initializer is present" do
    Dir.mktmpdir do |root|
      expect(check_for(described_class.new(root: root), :initializer).status).to eq(:missing)

      write_file(root, "config/initializers/rails_fields_kit.rb")

      initializer_check = check_for(described_class.new(root: root), :initializer)
      expect(initializer_check.status).to eq(:ok)
      expect(initializer_check.message).to include("config/initializers/rails_fields_kit.rb")
    end
  end

  it "keeps importmap as a manual item when config/importmap.rb is absent" do
    Dir.mktmpdir do |root|
      importmap_check = check_for(described_class.new(root: root), :importmap)

      expect(importmap_check.status).to eq(:manual)
      expect(importmap_check.message).to include("config/importmap.rb was not found")
    end
  end

  it "reports complete importmap pins when config/importmap.rb exists" do
    Dir.mktmpdir do |root|
      write_file(root, "config/importmap.rb", <<~RUBY)
        pin "rails_fields_kit", to: "rails_fields_kit/index.js"
        pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"
      RUBY

      importmap_check = check_for(described_class.new(root: root), :importmap)

      expect(importmap_check.status).to eq(:ok)
      expect(importmap_check.message).to include("Rails Fields Kit importmap pins are present")
    end
  end

  it "reports importmap pins with unexpected targets" do
    Dir.mktmpdir do |root|
      write_file(root, "config/importmap.rb", <<~RUBY)
        pin "rails_fields_kit", to: "rails_fields_kit.js"
        pin "rails_fields_kit/tom_select_controller"
      RUBY

      importmap_check = check_for(described_class.new(root: root), :importmap)

      expect(importmap_check.status).to eq(:missing)
      expect(importmap_check.message).to include("unexpected targets")
      expect(importmap_check.message).to include("rails_fields_kit (expected rails_fields_kit/index.js, found rails_fields_kit.js)")
      expect(importmap_check.message).to include("rails_fields_kit/tom_select_controller (expected rails_fields_kit/tom_select_controller.js, found no explicit target)")
    end
  end

  it "prints a status legend before individual setup checks" do
    Dir.mktmpdir do |root|
      output = StringIO.new

      described_class.new(root: root).run(io: output)

      expect(output.string).to include("Status legend: [OK] detected setup; [MISSING] needs action for the detected setup route; [MANUAL] host-app check, not an automatic failure.")
      expect(output.string).to include("Next step: fix [MISSING] lines first, then review [MANUAL] lines for this app's JavaScript toolchain.")
      expect(output.string).to match(/Next step:.*\n\n\[MISSING\] Initializer/m)
    end
  end

  it "reports missing importmap pins without treating toolchain variance as an invocation failure" do
    Dir.mktmpdir do |root|
      write_file(root, "config/importmap.rb", <<~RUBY)
        pin "rails_fields_kit", to: "rails_fields_kit/index.js"
      RUBY

      doctor = described_class.new(root: root)
      importmap_check = check_for(doctor, :importmap)
      output = StringIO.new

      expect(importmap_check.status).to eq(:missing)
      expect(importmap_check.message).to include("rails_fields_kit/tom_select_controller")
      expect(doctor.run(io: output)).to eq(true)
      expect(output.string).to include("[MISSING] Importmap pins")
      expect(output.string).to include("[MANUAL] Tom Select package")
      expect(output.string).to include("[MANUAL] Stimulus registration")
      expect(output.string).to include("[MANUAL] CSS import")
      expect(output.string).to include("[MANUAL] Bundler alias")
      expect(output.string).to include("rails_fields_kit and rails_fields_kit/tom_select_controller")
      expect(output.string).to include("does not inspect or rewrite bundler config")
    end
  end
end
