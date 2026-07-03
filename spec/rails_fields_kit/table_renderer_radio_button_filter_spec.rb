# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableRenderer do
  class FakeRadioButtonFilterFormBuilder
    attr_reader :calls

    def initialize
      @calls = []
    end

    def rfk_radio_button(method, tag_value, **options)
      calls << [:rfk_radio_button, method, tag_value, options]
      "radio_button"
    end
  end

  around do |example|
    described_class.reset_field_helpers!
    example.run
    described_class.reset_field_helpers!
  end

  it "renders radio button filter metadata with tag_value as the positional value" do
    form_builder = FakeRadioButtonFilterFormBuilder.new
    metadata = RailsFieldsKit::TableFilterInput.radio_button(
      :status,
      tag_value: "published",
      label: "Published"
    )

    expect(described_class.render_filter(form_builder, metadata)).to eq("radio_button")
    expect(form_builder.calls).to eq([
      [:rfk_radio_button, :status, "published", {label: "Published"}]
    ])
  end

  it "raises when radio button filter metadata omits tag_value" do
    form_builder = FakeRadioButtonFilterFormBuilder.new
    metadata = RailsFieldsKit::TableFilterInput.radio_button(:status, label: "Published")

    expect { described_class.render_filter(form_builder, metadata) }.to raise_error(
      ArgumentError,
      "table radio button metadata tag_value is required"
    )
  end
end
