source "https://rubygems.org"

gemspec development_group: :test
group :cookstyle do
  gem "cookstyle"
end

group :test do
  gem "minitest", ">= 6.0"
  gem "base64" # cucumber needs it; not a default gem on Ruby 4.0
  gem "cucumber", ">= 11.1"
  gem "rake"
end
