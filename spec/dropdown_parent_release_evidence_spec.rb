# frozen_string_literal: true

require "spec_helper"

RSpec.describe "dropdown_parent release evidence" do
  let(:form_builder_source) { repo_file("lib/rails_fields_kit/form_builder.rb") }
  let(:tom_select_controller_source) { repo_file("app/javascript/rails_fields_kit/tom_select_controller.js") }
  let(:release_evidence) { repo_file("doc/dropdown_parent_release_evidence.md") }

  it "keeps source evidence aligned with the documented release lanes" do
    expect(form_builder_source).to include("rfk_assign_data_value(data, :dropdown_parent")
    expect(tom_select_controller_source).to include("dropdownParent: String")
    expect(tom_select_controller_source).to include("options.dropdownParent = this.dropdownParentValue")
  end

  it "keeps the release evidence scoped to selector pass-through and host-app boundaries" do
    expect(release_evidence).to include(
      "dropdown_parent: \"body\"",
      "No-config boundary",
      "modal, drawer, or portal markup",
      "browser positioning, modal layout, portal implementation, z-index policy, or production CSS",
      "host-app responsibilities"
    )
  end

  def repo_file(relative_path)
    File.read(File.expand_path("../#{relative_path}", __dir__))
  end
end
