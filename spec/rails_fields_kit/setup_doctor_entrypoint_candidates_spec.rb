# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"

RSpec.describe RailsFieldsKit::SetupDoctor, "entrypoint candidates" do
  def write_file(root, path, content = "")
    absolute_path = File.join(root, path)
    FileUtils.mkdir_p(File.dirname(absolute_path))
    File.write(absolute_path, content)
  end

  def check_for(doctor, key)
    doctor.checks.find { |check| check.key == key }
  end

  it "detects Stimulus registration from JSX and TSX entrypoints" do
    {
      "app/javascript/entrypoints/application.jsx" => "application.jsx",
      "app/javascript/entrypoints/application.tsx" => "application.tsx",
      "app/frontend/entrypoints/application.jsx" => "application.jsx"
    }.each do |entrypoint_path, filename|
      Dir.mktmpdir do |root|
        write_file(root, entrypoint_path, <<~JS)
          import { application } from "controllers/application"
          import { TomSelectController } from "rails_fields_kit"

          application.register("rails-fields-kit--tom-select", TomSelectController)
        JS

        stimulus_check = check_for(described_class.new(root: root), :stimulus_registration)

        expect(stimulus_check.status).to eq(:ok)
        expect(stimulus_check.message).to include("Found Rails Fields Kit Stimulus registration signal in #{entrypoint_path}")
        expect(stimulus_check.message).to include("Stimulus boot policy stays with the host app")
        expect(entrypoint_path).to end_with(filename)
      end
    end
  end

  it "detects Tom Select CSS imports from JSX and TSX entrypoints" do
    {
      "app/javascript/entrypoints/application.jsx" => "application.jsx",
      "app/javascript/entrypoints/application.tsx" => "application.tsx",
      "app/frontend/entrypoints/application.jsx" => "application.jsx"
    }.each do |entrypoint_path, filename|
      Dir.mktmpdir do |root|
        write_file(root, entrypoint_path, <<~JS)
          import "tom-select/dist/css/tom-select.css"
        JS

        css_check = check_for(described_class.new(root: root), :css_import)

        expect(css_check.status).to eq(:ok)
        expect(css_check.message).to include("Found Tom Select CSS import signal in #{entrypoint_path}")
        expect(css_check.message).to include("stylesheet pipeline and theme policy stay with the host app")
        expect(entrypoint_path).to end_with(filename)
      end
    end
  end
end
