# frozen_string_literal: true

RSpec.describe "RailsFieldsKit::FormBuilder#rfk_password_field" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  PasswordModel = Struct.new(:password) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "PasswordModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  PasswordErrorModel = Struct.new(:password) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "PasswordErrorModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end

    def errors
      { password: ["is too short"] }
    end
  end

  def protect_against_forgery?
    false
  end

  def form_builder(model = PasswordModel.new(nil), object_name = :password_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders a native password input" do
    html = form_builder.rfk_password_field(:password, autocomplete: "current-password")

    expect(html).to include("type=\"password\"")
    expect(html).to include("name=\"password_model[password]\"")
    expect(html).to include("autocomplete=\"current-password\"")
  end

  it "reuses the native wrapper label, hint, and accessibility contract" do
    html = form_builder.rfk_password_field(
      :password,
      wrapper: true,
      label: "Password",
      hint: "Use your account password",
      required: true
    )

    expect(html).to include("class=\"rfk-field\"")
    expect(html).to include("Password</label>")
    expect(html).to include("Use your account password")
    expect(html).to include("aria-describedby=\"password_model_password_hint\"")
    expect(html).to include("aria-required=\"true\"")
  end

  it "reuses native wrapper error wiring" do
    html = form_builder(PasswordErrorModel.new(nil), :password_error_model).rfk_password_field(
      :password,
      wrapper: true,
      label: "Password",
      hint: "At least 12 characters"
    )

    expect(html).to include("type=\"password\"")
    expect(html).to include("rfk-field--error")
    expect(html).to include("is too short")
    expect(html).to include("aria-invalid=\"true\"")
    expect(html).to include("password_error_model_password_hint password_error_model_password_error")
  end
end
