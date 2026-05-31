# frozen_string_literal: true

require "fileutils"
require "tmpdir"
require "spec_helper"
require "generators/rails_fields_kit/install_generator"

RSpec.describe RailsFieldsKit::Generators::InstallGenerator do
  let(:destination_root) { Dir.mktmpdir("rails_fields_kit_generator") }

  after do
    FileUtils.remove_entry(destination_root) if File.directory?(destination_root)
  end

  def run_generator(args = [])
    described_class.start(args, destination_root: destination_root)
  end

  def write_file(path, content)
    absolute_path = File.join(destination_root, path)
    FileUtils.mkdir_p(File.dirname(absolute_path))
    File.write(absolute_path, content)
  end

  def read_file(path)
    File.read(File.join(destination_root, path))
  end

  it "creates the initializer and setup note without touching importmap by default" do
    write_file "config/importmap.rb", "# existing importmap\n"

    run_generator

    expect(File).to exist(File.join(destination_root, "config/initializers/rails_fields_kit.rb"))
    expect(File).to exist(File.join(destination_root, "doc/rails_fields_kit_setup.md"))
    expect(read_file("config/importmap.rb")).to eq("# existing importmap\n")
  end

  it "appends the documented Rails Fields Kit pins when importmap opt-in is used" do
    write_file "config/importmap.rb", "pin \"tom-select\"\n"

    run_generator ["--importmap"]

    expect(read_file("config/importmap.rb")).to include(
      "pin \"tom-select\"",
      "pin \"rails_fields_kit\", to: \"rails_fields_kit/index.js\"",
      "pin \"rails_fields_kit/tom_select_controller\", to: \"rails_fields_kit/tom_select_controller.js\""
    )
  end

  it "does not duplicate existing importmap pins" do
    write_file "config/importmap.rb", <<~RUBY
      pin "rails_fields_kit", to: "rails_fields_kit/index.js"
    RUBY

    run_generator ["--importmap"]

    importmap = read_file("config/importmap.rb")
    expect(importmap.scan(/pin "rails_fields_kit"/).size).to eq(1)
    expect(importmap).to include(
      "pin \"rails_fields_kit/tom_select_controller\", to: \"rails_fields_kit/tom_select_controller.js\""
    )
  end

  it "does not create config/importmap.rb when opt-in is used without an existing importmap" do
    run_generator ["--importmap"]

    expect(File).not_to exist(File.join(destination_root, "config/importmap.rb"))
  end
end
