source "https://rubygems.org"

gemspec development_group: :test
group :cookstyle do
  gem "cookstyle"
end

group :test do
  # minitest 6 and cucumber 11 both require Ruby 3.2, and this gem still
  # supports 3.1. The specs themselves no longer hold these back: they use the
  # _() expectation syntax and pass on minitest 6 and cucumber 11 today. Unpin
  # once the supported Ruby floor moves.
  gem "minitest", "~> 6.0"
  gem "base64" # cucumber 9.x needs it; not a default gem on Ruby 4.0
  gem "cucumber", "~> 9.0"
  gem "rake"
end
