## [0.9.0](https://github.com/test-kitchen/busser/compare/v0.8.0...v0.9.0) (2026-08-28)

The first release since 2020. Busser now runs on current Ruby, which is the
main reason to take this version.

### Breaking changes

* Ruby 3.2 or newer is now required ([#61](https://github.com/test-kitchen/busser/pull/61))

### Bug fixes

* The CLI no longer crashes on startup on modern Ruby. thor 1.1 and newer are
  required, because earlier versions reference `DidYouMean::SPELL_CHECKERS`,
  which Ruby 3.1 removed ([#54](https://github.com/test-kitchen/busser/pull/54))
* `base64` is declared as a runtime dependency. It stopped being a default gem,
  so `busser deserialize` failed to load on Ruby 3.4 and
  newer ([#54](https://github.com/test-kitchen/busser/pull/54))
* A plugin installed at more than one version is no longer reported once per
  version. `busser test` ran that plugin's suite repeatedly and
  `busser plugin list` printed it repeatedly ([#64](https://github.com/test-kitchen/busser/pull/64))
* `busser deserialize` verifies the md5 digest before writing. It previously
  checked afterwards, so a corrupted or truncated stream left the unverified
  file on disk with its requested permissions, even though the command
  failed ([#64](https://github.com/test-kitchen/busser/pull/64))

### Maintenance

* Test suites run on Ruby 3.2 through 4.0 with minitest 6 and cucumber 11, and
  the cucumber suite moved to aruba 2 ([#54](https://github.com/test-kitchen/busser/pull/54), [#60](https://github.com/test-kitchen/busser/pull/60), [#61](https://github.com/test-kitchen/busser/pull/61))
* CI runs on pushes to main, uses a least privilege token, and pins the shared
  workflow to a release ([#59](https://github.com/test-kitchen/busser/pull/59))
* Releases are automated with release-please ([#62](https://github.com/test-kitchen/busser/pull/62))
* Rewritten README, and development documentation moved to
  CONTRIBUTING.md ([#63](https://github.com/test-kitchen/busser/pull/63))

## [0.9.1](https://github.com/test-kitchen/busser/compare/v0.9.0...v0.9.1) (2026-08-28)


### Bug Fixes

* generate a plugin project that resolves and builds ([#68](https://github.com/test-kitchen/busser/issues/68)) ([0c9a450](https://github.com/test-kitchen/busser/commit/0c9a450af83f086ac3627be938db856c9657208b))
* report signals and keep bundler out of the busser binstub ([#66](https://github.com/test-kitchen/busser/issues/66)) ([4fc9b35](https://github.com/test-kitchen/busser/commit/4fc9b350c7e3990c82ce4e229927be60a6431ee7))

## 0.8.0 / 2020-08-20

- Add http_proxy support to `busser plugin install`
- Use a SPDX compliant license string in the gemspec
- Remove the pin to bundler 1.x in the development gems
- Misc readme updates
- Add testing with Appveyor
- Pin the Aruba dev dep to prevent API churn

## 0.7.1 / 2015-04-20

### Bug fixes

* Pull request [#23][]: Dir.glob does not accept `/` but on windows hosts uses `/` when joining path segments - expanding the path corrects this. ([@tyler-ball][])

## 0.7.0 / 2015-03-19

### Bug fixes

* Pull request [#20][], issue [#17][]: Better detection of failed forked subprocess in `#run_ruby_script!` & `#run!`. ([@fnichol][], [@tyler-ball][], [@tknerr][])

### New features

* Add optional `--type bat` flag to `busser setup` to support Windows platforms. ([@fnichol][])

### Improvements

* Simplify busser binstub for more conservative bourne shell support. ([@fnichol][])
* Pull request [#15][]: Fix spelling in `busser test`. ([@obazoud][])


## 0.6.2 / 2014-03-23

### Bug fixes

* Pull request [#8][]: Invoke prepare.sh scripts with /bin/sh for platforms without bash. ([@fnichol][])


## 0.6.1 / 2014-03-23

### Bug fixes

* Issue [#7][]: Ensure that Pathname is coerced to a String before calling Thor's #say. ([@fnichol][])
* Pull request [#4][], issue [#3][]: /usr/bin/env sh shouldn't assume bourne shell. ([@jtimberman][])
* Pull request [#5][]: Remove binstub before create. ([@sawanoboly][])
* Pull request [#6][]: Support binstub on SmartOS. ([@neuhalje][])


## 0.6.0 / 2013-11-27

### Breaking changes

* Pull request [#2][]: Remove soft dependency on Chef library code (chef\_apply). ([@fnichol][])

### Improvements

* Ensure that the Busser binstub script is bourne shell safe. ([@fnichol][])

## 0.5.0 / 2013-11-20

### Improvements

* Allow `busser setup` binstub script to honor gem sandboxing and a relocatable BUSSER\_ROOT. ([@fnichol][])
* TravisCI matrix build updates. ([@fnichol][])


## 0.4.1 / 2013-04-23

### Improvements

* Add method to Drop SSL verify peer to VERIFY_NONE within a given block (see commit for explanation). ([@fnichol][])


## 0.4.0 / 2013-04-10

### New features

* Add Busser::Helpers.install_gem. ([@fnichol][])
* Add Busser::UI.run_ruby_script! (dies on nonzero exit). ([@fnichol][])


## 0.3.2 / 2013-04-10

### Improvements

* Add more cucumber steps for vendor paths. ([@fnichol][])


## 0.3.1 / 2013-04-10

### Bug fixes

* If gem is installed but not on RubyGems, then pass #gem_installed?. ([@fnichol][])


## 0.3.0 / 2013-04-09

### New features

* Add `busser plugin create` command to help create new plugin gem projects. ([@fnichol][])
* Add #chef_apply to Busser::Helpers; chef-apply inline baby! ([@fnichol][])
* Implement execution of prepare.sh/prepare_recipe.rb before suite test. ([@fnichol][])

### Improvements

* Add Busser::Helpers.vendor_path helper. ([@fnichol][])


## 0.2.0 / 2013-03-31

### New features

* Add dummy runner internal plugin and skip on plugin install commands. ([@fnichol][])
* Add postinstall feature to runner plugins & add dummy runner plugin. ([@fnichol][])
* Move cucumber steps into lib/ for use by plugin authors. ([@fnichol][])


## 0.1.1 / 2013-03-29

### New features

* Add `busser deserialize` command to accept streamed files. ([@fnichol][])

### Improvements

* Support installing plugins from local .gem files. ([@fnichol][])


## 0.1.0 / 2013-03-28

* Initial release

<!--- The following link definition list is generated by PimpMyChangelog --->
[#2]: https://github.com/test-kitchen/busser/issues/2
[#3]: https://github.com/test-kitchen/busser/issues/3
[#4]: https://github.com/test-kitchen/busser/issues/4
[#5]: https://github.com/test-kitchen/busser/issues/5
[#6]: https://github.com/test-kitchen/busser/issues/6
[#7]: https://github.com/test-kitchen/busser/issues/7
[#8]: https://github.com/test-kitchen/busser/issues/8
[#15]: https://github.com/test-kitchen/busser/issues/15
[#17]: https://github.com/test-kitchen/busser/issues/17
[#20]: https://github.com/test-kitchen/busser/issues/20
[#23]: https://github.com/test-kitchen/busser/issues/23
[@fnichol]: https://github.com/fnichol
[@jtimberman]: https://github.com/jtimberman
[@neuhalje]: https://github.com/neuhalje
[@obazoud]: https://github.com/obazoud
[@sawanoboly]: https://github.com/sawanoboly
[@tknerr]: https://github.com/tknerr
[@tyler-ball]: https://github.com/tyler-ball
