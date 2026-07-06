# frozen_string_literal: true

require "rubygems"
require "spec_helper"

RSpec.describe "visual reference documentation inventory" do
  let(:root) { File.expand_path("..", __dir__) }
  let(:specification) { Gem::Specification.load(File.join(root, "rails_fields_kit.gemspec")) }
  let(:packaged_files) { specification.files.to_a }

  def read_doc(relative_path)
    File.read(File.join(root, relative_path))
  end

  def squish(content)
    content.gsub(/\s+/, " ").strip
  end

  it "ships the Turbo reconnect visual reference with lifecycle scope notes" do
    expect(packaged_files).to include(
      "doc/tom_select_turbo_reconnect_visual_reference.html",
      "doc/tom_select_turbo_lifecycle.md",
      "doc/visual_references.md"
    )

    visual_map = read_doc("doc/visual_references.md")
    reconnect_reference = squish(read_doc("doc/tom_select_turbo_reconnect_visual_reference.html"))
    lifecycle_guide = read_doc("doc/tom_select_turbo_lifecycle.md")

    expect(visual_map).to include(
      "tom_select_turbo_reconnect_visual_reference.html",
      "one-wrapper restored field appearance",
      "duplicate-wrapper caution",
      "runtime reconnect cleanup",
      "request cancellation",
      "stale response guards",
      "lifecycle smoke coverage"
    )

    expect(reconnect_reference).to include(
      "Restored field still has one enhanced wrapper",
      "Reconnect is not a special visible state",
      "Duplicate wrapper is a host-app anti-pattern",
      "Turbo navigation, reconnect cleanup, request cancellation, stale response guards, and lifecycle smoke coverage remain documented"
    )

    expect(lifecycle_guide).to include(
      "disconnect()",
      "aborts in-flight remote requests",
      "request abort and stale-response guards"
    )
  end

  it "keeps the native constraint attribute boundary documented and packaged" do
    expect(packaged_files).to include(
      "doc/native_field_visual_reference.html",
      "doc/public_api.md",
      "doc/visual_references.md"
    )

    visual_map = read_doc("doc/visual_references.md")
    public_api = read_doc("doc/public_api.md")
    native_reference = squish(read_doc("doc/native_field_visual_reference.html"))

    expect(visual_map).to include(
      "For native constraint attribute review",
      "`maxlength`, `pattern`, `inputmode`, and `autocomplete`",
      "ordinary native attributes",
      "browser validation copy, masking, formatting, normalization, and autocomplete policy"
    )

    expect(public_api).to include(
      "Attribute pass-through: Native wrapper helpers pass ordinary Rails/native input attributes",
      "`maxlength`, `minlength`, `pattern`, `required`, `autocomplete`, and `inputmode`",
      "character counters, masking, browser validation-message policy",
      "autocomplete policy",
      "nativeFieldConstraintContract(element)",
      "does not mutate attributes, run validation, own validation messages, apply masking or formatting"
    )

    expect(native_reference).to include(
      "Constraint attribute boundary scan",
      "Metadata and constraint attributes stay native",
      "Native helper lanes can expose ordinary browser attributes such as `inputmode`, `autocomplete`, `maxlength`, and `pattern` without adding masks or owning browser validation message policy.",
      "Pattern shape is native input metadata. Browser validation wording, masking, and normalization stay host-app owned."
    )
  end
end
