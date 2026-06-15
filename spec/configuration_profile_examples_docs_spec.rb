# frozen_string_literal: true

RSpec.describe "configuration profile examples documentation" do
  let(:profile_docs) { File.read("doc/configuration_profiles.md") }

  it "keeps initializer profiles as docs-only copyable examples" do
    expect(profile_docs).to include("Rails Fields Kit does not ship named initializer profiles")
    expect(profile_docs).to include("not presets, modes, or design system policy owned by the gem")
    expect(profile_docs).to include("These examples deliberately avoid a Ruby profile API")
  end

  it "documents representative host app configuration patterns" do
    expect(profile_docs).to include("## Admin-heavy Internal Tools")
    expect(profile_docs).to include("## Public Forms")
    expect(profile_docs).to include("## Compact Table Filters")
  end

  it "keeps host app responsibilities outside the initializer examples" do
    expect(profile_docs).to include("authorization")
    expect(profile_docs).to include("endpoint behavior")
    expect(profile_docs).to include("Tom Select asset loading")
    expect(profile_docs).to include("Query execution, table persistence, filter semantics")
  end
end
