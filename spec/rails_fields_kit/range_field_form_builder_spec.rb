# frozen_string_literal: true

RSpec.describe "RailsFieldsKit range field FormBuilder helper" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  RangeModel = Struct.new(:score) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "RangeModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end

    def errors
      { score: ["must be reviewed"] }
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder(model = RangeModel.new(50), object_name = :range_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders a native range input through the shared wrapper contract" do
    html = form_builder.rfk_range_field(
      :score,
      wrapper: true,
      label: "Score",
      hint: "Use the native slider only",
      min: 0,
      max: 100,
      step: 5,
      required: true,
      html: { data: { role: "score-range" } }
    )

    expect(html).to include("type=\"range\"")
    expect(html).to include("name=\"range_model[score]\"")
    expect(html).to include("min=\"0\"")
    expect(html).to include("max=\"100\"")
    expect(html).to include("step=\"5\"")
    expect(html).to include("data-role=\"score-range\"")
    expect(html).to include("class=\"rfk-field rfk-field--error\"")
    expect(html).to include("Score</label>")
    expect(html).to include("Use the native slider only")
    expect(html).to include("must be reviewed")
    expect(html).to include("aria-describedby=\"range_model_score_hint range_model_score_error\"")
    expect(html).to include("aria-invalid=\"true\"")
    expect(html).to include("aria-required=\"true\"")
  end
end
