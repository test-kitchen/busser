# Busser

[![Gem Version](https://badge.fury.io/rb/busser.png)](http://badge.fury.io/rb/busser)
[![Build Status](https://travis-ci.org/test-kitchen/busser.png?branch=master)](https://travis-ci.org/test-kitchen/busser)
[![Code Climate](https://codeclimate.com/github/test-kitchen/busser.png)](https://codeclimate.com/github/test-kitchen/busser)

Busser is a test setup and execution framework designed to
work on remote nodes whose system dependencies cannot be relied upon, except
for an Omnibus installation of Chef. It uses a plugin architecture to add
support for different testing strategies such minitest, cucumber, bash, etc.

## Status

This software project is no longer under active development as it has no active maintainers. The software may continue to work for some or all use cases, but issues filed in GitHub will most likely not be triaged. If a new maintainer is interested in working on this project please come chat with us in #test-kitchen on Chef Community Slack.

## Installation

Add this line to your application's Gemfile:

    gem 'busser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install busser

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
