# frozen_string_literal: true

require "spec_helper"

RSpec.describe "table filter token search rendering" do
  let(:form_object_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :query
    end
  end

  let(:form_object) { form_object_class.new }
  let(:template) { ActionView::Base.empty }
  let(:form_builder) { ActionView::Helpers::FormBuilder.new(:search, form_object, template, {}) }
  let(:metadata_options) do
    {
      adapter: :ransack,
      param_name: :q,
      fields: {
        name: :name_cont,
        status: :status_eq
      },
      url: "/search_tokens.json",
      placeholder: "status:open keyword"
    }
  end
  let(:filter_metadata) do
    {
      field_type: "token_search",
      method: :query,
      options: metadata_options
    }
  end

  it "keeps adapter metadata in the call spec and exposes a rendered table filter contract" do
    call = RailsFieldsKit::TableRenderer.filter_call(filter_metadata)

    expect(call.fetch(:options)).to include(
      adapter: :ransack,
      param_name: :q,
      fields: {
        name: :name_cont,
        status: :status_eq
      }
    )

    html = RailsFieldsKit::TableRenderer.render_filter(form_builder, filter_metadata)

    expect(html).to include('data-rails-fields-kit--tom-select-url-value="/search_tokens.json"')
    expect(html).to include('data-rails-fields-kit-table-filter-adapter="ransack"')
    expect(html).to include('data-rails-fields-kit-table-filter-param-name="q"')
    expect(html).to include("data-rails-fields-kit-table-filter-fields=")
    expect(html).to include("&quot;name&quot;:&quot;name_cont&quot;")
    expect(html).to include("&quot;status&quot;:&quot;status_eq&quot;")
    expect(html).not_to match(/\sadapter=/)
    expect(html).not_to match(/\sparam_name=/)
    expect(html).not_to match(/\sfields=/)
  end

  it "does not leak adapter metadata when rfk_token_search is called directly" do
    html = form_builder.rfk_token_search(:query, **metadata_options)

    expect(html).to include('data-rails-fields-kit--tom-select-url-value="/search_tokens.json"')
    expect(html).not_to include("data-rails-fields-kit-table-filter-adapter")
    expect(html).not_to include("data-rails-fields-kit-table-filter-param-name")
    expect(html).not_to include("data-rails-fields-kit-table-filter-fields")
    expect(html).not_to match(/\sadapter=/)
    expect(html).not_to match(/\sparam_name=/)
    expect(html).not_to match(/\sfields=/)
  end
end
