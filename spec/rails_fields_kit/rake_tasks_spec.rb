# frozen_string_literal: true

require "spec_helper"
require "rake"

RSpec.describe "Rake tasks" do
  let(:rake) { Rake::Application.new }

  around do |example|
    original_application = Rake.application
    Rake.application = rake
    load File.expand_path("../../Rakefile", __dir__)
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

  it "defines Bundler gem build tasks" do
    expect(rake.lookup("build")).not_to be_nil
    expect(rake.lookup("release")).not_to be_nil
  end
end
