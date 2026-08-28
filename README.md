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

## Using Busser with Test Kitchen

This is how most people meet Busser, and it needs no `busser` commands of your
own. Select the verifier in `kitchen.yml`:

```yaml
verifier:
  name: busser

suites:
  - name: default
```

Then put tests in a directory named after the plugin that should run them,
inside the suite:

```text
test/integration/default/bash/smoke_test.sh
```

`kitchen verify` installs Busser and the matching plugin on the instance, then
runs the suite. Which plugin runs is decided by that directory name alone --
`bash/` is picked up by busser-bash, `minitest/` by busser-minitest, and so on.
There is nothing else to configure.

## A worked example, without Test Kitchen

To see Busser on its own, set a `BUSSER_ROOT` you can write to:

```bash
export BUSSER_ROOT=/tmp/busser
busser setup
busser plugin install busser-bash
mkdir -p "$BUSSER_ROOT/suites/bash"

cat > "$BUSSER_ROOT/suites/bash/smoke_test.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
echo hello
SH

busser test bash
```

A passing run looks like this, and exits `0`:

```text
-----> Running bash test suite
-----> [bash] smoke_test.sh
hello
```

A failing one names the command and exits non-zero:

```text
-----> Running bash test suite
-----> [bash] smoke_test.sh
!!!!!! Command [bash /tmp/busser/suites/bash/smoke_test.sh] exit code was 1
```

## When nothing runs

A suite whose files do not match what the plugin looks for produces this, and
**exits `0`**:

```text
-----> Running bash test suite
```

No tests ran, and nothing said so. If a suite looks like it is being skipped,
work through these in order:

1. **Is the plugin installed?** `busser plugin list` shows what is available.
   Without the plugin, `busser test` has no runner for that directory.
2. **Is the directory named after the plugin?** Tests for busser-bash live in
   `bash/`, not `tests/` or `scripts/`.
3. **Do the filenames match?** Each plugin globs for its own pattern -- for
   example busser-bash takes `*_test.sh` and `*_spec.bash` but ignores
   `mytest.sh`. Each plugin's README states its pattern.
4. **Is `BUSSER_ROOT` what you think?** `busser suite path` prints where suites
   are actually being looked for.

## Contributing

Bug reports and pull requests are welcome. See
[CONTRIBUTING.md](CONTRIBUTING.md) for how to set up the project, run the test
suites, and format your commits.

## License

Apache License 2.0. See [LICENSE](LICENSE).
