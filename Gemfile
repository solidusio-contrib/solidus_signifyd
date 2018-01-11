source "https://rubygems.org"

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", github: "solidusio/solidus", branch: branch

gem 'pg', '~> 0.21'
gem 'mysql2'

if branch != 'master' && branch < "v2.0"
  gem "rails_test_params_backport", group: :test
end

group :development, :test do
  gem "pry-rails"
end

gemspec
