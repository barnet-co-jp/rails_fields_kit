# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "bundled locale package contents" do
  let(:gemspec_path) { File.expand_path("../../rails_fields_kit.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }
  let(:form_builder_source) { File.read(File.expand_path("../../lib/rails_fields_kit/form_builder.rb", __dir__)) }

  it "ships the bundled Tom Select locale files used by Rails engine I18n lookup" do
    expect(specification.files).to include(
      "config/locales/en.yml",
      "config/locales/ja.yml"
    )
  end

  it "keeps bundled render text defaults aligned with locale keys" do
    locale_files = {
      "en" => File.expand_path("../../config/locales/en.yml", __dir__),
      "ja" => File.expand_path("../../config/locales/ja.yml", __dir__)
    }

    locale_files.each do |locale, path|
      translations = YAML.safe_load_file(path)
      tom_select = translations.fetch(locale).fetch("rails_fields_kit").fetch("tom_select")

      expect(tom_select.keys).to include(
        "no_results_text",
        "loading_text",
        "create_text"
      )
    end

    expect(form_builder_source).to include(
      "rails_fields_kit.tom_select.no_results_text",
      "rails_fields_kit.tom_select.loading_text",
      "rails_fields_kit.tom_select.create_text"
    )
  end
end
