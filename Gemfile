source 'https://rubygems.org'

gemspec development_group: :test
group :cookstyle do
  gem "cookstyle"
end

group :test do
  gem "minitest", "~> 5.0"  # specs use the pre-6.0 must_* expectation syntax
  gem "base64"  # cucumber 9.x needs it; not a default gem on Ruby 4.0
  gem "cucumber", "~> 9.0"
  gem "rake"
end
