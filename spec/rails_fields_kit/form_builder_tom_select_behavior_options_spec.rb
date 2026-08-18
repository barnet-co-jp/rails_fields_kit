# frozen_string_literal: true

RSpec.describe "RailsFieldsKit Tom Select behavior options" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  BehaviorOptionModel = Struct.new(:customer_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "BehaviorOptionModel")
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

  def form_builder
    ActionView::Helpers::FormBuilder.new(:behavior_option_model, BehaviorOptionModel.new(nil), self, {})
  end

  it "renders explicit Tom Select behavior options as Stimulus values" do
    html = form_builder.rfk_combobox(
      :customer_id,
      add_precedence: true,
      create_on_blur: true,
      clear_after_select: true
    )

    expect(html).to include('data-rails-fields-kit--tom-select-add-precedence-value="true"')
    expect(html).to include('data-rails-fields-kit--tom-select-create-on-blur-value="true"')
    expect(html).to include('data-rails-fields-kit--tom-select-clear-after-select-value="true"')
  end

  it "does not change free_text defaults implicitly" do
    html = form_builder.rfk_combobox(:customer_id, free_text: true)

    expect(html).not_to include("data-rails-fields-kit--tom-select-add-precedence-value")
    expect(html).not_to include("data-rails-fields-kit--tom-select-create-on-blur-value")
    expect(html).not_to include("data-rails-fields-kit--tom-select-clear-after-select-value")
  end
end
