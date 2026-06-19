# frozen_string_literal: true

require "spec_helper"

RSpec.describe "native file field FormBuilder helper" do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  FileFieldModel = Struct.new(:attachment) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "FileFieldModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  ErrorFileFieldModel = Struct.new(:attachment) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "ErrorFileFieldModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end

    def errors
      { attachment: ["is required"] }
    end
  end

  def protect_against_forgery?
    false
  end

  def file_form_builder(model = FileFieldModel.new, object_name = :file_field_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders a native file input and passes ordinary Rails file options through" do
    html = file_form_builder.rfk_file_field(
      :attachment,
      accept: "image/png,image/jpeg",
      multiple: true,
      html: { data: { role: "attachment-input" } }
    )

    expect(html).to include("type=\"file\"")
    expect(html).to include("accept=\"image/png,image/jpeg\"")
    expect(html).to include("multiple=\"multiple\"")
    expect(html).to include("data-role=\"attachment-input\"")
  end

  it "shares wrapper, hint, error, and accessibility wiring with other native helpers" do
    html = file_form_builder(ErrorFileFieldModel.new, :error_file_field_model).rfk_file_field(
      :attachment,
      wrapper: true,
      label: "Attachment",
      hint: "Upload one PDF",
      required: true,
      accept: "application/pdf"
    )

    expect(html).to include("class=\"rfk-field rfk-field--error\"")
    expect(html).to include("Attachment</label>")
    expect(html).to include("Upload one PDF")
    expect(html).to include("type=\"file\"")
    expect(html).to include("accept=\"application/pdf\"")
    expect(html).to include("aria-describedby=\"error_file_field_model_attachment_hint error_file_field_model_attachment_error\"")
    expect(html).to include("aria-invalid=\"true\"")
    expect(html).to include("aria-required=\"true\"")
    expect(html).to include("is required")
  end
end
