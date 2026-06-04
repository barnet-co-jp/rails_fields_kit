# frozen_string_literal: true

require "spec_helper"
require "rake"

RSpec.describe "Rake tasks" do
  let(:rakefile_path) { File.expand_path("../../Rakefile", __dir__) }
  let(:task_path) { File.expand_path("../../lib/tasks/rails_fields_kit.rake", __dir__) }
  let(:rakefile) { File.read(rakefile_path) }
  let(:rake) { Rake::Application.new }

  around do |example|
    original_application = Rake.application
    Rake.application = rake
    load rakefile_path
    load task_path
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

  it "defines the setup doctor task" do
    expect(rake.lookup("rails_fields_kit:doctor")).not_to be_nil
  end

  it "runs the setup doctor task" do
    doctor = instance_double(RailsFieldsKit::SetupDoctor)

    expect(RailsFieldsKit::SetupDoctor).to receive(:new).and_return(doctor)
    expect(doctor).to receive(:run)

    rake["rails_fields_kit:doctor"].invoke
  end

  it "loads Bundler gem tasks for build and release" do
    expect(rakefile).to include('require "bundler/gem_tasks"')
  end
end
