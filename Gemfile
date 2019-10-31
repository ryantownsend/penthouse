source "https://rubygems.org"
ruby ENV.fetch("RUBY_VERSION", "2.3.0")

group :test do
  gem "activesupport", ENV.fetch("RAILS_VERSION", "4.2.2").to_s
  gem "activerecord", ENV.fetch("RAILS_VERSION", "4.2.2").to_s
  gem "pg", ENV.fetch("PG_VERSION", "0.19.0").to_s
end

gemspec
