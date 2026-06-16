# frozen_string_literal: true

RSpec.describe "minimum query documentation boundary" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:readme) { File.read(File.join(repo_root, "README.md")) }
  let(:field_helpers) { File.read(File.join(repo_root, "doc/field_helpers.md")) }
  let(:controller_helpers) { File.read(File.join(repo_root, "doc/controller_helpers.md")) }
  let(:development) { File.read(File.join(repo_root, "doc/development.md")) }

  it "keeps the endpoint-side minimum query policy in the controller helper docs" do
    expect(controller_helpers).to include(
      "`minimum_query_length:` endpoint-side minimum query length",
      "FormBuilder's field-level `min_length:` is a browser-side loading hint",
      "`minimum_query_length:` is the server endpoint policy",
      "Use both when the UI and endpoint should enforce the same minimum"
    )
  end

  it "keeps field helper docs pointing remote helper readers to the endpoint policy" do
    expect(field_helpers).to include(
      "`min_length:` is a client-side load gate before the request is made",
      "Use [`controller_helpers.md#blank-query-policy`](controller_helpers.md#blank-query-policy)",
      "endpoint-side `minimum_query_length:` policy"
    )
  end

  it "keeps the README and development guide from becoming full mirrors" do
    expect(readme).to include(
      "Build remote search, selected preload, create, or token suggestion endpoints",
      "[`doc/controller_helpers.md`](doc/controller_helpers.md)"
    )

    expect(development).to include(
      "The remote request option documentation drift spec keeps representative request-shaping option names visible across README, `doc/field_helpers.md`, and `doc/controller_helpers.md`."
    )
  end
end
