# frozen_string_literal: true

source 'https://rubygems.org'

# Declare your gem's dependencies in cama_meta_tag.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# CAMALEON_CMS_PATH sources the core from a local checkout instead of the released gem, which is how
# the Core compatibility workflow (.github/workflows/core_compat.yml) runs this suite against an
# unreleased core commit. The committed Gemfile.lock belongs to the released gem: after a local run
# with the variable set, restore it with `git checkout Gemfile.lock`.
camaleon_cms_path = ENV.fetch('CAMALEON_CMS_PATH', '')
if camaleon_cms_path.empty?
  gem 'camaleon_cms', '>= 2.9.4'
else
  gem 'camaleon_cms', path: camaleon_cms_path
end
gem 'sprockets-rails', '>= 3.5.2'

# Development/test dependencies (none are shipped in the packaged gem). A camaleon_cms-backed dummy
# Rails app under spec/ is booted under RSpec.
group :development do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'sqlite3'

  # Linting -- same rubocop plugin set as camaleon_cms, so style stays consistent across the repos.
  gem 'rubocop'
  gem 'rubocop-factory_bot'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'

  # json 3 rejects comments in JSON by default, yet camaleon_cms 2.9.4 still ships commented configs
  # that it parses at boot, and Rails 8.1.3.1's ActiveSupport::JSON.decode raises under json 3 as
  # well. Hold the dummy app on json 2.x until both are fixed.
  gem 'json', '< 3'
end
