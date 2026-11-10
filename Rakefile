# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CamaMetaTag'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# The suite is run with bin/rspec against the camaleon_cms-backed dummy app under spec/dummy, so the
# dummy-app engine tasks and the default `test` task are intentionally absent.
# `Bundler::GemHelper.install_tasks` still provides build/install/release.
Bundler::GemHelper.install_tasks
