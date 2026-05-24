# frozen_string_literal: true

require_relative "lib/rails_fields_kit/version"

Gem::Specification.new do |spec|
  spec.name = "rails_fields_kit"
  spec.version = RailsFieldsKit::VERSION
  spec.authors = ["Haruhito Matsuo"]
  spec.email = ["matsuo@scrumsoftware.co.jp"]

  spec.summary = "Rails form helpers for searchable selects, editable comboboxes, tags, and autocomplete."
  spec.description = "Rails Fields Kit provides Rails-friendly field helpers for form inputs that native HTML and Rails helpers still make awkward, starting with Tom Select powered editable comboboxes."
  spec.homepage = "https://github.com/matsuo-haruhito/rails_fields_kit"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "#{spec.homepage}/blob/main/doc/setup.md"

  spec.files = Dir.chdir(__dir__) do
    Dir[
      "{app,lib}/**/*",
      "doc/**/*.md",
      "CHANGELOG.md",
      "LICENSE.txt",
      "README.md",
      "package.json"
    ].sort
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0", "< 9.0"

  spec.add_development_dependency "rspec", "~> 3.13"
end
