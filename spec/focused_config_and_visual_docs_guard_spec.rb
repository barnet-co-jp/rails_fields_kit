# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "focused configuration and visual docs inventory guard" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:readme) { read_doc("README.md") }
  let(:product_profile) { read_doc("Product Profile.md") }
  let(:public_api) { read_doc("doc/public_api.md") }
  let(:configuration) { read_doc("doc/configuration.md") }
  let(:field_helpers) { read_doc("doc/field_helpers.md") }
  let(:controller_helpers) { read_doc("doc/controller_helpers.md") }
  let(:visual_references) { read_doc("doc/visual_references.md") }
  let(:default_allow_clear) { read_doc("doc/default_allow_clear.md") }
  let(:tom_select_source_fallback_review) { read_doc("doc/tom_select_source_fallback_review.html") }
  let(:native_accessibility_contract_visual_reference) { read_doc("doc/native_accessibility_contract_visual_reference.html") }

  it "keeps the default_allow_clear focused guide packaged and routed without taking over plugin behavior" do
    expect(specification.files).to include("doc/default_allow_clear.md")

    expect(readme).to include(
      "[`doc/default_allow_clear.md`](doc/default_allow_clear.md)",
      "app-wide clear-button default",
      "wrapper classes and host-app CSS ownership"
    )
    expect(public_api).to include(
      "Configuration attributes are documented in [`configuration.md`](configuration.md)",
      "Tom Select interaction attributes include `default_allow_clear`",
      "use [`default_allow_clear.md`](default_allow_clear.md) for focused examples and non-goals"
    )
    expect(configuration).to include(
      "`default_allow_clear`",
      "Adds `clear_button` when a helper omits `allow_clear:` and the app-wide default is enabled",
      "Field-level `allow_clear:` replaces this initializer default for that one helper",
      "`default_plugins` remains the raw Tom Select plugin pass-through",
      "does not install Tom Select plugins, import plugin-specific assets, define styling, or own plugin lifecycle behavior"
    )
    expect(field_helpers).to include(
      "Use [`default_allow_clear.md`](default_allow_clear.md) for app-wide clear-button default examples",
      "raw `plugins:` / `default_plugins` pass-through"
    )

    expect(default_allow_clear).to include(
      "app-wide semantic default",
      "Field-level `allow_clear:` is the semantic override for one helper render",
      "`allow_clear: false` only suppresses Rails Fields Kit's semantic auto-add",
      "`default_plugins` remains a raw Tom Select plugin pass-through",
      "does not add production CSS, theme presets, Tom Select plugin assets, clear-button wording, empty-state copy, or JavaScript lifecycle behavior"
    )
  end

  it "keeps the Tom Select source fallback review packaged and mapped without changing enum or endpoint policy" do
    expect(specification.files).to include("doc/tom_select_source_fallback_review.html")

    expect(visual_references).to include(
      "[`tom_select_source_fallback_review.html`](tom_select_source_fallback_review.html)",
      "explicit-source or remote option label-fallback review",
      "model enum source vs explicit `enum:` source",
      "display-only fallback",
      "not a new API or endpoint behavior spec"
    )
    expect(controller_helpers).to include(
      "### Remote option label fallback",
      "This fallback is display-only",
      "It does not change the submitted value, option payload, endpoint response shape, authorization boundary, or request lifecycle"
    )

    expect(tom_select_source_fallback_review).to include(
      "Tom Select Source and Fallback Review",
      "Compare labels, submitted keys, placeholder copy, selected state, and disabled option readability only",
      "Do not treat this page as a new helper API, renderer change, enum translation policy, validation policy, authorization rule, or endpoint validation proposal",
      "Explicit <code>enum:</code> hash",
      "Remote label missing",
      "Display-only fallback when a remote option is missing the configured label field or returns an empty label",
      "This companion artifact supplements the existing Tom Select core reference without changing production helper markup or runtime JavaScript"
    )
  end

  it "keeps the native accessibility contract reader artifact packaged and discoverable without changing runtime behavior" do
    expect(specification.files).to include("doc/native_accessibility_contract_visual_reference.html")

    expect(visual_references).to include(
      "[`native_accessibility_contract_visual_reference.html`](native_accessibility_contract_visual_reference.html)",
      "Focused native helper accessibility contract reader lanes",
      "Can reviewers inspect the current rendered accessibility contract without treating future return-shape proposals, id generation, validation messages, or focus management as current public behavior?"
    )
    expect(product_profile).to include(
      "`doc/native_accessibility_contract_visual_reference.html`: static visual reference for focused native helper accessibility contract reader lanes"
    )

    expect(native_accessibility_contract_visual_reference).to include(
      "Native Accessibility Contract Reference",
      "Focused visual review lane for the current `nativeFieldAccessibilityContract(element)`",
      "wrapper, label, hint, error, and `aria-describedby` pieces",
      "Confirm <code>labelElement</code> resolves an explicit <code>label[for]</code> first, then the nearest wrapper label fallback.",
      "Do not change native helper markup, JavaScript helper behavior, or the reader return shape from this artifact"
    )
  end

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end
end
