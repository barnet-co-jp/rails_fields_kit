# frozen_string_literal: true

RSpec.describe "rfk_grouped_select option metadata" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  GroupedSelectModel = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "GroupedSelectModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder(model = GroupedSelectModel.new("2"))
    ActionView::Helpers::FormBuilder.new(:grouped_select_model, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "passes disabled options and option html through grouped choices" do
    html = form_builder.rfk_grouped_select(
      :customer_id,
      grouped_collection: {
        "Active" => [["Acme Corp", "1"], ["Beta LLC", "2"]],
        "Archived" => [["Old Corp", "3"]]
      },
      disabled: ["3"],
      option_html: {
        "2" => { data: { tier: "preferred" }, class: "customer-option" }
      }
    )

    expect(html).to include("<optgroup label=\"Active\">")
    expect(html).to include("value=\"2\"")
    expect(html).to include("selected=\"selected\"")
    expect(html).to include("data-tier=\"preferred\"")
    expect(html).to include("class=\"customer-option\"")
    expect(html).to include("<optgroup label=\"Archived\">")
    expect(html).to include("value=\"3\" disabled=\"disabled\"").or include("disabled=\"disabled\" value=\"3\"")
  end

  it "keeps boolean disabled as the whole-select disabled contract" do
    html = form_builder.rfk_grouped_select(
      :customer_id,
      grouped_collection: {
        "Active" => [["Acme Corp", "1"]]
      },
      disabled: true
    )

    expect(html).to include("<select")
    expect(html).to include("disabled=\"disabled\"")
    expect(html).to include("<option value=\"1\">Acme Corp</option>")
  end
end
