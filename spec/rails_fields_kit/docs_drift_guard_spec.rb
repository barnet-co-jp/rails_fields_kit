# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "Rails Fields Kit docs drift guards" do
  let(:repo_root) { File.expand_path("../..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(repo_root, "rails_fields_kit.gemspec")) }

  def read_repo_file(relative_path)
    File.read(File.join(repo_root, relative_path))
  end

  it "keeps generated setup notes pointed at setup doctor output review evidence" do
    generated_setup_note = read_repo_file("lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md")

    expect(generated_setup_note).to include(
      "Run `rails rails_fields_kit:doctor` after installation",
      "use the upstream setup doctor output review",
      "Setup doctor output review: <https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/doc/setup_doctor_output_review.md>"
    )
  end

  it "keeps the table group FormBuilder split implementation discoverable" do
    table_group_docs = read_repo_file("doc/table_group_html.md")
    table_group_source = read_repo_file("lib/rails_fields_kit/form_builder_table_groups.rb")

    expect(specification.files).to include(
      "doc/table_group_html.md",
      "lib/rails_fields_kit/form_builder_table_groups.rb"
    )

    expect(table_group_source).to include(
      "def rfk_table_filters(columns, group_html: nil)",
      "def rfk_table_cell_editors(columns, group_html: nil)",
      "RailsFieldsKit::TableMetadata.render_filters",
      "RailsFieldsKit::TableMetadata.render_cell_editors"
    )

    expect(table_group_docs).to include(
      "`lib/rails_fields_kit/form_builder_table_groups.rb`",
      "`RailsFieldsKit::FormBuilder`",
      "Check that split definition before treating the older base helper file as the complete table helper surface."
    )
  end
end
