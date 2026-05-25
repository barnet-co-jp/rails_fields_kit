# frozen_string_literal: true

require "spec_helper"

RSpec.describe "rfk_token_search defaults source" do
  let(:source) { File.read(File.expand_path("../lib/rails_fields_kit/form_builder.rb", __dir__)) }

  it "defaults token search to a text input with free-text creation" do
    expect(source).to include("options[:as] = :text unless options.key?(:as)")
    expect(source).to include("options[:free_text] = true unless options.key?(:free_text)")
    expect(source).to include("options[:create] = true unless options.key?(:create)")
  end

  it "keeps created token options ephemeral by default" do
    expect(source).to include("options[:persist] = false unless options.key?(:persist)")
  end

  it "separates tokens on spaces by default" do
    expect(source).to include('options[:delimiter] = " " unless options.key?(:delimiter)')
  end

  it "adds the remove_button plugin unless plugins are provided explicitly" do
    expect(source).to include('options[:plugins] = Array(options[:plugins]) | ["remove_button"] unless options.key?(:plugins)')
  end
end
