# frozen_string_literal: true

require_relative "lib/rails_fields_kit/version"

Gem::Specification.new do |spec|
  spec.name = "rails_fields_kit"
  spec.version = RailsFieldsKit::VERSION
  spec.authors = ["Haruhito Matsuo"]
  spec.email = ["matsuo@scrumsoftware.co.jp"]

  spec.summary = "Rails form helpers for Tom Select fields, token search, native wrappers, and table metadata."
  spec.description = "Rails Fields Kit provides Rails-friendly form helpers centered on Tom Select-backed selects and comboboxes, with token search inputs, native wrapper helpers, and table-oriented metadata helpers for host-app owned workflows."
  spec.homepage = "https://github.com/barnet-co-jp/rails_fields_kit"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/barnet-co-jp"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "#{spec.homepage}/blob/main/doc/setup.md"

  spec.files = Dir.chdir(__dir__) do
    Dir[
      "{app,lib}/**/*",
      "config/locales/**/*.yml",
      "doc/**/*.md",
      "doc/**/*.html",
      "CHANGELOG.md",
      "LICENSE.txt",
      "README.md",
      "package.json"
    ].sort
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0", "< 9.0"

  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "standard", ">= 1.35.1"
end
