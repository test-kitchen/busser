# Busser

[![Gem Version](https://badge.fury.io/rb/busser.svg)](http://badge.fury.io/rb/busser)

Busser runs your integration tests on the machine under test.

It is built for remote nodes whose system dependencies cannot be relied upon,
so it assumes very little about where it lands. Test frameworks are added as
plugins, each a `busser-*` gem, which lets a single suite run bash scripts,
minitest specs, RSpec examples or anything else a plugin knows how to execute.

Busser is normally invoked for you by
[Test Kitchen](https://github.com/test-kitchen/test-kitchen), which installs it
on the instance under test and runs `busser test` as part of `kitchen verify`.
You can also drive it directly, which is what the rest of this document covers.

## Status

This software project is no longer under active development as it has no active maintainers. The software may continue to work for some or all use cases, but issues filed in GitHub will most likely not be triaged. If a new maintainer is interested in working on this project please come chat with us in #test-kitchen on Chef Community Slack.

## Requirements

Ruby 3.2 or newer.

## Installation

```bash
gem install busser
```

Or add it to your `Gemfile`:

```ruby
gem "busser"
```

## Usage

Busser is driven by the `busser` command. Run `busser help`, or
`busser help SUBCOMMAND`, for the full option list.

### Setting up

Create the Busser home directory, where plugins and suites are installed:

```bash
busser setup
```

By default this is `/opt/busser`. Set `BUSSER_ROOT` to put it elsewhere.

### Working with plugins

Each test framework is a separate `busser-*` gem:

```bash
busser plugin install busser-bash    # install a plugin
busser plugin install busser-bash@0.3.0  # install a specific version
busser plugin list                   # list installed plugins
busser plugin create junit           # scaffold a new plugin
```

### Laying out tests

Each plugin picks up the tests belonging to it, from a directory named after
the plugin inside the suite:

```text
test
`-- integration
    `-- default        # suite name
        |-- bash       # picked up by busser-bash
        |   `-- my_test.sh
        `-- minitest   # picked up by busser-minitest
            `-- test_default.rb
```

Use `busser suite path` to print where suites live, and `busser suite cleanup`
to remove them.

### Running tests

Run every installed plugin's suites, or name specific plugins:

```bash
busser test
busser test bash minitest
```

## Contributing

Bug reports and pull requests are welcome. See
[CONTRIBUTING.md](CONTRIBUTING.md) for how to set up the project, run the test
suites, and format your commits.

## License

Apache License 2.0. See [LICENSE](LICENSE).
