# frozen_string_literal: true

require "fileutils"
require "stringio"
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

  def capture_generator_output(args = [])
    original_stdout = $stdout
    output = StringIO.new
    $stdout = output
    run_generator(args)
    output.string
  ensure
    $stdout = original_stdout
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

  it "keeps importmap opt-in guidance when importmap is not requested" do
    write_file "config/importmap.rb", "# existing importmap\n"

    output = capture_generator_output

    expect(output).to include("If this app uses importmap, run with --importmap or add the documented pins manually.")
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

  it "reports completed importmap pins without prompting another importmap run" do
    write_file "config/importmap.rb", "pin \"tom-select\"\n"

    output = capture_generator_output ["--importmap"]

    expect(output).to include("Rails Fields Kit importmap pins were added to config/importmap.rb.")
    expect(output).not_to include("run with --importmap")
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

  it "reports existing importmap pins without prompting another importmap run" do
    write_file "config/importmap.rb", <<~RUBY
      pin "rails_fields_kit", to: "rails_fields_kit/index.js"
      pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"
    RUBY

    output = capture_generator_output ["--importmap"]

    expect(output).to include("Rails Fields Kit importmap pins already exist in config/importmap.rb.")
    expect(output).not_to include("run with --importmap")
  end

  it "does not create config/importmap.rb when opt-in is used without an existing importmap" do
    run_generator ["--importmap"]

    expect(File).not_to exist(File.join(destination_root, "config/importmap.rb"))
  end

  it "points to manual pins when importmap opt-in is used without an existing importmap" do
    output = capture_generator_output ["--importmap"]

    expect(output).to include("config/importmap.rb was not found")
    expect(output).to include("add the documented pins manually if this app uses importmap")
    expect(output).not_to include("run with --importmap")
  end
end
