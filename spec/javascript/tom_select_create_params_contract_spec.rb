# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Tom Select create params contract" do
  let(:source) { File.read(File.expand_path("../../app/javascript/rails_fields_kit/tom_select_controller.js", __dir__)) }
  let(:create_option_source) { source[/  createOption\(input, callback\) \{.*?^  \}/m] }

  it "submits create_params as fixed JSON body fields with the created input" do
    expect(create_option_source).to include("fetch(this.createUrlValue, this.requestOptions({")
    expect(create_option_source).to include('method: "POST"')
    expect(create_option_source).to include("headers: this.createRequestHeaders()")
    expect(create_option_source).to include("body: JSON.stringify({ ...this.createParamsValue, [this.createParamValue]: input })")
  end

  it "keeps create request params separate from URL query serialization" do
    expect(create_option_source).not_to include("new URL(")
    expect(create_option_source).not_to include("appendParams")
    expect(create_option_source).not_to include("URLSearchParams")
  end

  it "keeps the successful create event focused on the input and created option" do
    expect(create_option_source).to include('this.dispatch("create", { detail: { input, option } })')
  end
end
