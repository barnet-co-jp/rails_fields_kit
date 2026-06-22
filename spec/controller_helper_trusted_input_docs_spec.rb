# frozen_string_literal: true

require "spec_helper"

RSpec.describe "controller helper trusted input documentation" do
  let(:root_path) { File.expand_path("..", __dir__) }
  let(:controller_helpers) { File.read(File.join(root_path, "doc/controller_helpers.md")) }

  it "keeps rfk_search_with scope and order boundaries host-app owned" do
    trusted_boundary = markdown_section(controller_helpers, "### Trusted scope and order inputs")

    expect(trusted_boundary).to include(
      "`scope:` and `order:` are endpoint-side relation helpers, not request-parameter sanitizers",
      "trusted relations, named model scopes, constants, or allowlisted values",
      "controller-owned allowlist",
      "Do not pass arbitrary request params directly into `order:`",
      "use `scope:` to expose a relation the current user has not already been allowed to search",
      "authentication, authorization, tenant scoping, validation, and query execution decisions stay in the host app"
    )
  end

  def markdown_section(document, heading)
    document.split(heading, 2).last.split(/\n(?=##?#?\s)/, 2).first
  end
end
