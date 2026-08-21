# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"
require "generators/rails_fields_kit/install_generator"

RSpec.describe "Rails Fields Kit install generator importmap pins" do
  around do |example|
    Dir.mktmpdir("rails_fields_kit_install_generator") do |dir|
      @destination_root = dir
      example.run
    end
  end

  def destination_root
    @destination_root
  end

  def importmap_path
    File.join(destination_root, "config/importmap.rb")
  end

  def write_importmap(contents)
    FileUtils.mkdir_p(File.dirname(importmap_path))
    File.write(importmap_path, contents)
  end

  def run_generator(*args)
    RailsFieldsKit::Generators::InstallGenerator.start(args, destination_root: destination_root)
  end

  def importmap_content
    File.read(importmap_path)
  end

  it "leaves importmap.rb unchanged when --importmap is not requested" do
    write_importmap(<<~RUBY)
      pin "application"
    RUBY

    run_generator("--skip-setup-notes")

    expect(importmap_content).to eq(<<~RUBY)
      pin "application"
    RUBY
  end

  it "does not create config/importmap.rb when --importmap is requested but the file is missing" do
    run_generator("--importmap", "--skip-setup-notes")

    expect(File.exist?(importmap_path)).to be(false)
  end

  it "appends both Rails Fields Kit pins when importmap.rb exists without them" do
    write_importmap(<<~RUBY)
      pin "application"
    RUBY

    run_generator("--importmap", "--skip-setup-notes")

    expect(importmap_content).to include(%(pin "rails_fields_kit", to: "rails_fields_kit/index.js"))
    expect(importmap_content).to include(%(pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"))
  end

  it "does not duplicate existing Rails Fields Kit pins" do
    write_importmap(<<~RUBY)
      pin "application"
      pin "rails_fields_kit", to: "rails_fields_kit/index.js"
      pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"
    RUBY

    run_generator("--importmap", "--skip-setup-notes")

    expect(importmap_content.scan(/pin "rails_fields_kit"/).length).to eq(1)
    expect(importmap_content.scan(%r{pin "rails_fields_kit/tom_select_controller"}).length).to eq(1)
  end

  it "appends only the missing importmap pin when one Rails Fields Kit pin already exists" do
    write_importmap(<<~RUBY)
      pin "application"
      pin "rails_fields_kit", to: "rails_fields_kit/index.js"
    RUBY

    run_generator("--importmap", "--skip-setup-notes")

    expect(importmap_content.scan(/pin "rails_fields_kit"/).length).to eq(1)
    expect(importmap_content.scan(%r{pin "rails_fields_kit/tom_select_controller"}).length).to eq(1)
  end
end
