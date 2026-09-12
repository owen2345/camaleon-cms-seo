# Change Log

## Unreleased

### Security: SEO fields store only their own options

The category and post type save hooks now store only the six SEO fields, as text values. Before, every submitted `options` key was stored, so a settings manager could set any post type option, and a save without SEO fields answered 500. The post save hooks for Camaleon CMS 2.3.6 and earlier are gone; a plugin adding its own `options[...]` inputs to those two forms stores them from its own hooks. [#53](https://github.com/owen2345/camaleon-cms-seo/pull/53).

### Fix: plugin config parses under json 3

`config/camaleon_plugin.json` carried `//` comments, which the json gem no longer accepts by default as of 3.0, so a host app resolving json 3.x raised `JSON::ParserError` at boot. The file is now plain JSON. [#52](https://github.com/owen2345/camaleon-cms-seo/pull/52).

### Release pipeline

Adds the manually dispatched Release workflow, the same pipeline as camaleon_editor, cama_contact_form and camaleon_cms. It verifies the requested version against `lib/cama_meta_tag/version.rb`, RubyGems and the existing tags, requires a green CI run for the released commit, builds the gem with `--strict` and audits the packaged files. It then publishes to RubyGems, and tags and creates the GitHub release with the version's CHANGELOG section as notes. Development tooling only. [#51](https://github.com/owen2345/camaleon-cms-seo/pull/51).

### RuboCop and CI

Adds RuboCop (same plugin set as camaleon_cms), lint-cleans the codebase with behavior-preserving fixes, and adds a CI workflow running the RSpec suite and RuboCop on every push and pull request. Development tooling only; the packaged gem's behavior is unchanged. [#50](https://github.com/owen2345/camaleon-cms-seo/pull/50).

### Modern toolchain and a spec harness

Modernizes the gemspec (`required_ruby_version >= 3.0`, `README.md` packaged, no test files shipped) and the development setup (Ruby 3.4.10, a committed `Gemfile.lock` on Rails 8.1 and `camaleon_cms >= 2.9.4`), and replaces the generated Minitest scaffolding with a camaleon_cms-backed RSpec suite covering boot, the admin settings page, the SEO form fields and their saving, and the frontend meta tags. The packaged gem's behavior is unchanged. [#49](https://github.com/owen2345/camaleon-cms-seo/pull/49).
