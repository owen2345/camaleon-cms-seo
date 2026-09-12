# frozen_string_literal: true

source 'https://rubygems.org'

# Declare your gem's dependencies in cama_meta_tag.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'camaleon_cms', '>= 2.9.4'
gem 'sprockets-rails', '>= 3.5.2'

# Development/test dependencies (none are shipped in the packaged gem). A camaleon_cms-backed dummy
# Rails app under spec/ is booted under RSpec.
group :development do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'sqlite3'

  # json 3 rejects comments in JSON by default, yet camaleon_cms 2.9.4 and this plugin still ship
  # commented configs that are parsed at boot, and Rails 8.1.3.1's ActiveSupport::JSON.decode raises
  # under json 3 as well. Hold the dummy app on json 2.x until those are fixed.
  gem 'json', '< 3'
end
