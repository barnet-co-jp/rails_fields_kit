# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table group helper docs drift" do
  let(:repo_root) { File.expand_path("../..", __dir__) }
  let(:form_builder_source) { File.read(File.join(repo_root, "lib/rails_fields_kit/form_builder_table_groups.rb")) }
  let(:public_api) { File.read(File.join(repo_root, "doc/public_api.md")) }
  let(:table_group_doc) { File.read(File.join(repo_root, "doc/table_group_html.md")) }

  it "keeps table group FormBuilder signatures visible in the public docs" do
    helper_signatures = table_group_helper_signatures

    expect(helper_signatures.keys).to eq(%w[rfk_table_filters rfk_table_cell_editors])

    helper_signatures.each do |helper_name, signature|
      expect(signature).to include("group_html:")
      expect(public_api).to include("`#{helper_name}(columns, group_html: ...)`")
      expect(table_group_doc).to include("`#{helper_name}(columns)`")
    end
  end

  it "keeps the group-level wrapper boundary separate from field-level wrappers" do
    expect(table_group_doc).to include(
      "`group_html:` is intentionally separate from field-level `wrapper_html:`",
      "one outer `<div>` around the joined batch output",
      "each rendered field keeps its own helper options and wrapper behavior"
    )

    expect(public_api).to include(
      "one outer group wrapper around the joined helper output",
      "`group_html:` is separate from field-level `wrapper_html:`"
    )
  end

  def table_group_helper_signatures
    form_builder_source
      .scan(/^    def (rfk_table_(?:filters|cell_editors))\(([^)]*)\)/)
      .to_h
  end
end
