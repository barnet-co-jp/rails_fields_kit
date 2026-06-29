# frozen_string_literal: true

require "spec_helper"

RSpec.describe "native FormBuilder helper public API inventory" do
  let(:form_builder_paths) do
    %w[
      form_builder.rb
      form_builder_check_box.rb
      form_builder_file_field.rb
      form_builder_native_date_time_fields.rb
      form_builder_radio_button.rb
    ].map { |filename| File.expand_path("../lib/rails_fields_kit/#{filename}", __dir__) }
  end
  let(:form_builder_source) { form_builder_paths.map { |path| File.read(path) }.join("\n") }
  let(:radio_button_source_path) { File.expand_path("../lib/rails_fields_kit/form_builder_radio_button.rb", __dir__) }
  let(:radio_button_source) { File.read(radio_button_source_path) }
  let(:radio_button_doc_path) { File.expand_path("../doc/radio_button.md", __dir__) }
  let(:radio_button_doc) { File.read(radio_button_doc_path) }
  let(:public_api_path) { File.expand_path("../doc/public_api.md", __dir__) }
  let(:public_api) { File.read(public_api_path) }

  let(:landed_native_helpers) do
    form_builder_source.scan(/^    def (rfk_[a-z0-9_]+).*?\n(.*?)^    end/m).filter_map do |helper_name, body|
      helper_name if body.include?("rfk_native_field(") || body.include?("check_box(method") || body.include?("radio_button(method")
    end.sort
  end

  let(:documented_native_helpers) do
    native_section = public_api.match(/^Native input helpers:\n\n(?<body>(?:- `rfk_[^`]+`\n)+)/)

    expect(native_section).not_to be_nil, "doc/public_api.md is missing the Native input helpers list"

    native_section[:body].scan(/`(rfk_[^`]+)`/).flatten.sort
  end

  it "keeps doc/public_api.md aligned with landed native helper definitions" do
    expect(documented_native_helpers).to eq(landed_native_helpers)
  end

  it "keeps the single-control radio helper tied to its focused source and docs" do
    expect(File.file?(radio_button_source_path)).to be(true)
    expect(File.file?(radio_button_doc_path)).to be(true)
    expect(radio_button_source).to include(
      "def rfk_radio_button(method, tag_value, **options)",
      "radio_button(method, tag_value, field_options)",
      "rfk_apply_radio_label_value!(tag_value, wrapper_options)"
    )
    expect(radio_button_doc).to include(
      "`rfk_radio_button` is the Rails Fields Kit native wrapper lane for one Rails radio input",
      "no collection radio group DSL",
      "no `fieldset` or `legend` builder"
    )
  end

  it "keeps proposal-only native helper aliases out of the current public API list" do
    proposal_only_helpers = %w[
      rfk_checkbox
      rfk_radio_buttons
      rfk_collection_radio_buttons
    ]

    expect(documented_native_helpers & proposal_only_helpers).to be_empty
  end
end
