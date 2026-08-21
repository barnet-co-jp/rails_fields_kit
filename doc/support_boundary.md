# Rails Fields Kit Support Boundary

This page summarizes the current version boundary that is already encoded in the gem metadata, package metadata, and CI matrix. It does not change the host application's Tom Select runtime policy.

## Host app Ruby and Rails boundary

Rails Fields Kit is published as a Ruby gem for Rails host applications.

- Ruby: `>= 3.1`
- Rails: `>= 7.0`, `< 9.0`

The source of truth for these install-time boundaries is `rails_fields_kit.gemspec`.

## Repository compatibility checks

GitHub Actions runs the main Ruby checks on Ruby 3.3 and adds representative Rails compatibility checks for pull requests and `main` pushes:

| Rails | Ruby | Gemfile |
| --- | --- | --- |
| 7.0 | 3.1 | `gemfiles/rails_7_0.gemfile` |
| 8.0 | 3.3 | `gemfiles/rails_8_0.gemfile` |

These checks are representative CI coverage, not a separate host-app setup step or a full Rails/Ruby support matrix.

## JavaScript and Node boundary

Rails Fields Kit ships JavaScript entrypoints for the Stimulus controller and package-root helper exports, but the host app still chooses its JavaScript bundling or importmap strategy.

The package metadata boundary is Node 22.x || 24.x. The repository JavaScript check uses Node 22.x and Node 24.x because `package.json` declares `engines.node` as `22.x || 24.x` and the GitHub Actions `javascript` job runs `npm run check:js` on both Node lines. This is the boundary for repository-local JavaScript checks and package export smoke tests.

No single `.nvmrc` or `.node-version` file is committed as the repository support boundary. Contributors can run local JavaScript checks on either supported major, while `package.json` and the CI matrix remain the source of truth for the two-line Node boundary.

That Node 22.x / 24.x boundary is not a Tom Select runtime support policy for host applications. Rails Fields Kit does not publish a required Tom Select package version, pin source, CDN source, plugin list, plugin asset policy, or package-manager lockfile policy. Host applications choose and review those Tom Select runtime dependencies through their own JavaScript toolchain.

Host applications still need to install Tom Select, load any Tom Select CSS or plugin assets they enable, and register the Rails Fields Kit Stimulus controller with their own JavaScript toolchain. See `doc/setup.md` for setup examples and `doc/development.md` for local check commands.

## What this page does not define

This page does not add host-app support requirements for new JavaScript toolchains. It also does not change package manager policy, generator behavior, Tom Select installation, Tom Select version ownership, plugin asset ownership, bundler setup, importmap pinning, or host-app runtime responsibility.
