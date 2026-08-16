# frozen_string_literal: true

require "spec_helper"

RSpec.describe "FormBuilder error surface source" do
  let(:source) { File.read(File.expand_path("../../lib/rails_fields_kit/form_builder.rb", __dir__)) }

  it "wires an error surface id into tom select data values when requested" do
    expect(source).to include("rfk_assign_data_value(data, :error_surface_id, error_surface_id) if error_surface")
    expect(source).to include("rfk_apply_error_surface_accessibility!(html_options, error_surface_id) if error_surface")
  end

  it "derives a stable shared placeholder id from explicit HTML id or the object name and method" do
    expect(source).to include("def rfk_error_surface_id(method, error_surface_html = {})")
    expect(source).to include('explicit_id = error_surface_html[:id] || error_surface_html["id"]')
    expect(source).to include("return explicit_id unless explicit_id.nil? || explicit_id.to_s.empty?")
    expect(source).to include('"#{object_name}_#{method}_error_surface"')
  end

  it "appends the shared placeholder id into aria-describedby without duplication" do
    expect(source).to include('existing_described_by = html_options[:aria][:describedby] || html_options[:aria]["describedby"]')
    expect(source).to include('described_by = Array(existing_described_by.to_s.split(/\\s+/)).reject(&:empty?)')
    expect(source).to include('described_by << error_surface_id unless described_by.include?(error_surface_id)')
    expect(source).to include('html_options[:aria][:describedby] = described_by.join(" ")')
  end

  it "preserves the shared placeholder contract when host apps add custom HTML" do
    expect(source).to include("surface_options = error_surface_html.dup")
    expect(source).to include("surface_options[:id] = error_surface_id")
    expect(source).to include('surface_options.delete("id")')
    expect(source).to include('surface_options[:hidden] = true unless surface_options.key?(:hidden)')
    expect(source).to include('surface_options[:role] ||= "status"')
    expect(source).to include('surface_options[:"aria-live"] ||= "polite"')
    expect(source).to include('surface_options[:"aria-atomic"] = true unless surface_options.key?(:"aria-atomic")')
    expect(source).to include('surface_options[:class] = [surface_options[:class], "rfk-tom-select-error-surface"].compact.join(" ")')
  end
end
