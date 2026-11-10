# frozen_string_literal: true

# camaleon_cms reads each gem plugin's config/camaleon_plugin.json with JSON.parse while the engine
# boots. json 3 rejects comments by default, so a comment in the file stops every host app that
# resolves json 3 from booting. The suite runs on json 2, so parse the file as json 3 would.
RSpec.describe CamaMetaTag::Engine do
  describe 'config/camaleon_plugin.json' do
    let(:config) { described_class.root.join('config/camaleon_plugin.json').read }

    it 'is plain JSON, without comments' do
      expect { JSON.parse(config, allow_comments: false) }.not_to raise_error
    end

    # The plugin stores the SEO fields of categories and post types; a post's are stored by
    # camaleon_cms itself, so no post save hook is registered.
    it 'registers handlers for the forms it extends, the category and post type saves, and the seo hook' do
      expect(JSON.parse(config)['hooks'].keys).to contain_exactly(
        'on_active', 'on_inactive', 'seo', 'post_form_custom_html', 'category_form',
        'post_type_settings_form', 'created_post_type', 'updated_post_type', 'created_category',
        'updated_category'
      )
    end
  end
end
