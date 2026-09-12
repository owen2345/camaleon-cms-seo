# Seo For Camaleon CMS
Permit to manage the seo attributes for each page of Camaleon CMS.
![Alt text](/screenshot.png?raw=true)

## Installation
- Go to admin -> plugins and activate the plugin
- Edit your Post Types "Content Types" settings to enable or disable SEO

## Development

The suite runs against a camaleon_cms-backed dummy Rails app under `spec/` (the Ruby version comes
from `.tool-versions`):

```bash
bundle install
(cd spec/dummy && RAILS_ENV=test bin/rails db:test:prepare)
bin/rspec
```

Lint with the same configuration CI enforces:

```bash
bin/rubocop
```
