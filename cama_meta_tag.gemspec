# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'cama_meta_tag/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'cama_meta_tag'
  s.version     = CamaMetaTag::VERSION
  s.authors     = ['Owen Peredo']
  s.email       = ['owenperedo@gmail.com']
  s.homepage    = 'https://github.com/owen2345/camaleon-cms-seo'
  s.summary     = 'SEO meta tags plugin for Camaleon CMS'
  s.description = 'Manage the SEO attributes (title, keywords, description, author, image and canonical link) ' \
                  'of Camaleon CMS posts, categories and post types, rendered as meta tags on the frontend.'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.0'

  # No test_files: RubyGems merges it into `files`, which would ship the test suite to users.
  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails'
end
