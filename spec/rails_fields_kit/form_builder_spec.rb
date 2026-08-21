# frozen_string_literal: true

RSpec.describe RailsFieldsKit::FormBuilder do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  DummyModel = Struct.new(:status, :customer_id, :tag_ids, :keyword, :quantity, :amount, :rate, :email, :website_url, :phone, :product_id) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "DummyModel")
    end

    def self.statuses
      { "draft" => 0, "published" => 1 }
    end

    def self.human_attribute_name(attribute, options = {})
      translations = {
        "status.draft" => "Draft label",
        "status.published" => "Published label"
      }
      translations.fetch(attribute.to_s, options[:default] || attribute.to_s.humanize)
    end

    def persisted?
      false
    end

    def to_key
      nil
    end
  end

  ErrorModel = Struct.new(:status) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "ErrorModel")
    end

    def persisted?
      false
    end

    def to_key
      nil
    end

    def errors
      { status: ["is invalid"] }
    end
  end

  SelectedCustomer = Struct.new(:id, :name)
  CollectionCustomer = Struct.new(:uuid, :display_name)

  def protect_against_forgery?
    false
  end

  def form_builder(model = DummyModel.new("draft", nil, [], nil, 1, 1000, 10, "a@example.com", "https://example.com", "03-0000-0000"), object_name = :dummy_model)
    ActionView::Helpers::FormBuilder.new(object_name, model, self, {})
  end

  def with_available_locales(*locales)
    previous_available_locales = I18n.available_locales
    previous_load_path = I18n.load_path.dup
    locale_paths = locales.map { |locale| File.expand_path("../../config/locales/#{locale}.yml", __dir__) }
    I18n.load_path |= locale_paths
    I18n.reload!
    I18n.available_locales = (previous_available_locales + locales).uniq
    yield
  ensure
    I18n.load_path = previous_load_path
    I18n.available_locales = previous_available_locales
    I18n.reload!
  end

  around do |example|
    RailsFieldsKit.reset_configuration!
    example.run
    RailsFieldsKit.reset_configuration!
  end

  it "renders a Tom Select backed select field" do
    html = form_builder.rfk_select(:status, collection: { "Draft" => "draft" })

    expect(html).to include("select")
    expect(html).to include("rails-fields-kit--tom-select")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"select\"")
    expect(html).to include("data-rails-fields-kit--tom-select-value-field-value=\"value\"")
    expect(html).to include("data-rails-fields-kit--tom-select-label-field-value=\"text\"")
    expect(html).to include("data-rails-fields-kit--tom-select-no-results-text-value=\"No results found\"")
    expect(html).to include("data-rails-fields-kit--tom-select-loading-text-value=\"Loading...\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-text-value=\"Add\"")
    expect(html).to include("value=\"draft\"")
    expect(html).to include("selected=\"selected\"")
    expect(html).to include(">Draft</option>")
  end

  it "renders lookup text and selected id as separate Rails params" do
    model = DummyModel.new("draft", nil, [], "Custom item", 1, 1000, 10, "a@example.com", "https://example.com", "03-0000-0000", 42)
    html = form_builder(model).rfk_lookup(:keyword, id_field: :product_id, url: "/products.json")

    expect(html).to include('data-rails-fields-kit--tom-select-kind-value="lookup"')
    expect(html).to include('id="dummy_model_keyword_lookup"')
    expect(html).to include('name="dummy_model[keyword]"')
    expect(html).to include('value="Custom item"')
    expect(html).to include('name="dummy_model[product_id]"')
    expect(html).to include('value="42"')
    expect(html.scan('name="dummy_model[keyword]"').size).to eq(1)
  end

  it "renders declarative option metadata as escaped controller data" do
    html = form_builder.rfk_combobox(:customer_id, option_metadata_fields: [{field: "price", label: "Price"}])

    expect(html).to include("data-rails-fields-kit--tom-select-option-metadata-fields-value=")
    expect(html).to include("&quot;field&quot;:&quot;price&quot;")
  end

  it "renders grouped selects" do
    html = form_builder.rfk_grouped_select(
      :customer_id,
      grouped_collection: {
        "Active" => [["Acme Corp", "1"]],
        "Archived" => [["Old Corp", "2"]]
      }
    )

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"grouped_select\"")
    expect(html).to include("<optgroup label=\"Active\">")
    expect(html).to include("<option value=\"1\">Acme Corp</option>")
    expect(html).to include("<optgroup label=\"Archived\">")
    expect(html).to include("<option value=\"2\">Old Corp</option>")
  end

  it "renders disabled options and option html" do
    html = form_builder.rfk_select(
      :status,
      collection: { "Draft" => "draft", "Published" => "published" },
      disabled: ["published"],
      option_html: {
        "draft" => { data: { color: "gray" } }
      }
    )

    expect(html).to include("data-color=\"gray\"")
    expect(html).to include("value=\"published\" disabled=\"disabled\"").or include("disabled=\"disabled\" value=\"published\"")
  end

  it "renders custom Tom Select render options" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      max_options: 50,
      preload: true,
      no_results_text: "No customers",
      loading_text: "Searching...",
      create_text: "Create",
      option_description_field: "email",
      option_badge_field: "status"
    )

    expect(html).to include("data-rails-fields-kit--tom-select-max-options-value=\"50\"")
    expect(html).to include("data-rails-fields-kit--tom-select-preload-value=\"true\"")
    expect(html).to include("data-rails-fields-kit--tom-select-no-results-text-value=\"No customers\"")
    expect(html).to include("data-rails-fields-kit--tom-select-loading-text-value=\"Searching...\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-text-value=\"Create\"")
    expect(html).to include("data-rails-fields-kit--tom-select-option-description-field-value=\"email\"")
    expect(html).to include("data-rails-fields-kit--tom-select-option-badge-field-value=\"status\"")
  end

  it "uses bundled locale-aware render text defaults" do
    html = with_available_locales(:ja) do
      I18n.with_locale(:ja) do
        form_builder.rfk_combobox(:customer_id, url: "/customers.json")
      end
    end

    expect(html).to include("data-rails-fields-kit--tom-select-no-results-text-value=\"該当する項目はありません\"")
    expect(html).to include("data-rails-fields-kit--tom-select-loading-text-value=\"読み込み中...\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-text-value=\"追加\"")
  end

  it "prefers configured render text defaults over bundled locale copy" do
    RailsFieldsKit.configure do |config|
      config.default_no_results_text = "Nothing here"
      config.default_loading_text = "Searching..."
      config.default_create_text = "Create now"
    end

    html = with_available_locales(:ja) do
      I18n.with_locale(:ja) do
        form_builder.rfk_combobox(:customer_id, url: "/customers.json")
      end
    end

    expect(html).to include("data-rails-fields-kit--tom-select-no-results-text-value=\"Nothing here\"")
    expect(html).to include("data-rails-fields-kit--tom-select-loading-text-value=\"Searching...\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-text-value=\"Create now\"")
  end

  it "prefers field-level render text over configured defaults" do
    RailsFieldsKit.configure do |config|
      config.default_no_results_text = "Nothing here"
      config.default_loading_text = "Searching..."
      config.default_create_text = "Create now"
    end

    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      no_results_text: "No customers",
      loading_text: "Loading customers",
      create_text: "Add customer"
    )

    expect(html).to include("data-rails-fields-kit--tom-select-no-results-text-value=\"No customers\"")
    expect(html).to include("data-rails-fields-kit--tom-select-loading-text-value=\"Loading customers\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-text-value=\"Add customer\"")
  end

  it "renders extra remote query params" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected_url: "/customers/selected.json",
      create_url: "/customers",
      query_params: { scope: "active" },
      selected_query_params: { scope: "active" },
      create_params: { source: "inline" }
    )

    expect(html).to include("data-rails-fields-kit--tom-select-query-params-value=\"{&quot;scope&quot;:&quot;active&quot;}\"")
    expect(html).to include("data-rails-fields-kit--tom-select-selected-query-params-value=\"{&quot;scope&quot;:&quot;active&quot;}\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-params-value=\"{&quot;source&quot;:&quot;inline&quot;}\"")
  end

  it "renders a clearable select" do
    html = form_builder.rfk_select(:status, collection: { "Draft" => "draft" }, allow_clear: true)

    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;clear_button&quot;]\"")
  end

  it "preserves explicit plugins when allow_clear is enabled" do
    html = form_builder.rfk_select(
      :status,
      collection: { "Draft" => "draft" },
      plugins: ["dropdown_input"],
      allow_clear: true
    )

    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;dropdown_input&quot;,&quot;clear_button&quot;]\"")
  end

  it "renders object collections with collection methods" do
    customers = [CollectionCustomer.new("c-1", "Acme Corp")]

    html = form_builder.rfk_select(
      :customer_id,
      collection: customers,
      collection_value_method: :uuid,
      collection_label_method: :display_name
    )

    expect(html).to include("value=\"c-1\"")
    expect(html).to include(">Acme Corp</option>")
  end

  it "keeps the documented rfk_select migration contract" do
    customers = [
      CollectionCustomer.new("c-1", "Acme Corp"),
      CollectionCustomer.new("c-2", "Beta LLC")
    ]
    model = DummyModel.new("draft", "c-2", [], nil, 1, 1000, 10, "a@example.com", "https://example.com", "03-0000-0000")

    html = form_builder(model, :document_set).rfk_select(
      :customer_id,
      collection: customers,
      collection_value_method: :uuid,
      collection_label_method: :display_name,
      include_blank: "Select an owner",
      disabled: ["c-1"],
      option_html: {
        "c-2" => { data: { migration: "kept" } }
      }
    )

    expect(html).to include("name=\"document_set[customer_id]\"")
    expect(html).to include("<option value=\"\">Select an owner</option>")
    expect(html).to include("value=\"c-2\"")
    expect(html).to include("selected=\"selected\"")
    expect(html).to include("data-migration=\"kept\"")
    expect(html).to include(">Beta LLC</option>")
    expect(html).to include("value=\"c-1\" disabled=\"disabled\"").or include("disabled=\"disabled\" value=\"c-1\"")
  end

  it "keeps representative grouped options in the migration lane" do
    html = form_builder(DummyModel.new("draft", "2", [], nil, 1, 1000, 10, "a@example.com", "https://example.com", "03-0000-0000"), :document_set).rfk_grouped_select(
      :customer_id,
      grouped_collection: {
        "Active" => [["Acme Corp", "1"]],
        "Archived" => [["Beta LLC", "2"]]
      },
      include_blank: "Select an owner"
    )

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"grouped_select\"")
    expect(html).to include("<option value=\"\">Select an owner</option>")
    expect(html).to include("<optgroup label=\"Active\">")
    expect(html).to include("<optgroup label=\"Archived\">")
    expect(html).to include("value=\"2\"")
    expect(html).to include(">Beta LLC</option>")
  end

  it "keeps grouped select selected and disabled option boundaries" do
    html = form_builder(DummyModel.new("draft", "2", [], nil, 1, 1000, 10, "a@example.com", "https://example.com", "03-0000-0000"), :document_set).rfk_grouped_select(
      :customer_id,
      grouped_collection: {
        "Active" => [["Acme Corp", "1"]],
        "Archived" => [["Beta LLC", "2"], ["Old Corp", "3"]]
      },
      selected: "2",
      disabled: ["3"],
      include_blank: "Select an owner"
    )

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"grouped_select\"")
    expect(html).to include("<option value=\"\">Select an owner</option>")
    expect(html).to include("value=\"2\" selected=\"selected\"").or include("selected=\"selected\" value=\"2\"")
    expect(html).to include("value=\"3\" disabled=\"disabled\"").or include("disabled=\"disabled\" value=\"3\"")
  end

  it "keeps grouped select boolean disabled as a whole-field state" do
    html = form_builder.rfk_grouped_select(
      :customer_id,
      grouped_collection: {
        "Active" => [["Acme Corp", "1"]],
        "Archived" => [["Old Corp", "2"]]
      },
      disabled: true
    )

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"grouped_select\"")
    expect(html).to include("<select")
    expect(html).to include("disabled=\"disabled\"")
    expect(html).to include("<option value=\"1\">Acme Corp</option>")
  end

  it "renders enum selects" do
    html = form_builder.rfk_enum_select(:status)

    expect(html).to include("value=\"draft\"")
    expect(html).to include(">Draft label</option>")
    expect(html).to include("value=\"published\"")
    expect(html).to include(">Published label</option>")
  end

  it "renders a remote editable combobox" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      create_url: "/customers",
      placeholder: "Search or create a customer",
      query_param: "keyword",
      create_param: "name",
      value_field: "id",
      label_field: "name",
      search_field: "name,email",
      min_length: 2
    )

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"combobox\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/customers.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-url-value=\"/customers\"")
    expect(html).to include("data-rails-fields-kit--tom-select-query-param-value=\"keyword\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-param-value=\"name\"")
    expect(html).to include("data-rails-fields-kit--tom-select-value-field-value=\"id\"")
    expect(html).to include("data-rails-fields-kit--tom-select-label-field-value=\"name\"")
    expect(html).to include("data-rails-fields-kit--tom-select-search-field-value=\"name,email\"")
    expect(html).to include("data-rails-fields-kit--tom-select-min-length-value=\"2\"")
    expect(html).to include("placeholder=\"Search or create a customer\"")
  end

  it "keeps shared placeholder contract for custom error surfaces" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      error_surface: true,
      error_surface_html: {
        class: "field-error",
        data: { lane: "selected-preload" }
      }
    )
    plain_html = form_builder.rfk_combobox(:customer_id, url: "/customers.json")

    expect(html).to include("data-rails-fields-kit--tom-select-error-surface-id-value=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("aria-describedby=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("id=\"dummy_model_customer_id_error_surface\"")
    expect(html).to include("hidden=\"hidden\"")
    expect(html).to include("role=\"status\"")
    expect(html).to include("aria-live=\"polite\"")
    expect(html).to include("aria-atomic=\"true\"")
    expect(html).to include("data-lane=\"selected-preload\"")
    expect(html).to include("class=\"field-error rfk-tom-select-error-surface\"").or include("class=\"rfk-tom-select-error-surface field-error\"")
    expect(plain_html).not_to include("dummy_model_customer_id_error_surface")
  end

  it "keeps generated native hint ids tied to object name and method" do
    first_html = form_builder.rfk_text_field(:keyword, wrapper: true, hint: "First hint")
    second_html = form_builder.rfk_text_field(:keyword, wrapper: true, hint: "Second hint")
    combined_html = "#{first_html}#{second_html}"

    expect(first_html).to include("aria-describedby=\"dummy_model_keyword_hint\"")
    expect(first_html).to include("id=\"dummy_model_keyword_hint\"")
    expect(combined_html.scan("id=\"dummy_model_keyword_hint\"").size).to eq(2)
    expect(combined_html.scan("aria-describedby=\"dummy_model_keyword_hint\"").size).to eq(2)
  end

  it "keeps custom input ids separate from generated hint ids" do
    html = form_builder.rfk_text_field(
      :keyword,
      wrapper: true,
      hint: "Host app hint",
      html: {
        id: "custom_keyword_input",
        aria: { describedby: "host_hint" }
      }
    )

    expect(html).to include("id=\"custom_keyword_input\"")
    expect(html).to include("aria-describedby=\"host_hint dummy_model_keyword_hint\"")
    expect(html).to include("id=\"dummy_model_keyword_hint\"")
  end

  it "uses explicit error surface ids for Tom Select describedby wiring" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      error_surface: true,
      error_surface_html: { id: "customer_lookup_error_surface" },
      html: { aria: { describedby: "host_help" } }
    )

    expect(html).to include("data-rails-fields-kit--tom-select-error-surface-id-value=\"customer_lookup_error_surface\"")
    expect(html).to include("aria-describedby=\"host_help customer_lookup_error_surface\"")
    expect(html).to include("id=\"customer_lookup_error_surface\"")
  end

  it "renders a token search text input" do
    html = form_builder.rfk_token_search(
      :keyword,
      url: "/search_suggestions.json",
      placeholder: "status:open keyword",
      max_items: 20,
      load_throttle: 250
    )

    expect(html).to include("type=\"text\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"token_search\"")
    expect(html).to include("data-rails-fields-kit--tom-select-free-text-value=\"true\"")
    expect(html).to include("data-rails-fields-kit--tom-select-create-value=\"true\"")
    expect(html).to include("data-rails-fields-kit--tom-select-persist-value=\"false\"")
    expect(html).to include("data-rails-fields-kit--tom-select-delimiter-value=\" \"")
    expect(html).to include("data-rails-fields-kit--tom-select-max-items-value=\"20\"")
    expect(html).to include("data-rails-fields-kit--tom-select-load-throttle-value=\"250\"")
    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;remove_button&quot;]\"")
  end

  it "preloads a selected option from a hash" do
    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected: { value: 10, text: "Acme Corp" }
    )

    expect(html).to include("<option selected=\"selected\" value=\"10\">Acme Corp</option>")
  end

  it "preloads a selected option from an object" do
    customer = SelectedCustomer.new(20, "Beta LLC")

    html = form_builder.rfk_combobox(
      :customer_id,
      url: "/customers.json",
      selected: customer,
      value_method: :id,
      label_method: :name
    )

    expect(html).to include("<option selected=\"selected\" value=\"20\">Beta LLC</option>")
  end

  it "preloads multiple selected options without duplicating collection entries" do
    html = form_builder.rfk_tags(
      :tag_ids,
      collection: [["Urgent", 1]],
      selected: [
        { value: 1, text: "Urgent" },
        { value: 2, text: "Backlog" }
      ]
    )

    expect(html).to include("<option selected=\"selected\" value=\"2\">Backlog</option>")
    expect(html.scan("value=\"1\"").size).to eq(1)
  end

  it "renders tags as a multiple select with remove buttons" do
    html = form_builder.rfk_tags(:tag_ids, collection: [["Urgent", 1]])

    expect(html).to include("multiple=\"multiple\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"tags\"")
    expect(html).to include("data-rails-fields-kit--tom-select-plugins-value=\"[&quot;remove_button&quot;]\"")
  end

  it "renders autocomplete as a free text field" do
    html = form_builder.rfk_autocomplete(:keyword, url: "/suggestions.json")

    expect(html).to include("type=\"text\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"autocomplete\"")
    expect(html).to include("data-rails-fields-kit--tom-select-free-text-value=\"true\"")
  end

  it "renders native text fields with wrappers" do
    html = form_builder.rfk_text_field(:keyword, wrapper: true, label: "Keyword", hint: "Free text search")

    expect(html).to include("type=\"text\"")
    expect(html).to include("class=\"rfk-field\"")
    expect(html).to include("class=\"rfk-label\"")
    expect(html).to include("Keyword</label>")
    expect(html).to include("class=\"rfk-hint\"")
    expect(html).to include("Free text search")
  end

  it "renders native text areas" do
    html = form_builder.rfk_text_area(:keyword, wrapper: true)

    expect(html).to include("<textarea")
    expect(html).to include("class=\"rfk-field\"")
  end

  it "renders native number fields" do
    html = form_builder.rfk_number_field(:quantity, min: 1, step: 1)

    expect(html).to include("type=\"number\"")
    expect(html).to include("min=\"1\"")
    expect(html).to include("step=\"1\"")
  end

  it "renders money fields with a currency prefix" do
    html = form_builder.rfk_money_field(:amount, currency: "JPY", wrapper: true)

    expect(html).to include("inputmode=\"decimal\"")
    expect(html).to include("class=\"rfk-control\"")
    expect(html).to include("class=\"rfk-prefix\"")
    expect(html).to include(">JPY</span>")
  end

  it "renders percent fields with a suffix" do
    html = form_builder.rfk_percent_field(:rate, wrapper: true)

    expect(html).to include("type=\"number\"")
    expect(html).to include("inputmode=\"decimal\"")
    expect(html).to include("class=\"rfk-suffix\"")
    expect(html).to include(">%</span>")
  end

  it "renders email, url, phone, and search fields" do
    expect(form_builder.rfk_email_field(:email)).to include("type=\"email\"")
    expect(form_builder.rfk_url_field(:website_url)).to include("type=\"url\"")
    expect(form_builder.rfk_phone_field(:phone)).to include("type=\"tel\"")
    expect(form_builder.rfk_phone_field(:phone)).to include("autocomplete=\"tel\"")
    expect(form_builder.rfk_search_field(:keyword)).to include("type=\"search\"")
  end

  it "renders table metadata filters" do
    html = form_builder.rfk_table_filters([
      {
        filter: RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: "/customers.json")
      },
      {
        search_filter: RailsFieldsKit::TableFilterInput.token_search(:keyword, url: "/tokens.json")
      }
    ])

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"combobox\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/customers.json\"")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"token_search\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/tokens.json\"")
  end

  it "renders table metadata cell editors" do
    html = form_builder.rfk_table_cell_editors([
      {
        editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
      },
      {
        cell_editor: RailsFieldsKit::TableCellInput.new(:combobox, :customer_id, url: "/customers.json")
      }
    ])

    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"select\"")
    expect(html).to include(">Draft label</option>")
    expect(html).to include("data-rails-fields-kit--tom-select-kind-value=\"combobox\"")
    expect(html).to include("data-rails-fields-kit--tom-select-url-value=\"/customers.json\"")
  end

  it "wraps a field with label and hint when requested" do
    html = form_builder.rfk_select(
      :status,
      collection: { "Draft" => "draft" },
      wrapper: true,
      label: "Status",
      hint: "Choose the workflow status"
    )

    expect(html).to include("class=\"rfk-field\"")
    expect(html).to include("class=\"rfk-label\"")
    expect(html).to include("Status</label>")
    expect(html).to include("class=\"rfk-hint\"")
    expect(html).to include("Choose the workflow status")
  end

  it "renders errors in wrapped fields" do
    html = form_builder(ErrorModel.new("bad"), :error_model).rfk_select(
      :status,
      collection: { "Bad" => "bad" },
      wrapper: true
    )

    expect(html).to include("rfk-field--error")
    expect(html).to include("class=\"rfk-error\"")
    expect(html).to include("is invalid")
  end

  it "uses configured defaults" do
    RailsFieldsKit.configure do |config|
      config.default_query_param = "term"
      config.default_min_length = 3
      config.default_load_throttle = 250
      config.default_no_results_text = "Nothing here"
    end

    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json")

    expect(html).to include("data-rails-fields-kit--tom-select-query-param-value=\"term\"")
    expect(html).to include("data-rails-fields-kit--tom-select-min-length-value=\"3\"")
    expect(html).to include("data-rails-fields-kit--tom-select-load-throttle-value=\"250\"")
    expect(html).to include("data-rails-fields-kit--tom-select-no-results-text-value=\"Nothing here\"")
  end

  it "prefers field-level load throttle over the configured default" do
    RailsFieldsKit.configure do |config|
      config.default_load_throttle = 250
    end

    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json", load_throttle: 100)

    expect(html).to include("data-rails-fields-kit--tom-select-load-throttle-value=\"100\"")
    expect(html).not_to include("data-rails-fields-kit--tom-select-load-throttle-value=\"250\"")
  end

  it "omits load throttle when neither helper nor configuration sets it" do
    html = form_builder.rfk_combobox(:customer_id, url: "/customers.json")

    expect(html).not_to include("data-rails-fields-kit--tom-select-load-throttle-value")
  end
end
