# frozen_string_literal: true

require "spec_helper"

RSpec.describe "native FormBuilder helper public API inventory" do
  let(:form_builder_paths) do
    %w[
      form_builder.rb
      form_builder_file_field.rb
    ].map { |filename| File.expand_path("../lib/rails_fields_kit/#{filename}", __dir__) }
  end
  let(:form_builder_source) { form_builder_paths.map { |path| File.read(path) }.join("\n") }
  let(:public_api_path) { File.expand_path("../doc/public_api.md", __dir__) }
  let(:public_api) { File.read(public_api_path) }

  let(:landed_native_helpers) do
    form_builder_source.scan(/^    def (rfk_[a-z0-9_]+).*?\n(.*?)^    end/m).filter_map do |helper_name, body|
      helper_name if body.include?("rfk_native_field(")
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

  it "keeps proposal-only native helper names out of the current public API list" do
    proposal_only_helpers = %w[
      rfk_check_box
      rfk_checkbox
      rfk_color_field
      rfk_date_field
      rfk_datetime_local_field
      rfk_time_field
    ]

    expect(documented_native_helpers & proposal_only_helpers).to be_empty
  end
end
