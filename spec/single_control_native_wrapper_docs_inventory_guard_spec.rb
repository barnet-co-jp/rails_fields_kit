# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "single-control native wrapper focused docs inventory" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:field_helpers) { read_doc("doc/field_helpers.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:check_box) { read_doc("doc/check_box.md") }
  let(:radio_button) { read_doc("doc/radio_button.md") }
  let(:file_field) { read_doc("doc/file_field.md") }

  it "keeps single-control native wrapper focused docs packaged and discoverable" do
    expect(specification.files).to include(
      "doc/check_box.md",
      "doc/radio_button.md",
      "doc/file_field.md"
    )

    expect(readme).to include(
      "[`doc/field_helpers.md`](doc/field_helpers.md)",
      "[`doc/public_api.md`](doc/public_api.md#formbuilder-helpers)",
      "Use this map as a first reader route, not a full documentation inventory"
    )

    expect(field_helpers).to include(
      "[`check_box.md`](check_box.md)",
      "[`radio_button.md`](radio_button.md)",
      "[`file_field.md`](file_field.md)"
    )

    expect(public_api).to include(
      "[`check_box.md`](check_box.md)",
      "[`radio_button.md`](radio_button.md)",
      "[`file_field.md`](file_field.md)",
      "`rfk_check_box`",
      "`rfk_radio_button`",
      "`rfk_file_field`"
    )
  end

  it "keeps checkbox, radio, and file focused docs scoped to Rails-native contracts" do
    expect(check_box).to include(
      "Rails' standard `check_box` helper",
      "the hidden unchecked field stays enabled by default",
      "`checked_value:` and `unchecked_value:` are passed to Rails' helper",
      "no collection checkbox or radio group DSL",
      "no replacement for Rails hidden-field behavior"
    )

    expect(radio_button).to include(
      "Rails' standard `radio_button` helper",
      "the `tag_value` argument is passed to Rails as the radio value",
      "multiple radio buttons for the same method keep the same input name and different ids",
      "no collection radio group DSL",
      "no `fieldset` or `legend` builder"
    )

    expect(file_field).to include(
      "Rails' native `file_field` helper",
      "multipart form setup",
      "Active Storage direct upload behavior",
      "file preview UI",
      "Rails Fields Kit does not add upload JavaScript or replace Rails' file upload workflow"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
