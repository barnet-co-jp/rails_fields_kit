# frozen_string_literal: true

require "spec_helper"
require "rake"

RSpec.describe "Rake tasks" do
  let(:rakefile_path) { File.expand_path("../../Rakefile", __dir__) }
  let(:rakefile) { File.read(rakefile_path) }
  let(:rake) { Rake::Application.new }

  around do |example|
    original_application = Rake.application
    Rake.application = rake
    load rakefile_path
    example.run
  ensure
    Rake.application = original_application
  end

  it "defines the default task" do
    expect(rake.lookup("default")).not_to be_nil
  end

  it "defines the spec task" do
    expect(rake.lookup("spec")).not_to be_nil
  end

  it "loads Bundler gem tasks for build and release" do
    expect(rakefile).to include('require "bundler/gem_tasks"')
  end
end
