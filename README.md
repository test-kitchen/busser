# Busser

[![Gem Version](https://badge.fury.io/rb/busser.svg)](http://badge.fury.io/rb/busser)

Busser is a test setup and execution framework designed to
work on remote nodes whose system dependencies cannot be relied upon, except
for an Omnibus installation of Chef. It uses a plugin architecture to add
support for different testing strategies such minitest, cucumber, bash, etc.

## Status

This software project is no longer under active development as it has no active maintainers. The software may continue to work for some or all use cases, but issues filed in GitHub will most likely not be triaged. If a new maintainer is interested in working on this project please come chat with us in #test-kitchen on Chef Community Slack.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'busser'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install busser
```

## Usage

Busser is driven by the `busser` command. Run `busser help` (or
`busser help SUBCOMMAND`) for the full option list.

### Setting up

Create the Busser home directory, where plugins and suites are installed:

```bash
busser setup
```

### Working with plugins

Test frameworks are added as plugins, each packaged as a `busser-*` gem:

```bash
busser plugin install busser-bash    # install a plugin
busser plugin list                   # list installed plugins
busser plugin create junit           # scaffold a new plugin
```

### Laying out tests

Each plugin picks up the tests belonging to it, under a directory named after
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

Busser is normally invoked for you by
[Test Kitchen](https://github.com/test-kitchen/test-kitchen) rather than by
hand -- Test Kitchen installs Busser on the instance under test and runs
`busser test` as part of `kitchen verify`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
