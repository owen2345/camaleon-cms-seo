# Change Log

## Unreleased

### Modern toolchain and a spec harness

Modernizes the gemspec (`required_ruby_version >= 3.0`, `README.md` packaged, no test files shipped) and the development setup (Ruby 3.4.10, a committed `Gemfile.lock` on Rails 8.1 and `camaleon_cms >= 2.9.4`), and replaces the generated Minitest scaffolding with a camaleon_cms-backed RSpec suite covering boot, the admin settings page, the SEO form fields and their saving, and the frontend meta tags. The packaged gem's behavior is unchanged. [#49](https://github.com/owen2345/camaleon-cms-seo/pull/49).
