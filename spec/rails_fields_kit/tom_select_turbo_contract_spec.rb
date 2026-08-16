# frozen_string_literal: true

require "cgi"

RSpec.describe "Tom Select Turbo reconnect contract" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  TurboContractModel = Struct.new(:customer_id, :tag_ids) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "TurboContractModel")
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

  def form_builder(model = TurboContractModel.new(1, [1, 2]), object_name = :turbo_contract_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  def controller_names(html)
    html[/data-controller="([^"]+)"/, 1].to_s.split
  end

  def action_names(html)
    CGI.unescapeHTML(html[/data-action="([^"]+)"/, 1].to_s).split
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "adds the Tom Select controller without replacing host app controllers" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected_url: "/customers/selected.json",
      create_url: "/customers",
      html: {
        data: {
          controller: "filters autosave",
          action: "change->filters#changed"
        }
      }
    )

    expect(controller_names(html)).to include("filters", "autosave", "rails-fields-kit--tom-select")
    expect(action_names(html)).to include("change->filters#changed")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/customers.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-selected-url-value=\"/customers/selected.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-url-value=\"/customers\"")
    expect(html).not_to include("turbo:load")
    expect(html).not_to include("setupTomSelectFields")
  end

  it "renders the same reconnect contract for multiple-value fields" do
    html = form_builder.rfk_tags(
      :tag_ids,
      url: "/tags.json",
      selected_url: "/tags/selected.json",
      selected_multiple_param: "tag_ids",
      html: {
        data: {
          controller: "tag-picker"
        }
      }
    )

    expect(controller_names(html)).to include("tag-picker", "rails-fields-kit--tom-select")
    expect(html).to include("multiple=\"multiple\"")
    expect(html).to include("data-rails-fields-kit--tom-select-selected-url-value=\"/tags/selected.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-selected-multiple-param-value=\"tag_ids\"")
    expect(html).not_to include("turbo:load")
  end
end
