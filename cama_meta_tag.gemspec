$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cama_meta_tag/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cama_meta_tag"
  s.version     = CamaMetaTag::VERSION
  s.authors     = ["Owen Peredo"]
  s.email       = ["owenperedo@gmail.com"]
  s.homepage    = ""
  s.summary     = "Permit to manage the seo attributes for each page of Camaleon CMS."
  s.description = "Permit to manage the seo attributes for each page of Camaleon CMS."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.1.0"
  s.add_development_dependency "sqlite3"
end
