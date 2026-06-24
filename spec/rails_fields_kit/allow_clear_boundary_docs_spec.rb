# frozen_string_literal: true

require "spec_helper"

RSpec.describe "allow_clear boundary docs" do
  let(:allow_clear_boundary) { File.read(File.expand_path("../../doc/allow_clear_boundary.md", __dir__)) }
  let(:field_helpers) { File.read(File.expand_path("../../doc/field_helpers.md", __dir__)) }
  let(:public_api) { File.read(File.expand_path("../../doc/public_api.md", __dir__)) }

  it "keeps allow_clear documented as a Tom Select-backed field option" do
    expect(field_helpers).to include(
      "`allow_clear: true` adds `clear_button` to the effective plugin list for that field"
    )

    expect(public_api).to include(
      "Tom Select-backed helpers also support field-level `allow_clear: true`"
    )

    expect(allow_clear_boundary).to include(
      "Tom Select-backed helpers can opt into `allow_clear: true`",
      "`rfk_select` remains the representative single-value example"
    )
  end

  it "keeps clear_button separate from remove_button and host-owned behavior" do
    expect(allow_clear_boundary).to include(
      "`clear_button` clears the whole field value",
      "`remove_button` removes one selected item or token from a multi-value UI",
      "`rfk_tags` and `rfk_token_search` use `remove_button` by default when `plugins:` is omitted"
    )

    expect(allow_clear_boundary).to include(
      "remote search request lifecycle",
      "selected preload request lifecycle",
      "create-on-the-fly request lifecycle",
      "tag creation policy",
      "token parsing or search execution"
    )
  end
end
