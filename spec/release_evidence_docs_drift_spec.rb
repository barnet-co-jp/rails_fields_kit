# frozen_string_literal: true

require "spec_helper"

RSpec.describe "release evidence documentation drift guards" do
  it "keeps token suggestion release evidence separate from query execution" do
    readme = read_repo_file("README.md")
    token_suggestions = read_repo_file("doc/token_suggestions.md")
    ransack_suggestions = read_repo_file("doc/ransack_suggestions.md")
    sample_app_checklist = read_repo_file("doc/sample_app_checklist.md")
    sample_app_results = read_repo_file("doc/sample_app_results.md")

    expect(readme).to include("doc/token_suggestions.md", "doc/ransack_suggestions.md")
    expect(sample_app_checklist).to include("Token suggestion and Ransack suggestion metadata")
    expect(sample_app_checklist).to include("rfk_token_suggestions_with(..., wrap: \"options\")")
    expect(sample_app_results).to include("Token suggestion and Ransack suggestion metadata checks")

    expect(token_suggestions).to include(
      "operator, field, predicate, value, and saved-search suggestions",
      "without moving query parsing or search execution into Rails Fields Kit",
      "value field: `RailsFieldsKit.configuration.default_value_field`, default `\"value\"`",
      "label field: `RailsFieldsKit.configuration.default_label_field`, default `\"text\"`",
      "description field: `RailsFieldsKit.configuration.default_option_description_field` or `\"description\"`",
      "badge field: `RailsFieldsKit.configuration.default_option_badge_field` or `\"badge\"`",
      "The submitted search text still belongs to the host application"
    )
    expect(ransack_suggestions).to include(
      "does not require the `ransack` gem and does not call `Model.ransack`",
      "the host application remains responsible for parsing the submitted token text",
      "`ransack_predicate`",
      "`ransack_field`",
      "`ransack_value`"
    )
  end

  it "keeps controller helper custom action docs aligned with source signatures" do
    searchable = read_repo_file("lib/rails_fields_kit/searchable.rb")
    controller_helpers = read_repo_file("doc/controller_helpers.md")
    public_api = read_repo_file("doc/public_api.md")

    helper_defaults = {
      "rfk_search_with" => "index",
      "rfk_find_with" => "show",
      "rfk_create_with" => "create",
      "rfk_token_suggestions_with" => "index"
    }

    helper_defaults.each do |helper_name, default_action|
      expect(searchable).to match(/def #{helper_name}\([^\n]*action: :#{default_action}/)
      expect(controller_helpers).to include(helper_name)
    end

    expect(controller_helpers).to include(
      "action:",
      "action: :selected",
      "action: :create_option",
      "action: :search_tokens"
    )
    expect(public_api).to include("Controller helpers", "action:")
  end

  it "keeps explicit error surface ids documented and discoverable by source guards" do
    events = read_repo_file("doc/events.md")
    sample_app_checklist = read_repo_file("doc/sample_app_checklist.md")
    sample_app_results = read_repo_file("doc/sample_app_results.md")
    index_js = read_repo_file("app/javascript/rails_fields_kit/index.js")

    expect(events).to include(
      "error_surface_html: { id:",
      "same object and method multiple times",
      "aria-describedby",
      "placeholder",
      "detail.surface"
    )
    expect(sample_app_checklist).to include("error_surface_html:", "event.detail.surface")
    expect(sample_app_results).to include("error_surface_html:", "event.detail.surface")
    expect(index_js).to include("errorSurfaceId", "readRenderedErrorSurface")
  end

  def read_repo_file(path)
    File.read(File.expand_path(path, File.expand_path("..", __dir__)))
  end
end
