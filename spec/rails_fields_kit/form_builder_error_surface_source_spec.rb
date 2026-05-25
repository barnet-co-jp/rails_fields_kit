# frozen_string_literal: true

require "spec_helper"

RSpec.describe "FormBuilder error surface source" do
  let(:source) { File.read(File.expand_path("../../lib/rails_fields_kit/form_builder.rb", __dir__)) }

  it "wires an error surface id into tom select data values when requested" do
    expect(source).to include("rfk_assign_data_value(data, :error_surface_id, error_surface_id) if error_surface")
    expect(source).to include("rfk_apply_error_surface_accessibility!(html_options, error_surface_id) if error_surface")
  end

  it "renders a hidden polite status placeholder for host-app error UI" do
    expect(source).to include('surface_options[:hidden] = true unless surface_options.key?(:hidden)')
    expect(source).to include('surface_options[:role] ||= "status"')
    expect(source).to include('surface_options[:"aria-live"] ||= "polite"')
    expect(source).to include('surface_options[:class] = [surface_options[:class], "rfk-tom-select-error-surface"].compact.join(" ")')
  end
end
