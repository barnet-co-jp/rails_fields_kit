# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "setup doctor machine-readable docs guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:setup_doc) { read_doc("doc/setup.md") }
  let(:setup_doctor_doc) { read_doc("doc/setup_doctor.md") }
  let(:machine_readable_doc) { read_doc("doc/setup_doctor_machine_readable.md") }

  it "keeps the machine-readable guide packaged and routed without promoting a CI policy" do
    docs_map = markdown_section(readme, "## Docs map")

    expect(specification.files).to include("doc/setup_doctor_machine_readable.md")
    expect(docs_map).to include(
      "[`doc/setup_doctor_machine_readable.md`](doc/setup_doctor_machine_readable.md)",
      "structured JSON payloads"
    )
    expect(setup_doc).to include(
      "[`setup_doctor_machine_readable.md`](setup_doctor_machine_readable.md)",
      "RailsFieldsKit::SetupDoctor.new.run(io:, format: :json)",
      "without changing the text CLI output or promising a separate CLI `--json` contract"
    )
    expect(setup_doctor_doc).to include(
      "[`setup_doctor_machine_readable.md`](setup_doctor_machine_readable.md)",
      "schema_version",
      "summary",
      "checks",
      "without making the doctor an auto-fix tool, SARIF/JUnit emitter, or host-app CI pass/fail policy"
    )
    expect(machine_readable_doc).to include(
      "RailsFieldsKit::SetupDoctor.new.run(io: output, format: :json)",
      '"schema_version": 1',
      "`summary` counts and `checks` array are inspection data",
      "`manual` checks for review",
      "does not define a universal pass/fail policy"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?\s)/, 2).first
  end
end
