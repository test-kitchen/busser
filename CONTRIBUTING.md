# Contributing to Busser

Thanks for taking the time to contribute. This document covers how to get the
project running locally, how to check your work before opening a pull request,
and the commit convention releases depend on.

## Getting set up

Busser requires **Ruby 3.2 or newer**. Clone the repository and install the
development dependencies:

```bash
git clone https://github.com/test-kitchen/busser.git
cd busser
bundle install
```

Run the CLI from the working tree with `bundle exec busser`.

## Running the tests

There are two suites, and `rake` runs both:

```bash
bundle exec rake test        # everything
bundle exec rake unit        # minitest specs only
bundle exec rake features    # cucumber features only
```

**Unit specs** live in `spec/` and cover library code directly. They use
minitest's spec syntax with the `_()` expectation form:

```ruby
_(suite_path.to_s).must_match %r{/suites$}
```

The bare `suite_path.to_s.must_match` form was removed in minitest 6 and will
not work.

**Cucumber features** live in `features/` and drive the real `busser`
executable through [aruba](https://github.com/cucumber/aruba), so they cover
the CLI end to end. The step definitions are in `lib/busser/cucumber.rb`
because plugin authors reuse them.

Features that install plugins sandbox `GEM_HOME` into a temporary directory and
strip bundler out of the environment, so a test never installs a gem into your
bundle. If you add a step that shells out, be careful not to reintroduce
bundler variables: modern RubyGems re-requires `bundler/setup` whenever
`BUNDLER_SETUP` is present, which silently redirects `GEM_HOME` back at the
bundle.

## Linting

CI runs three linters, all of which you can run locally:

```bash
bundle exec cookstyle --chefstyle   # Ruby
yamllint --strict .                 # YAML
markdownlint-cli2 "**/*.md" "!**/CHANGELOG*.md"
```

## Commit messages

This project uses [Conventional Commits](https://www.conventionalcommits.org).
Releases are automated, and the commit subject on `main` is what decides the
next version number and what appears in the changelog.

Pull requests are **squash merged, so the pull request title becomes that
subject**. A CI check enforces the format on the title; the individual commits
on your branch are not checked.

| Prefix | Effect on the next release |
| --- | --- |
| `fix:` | Patch version bump |
| `feat:` | Minor version bump |
| `feat!:`, or a `BREAKING CHANGE:` footer | Major version bump |
| `chore:`, `docs:`, `ci:`, `test:`, `refactor:` | No release |

For example:

```text
fix: install plugins into GEM_HOME rather than the bundle
feat: add a --verbose flag to plugin install
ci: pin the shared workflow to a release
```

## Opening a pull request

1. Fork the repository and create a branch for your change.
2. Add or update tests. A bug fix should come with a test that fails without it.
3. Run `bundle exec rake test` and the linters above.
4. Open a pull request with a Conventional Commits title.

## Releases

Releases are handled by
[release-please](https://github.com/googleapis/release-please). It watches
commits landing on `main` and keeps a release pull request open with the next
version number and the accumulated changelog. Merging that pull request tags
the release and publishes the gem to RubyGems and GitHub Packages.

Maintainers do not bump `lib/busser/version.rb` or edit `CHANGELOG.md` by
hand; release-please owns both files.
