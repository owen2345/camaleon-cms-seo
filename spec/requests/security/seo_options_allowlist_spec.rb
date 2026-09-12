# frozen_string_literal: true

# The plugin's created_/updated_ hooks save the SEO fields it adds to the category and post type
# forms. They stored every submitted `options` key, with any nested value, on the record. On a post
# type that bypassed camaleon_cms's own allowlist of post type options, so a settings manager could
# set `cama_post_decorator_class`, the class name camaleon_cms constantizes to decorate every post of
# that type. A save carrying no SEO fields raised after the record was already stored.
RSpec.describe 'saving SEO options through the plugin hooks' do
  init_site

  let(:post_type) { @post.post_type }

  describe 'on a post type' do
    let(:settings_manager) { user_with_manager_grants({ 'settings' => 1 }, 'Settings Manager') }

    before { sign_in_as(settings_manager, site: @site) }

    it 'does not let a settings manager choose the post decorator class' do
      patch "/admin/settings/post_types/#{post_type.id}",
            params: { post_type: { name: post_type.name, slug: post_type.slug },
                      options: { 'seo_title' => 'SEO title', 'cama_post_decorator_class' => 'Object' } }

      saved_post_type = CamaleonCms::PostType.find(post_type.id)
      expect(saved_post_type.get_option('seo_title')).to eq('SEO title')
      expect(saved_post_type.get_option('cama_post_decorator_class')).to be_nil
      expect(CamaleonCms::Post.find(@post.id).decorator_class).to eq(CamaleonCms::PostDecorator)
    end

    it 'does not let a settings manager choose the post decorator class of a new post type' do
      post '/admin/settings/post_types',
           params: { post_type: { name: 'Products', slug: 'products' },
                     options: { 'seo_title' => 'SEO title', 'cama_post_decorator_class' => 'Object' } }

      created_post_type = @site.post_types.find_by!(slug: 'products')
      expect(created_post_type.get_option('seo_title')).to eq('SEO title')
      expect(created_post_type.get_option('cama_post_decorator_class')).to be_nil
    end

    it 'saves a post type submitted without SEO fields' do
      patch "/admin/settings/post_types/#{post_type.id}",
            params: { post_type: { name: post_type.name, slug: post_type.slug } }

      expect(response).to redirect_to('/admin/settings/post_types')
    end
  end

  describe 'on a category' do
    let(:category) { post_type.categories.create!(name: 'News', slug: 'news') }
    let(:categories_path) { "/admin/post_type/#{post_type.id}/categories" }

    before { sign_in_as(cama_admin_user, site: @site) }

    it 'stores only the SEO options, and only text values, keeping the ones it ignores' do
      category.set_option('seo_author', 'Jane Doe')

      patch "#{categories_path}/#{category.id}",
            params: { category: { name: 'News', slug: 'news' },
                      options: { 'seo_title' => 'SEO title', 'unrelated' => 'x',
                                 'seo_author' => { 'nested' => ['value'] } } }

      saved_category = CamaleonCms::Category.find(category.id)
      expect(saved_category.get_option('seo_title')).to eq('SEO title')
      expect(saved_category.get_option('unrelated')).to be_nil
      expect(saved_category.get_option('seo_author')).to eq('Jane Doe')
    end

    it 'saves a category submitted without SEO fields' do
      post categories_path, params: { category: { name: 'Bare', slug: 'bare' } }

      expect(response).to redirect_to(categories_path)
      expect(post_type.categories.find_by(slug: 'bare')).to be_present
    end

    it 'saves a category whose options are not a set of fields, keeping its SEO options' do
      category.set_option('seo_title', 'Kept title')

      patch "#{categories_path}/#{category.id}",
            params: { category: { name: 'News', slug: 'news' }, options: 'seo_title' }

      expect(response).to redirect_to(categories_path)
      expect(CamaleonCms::Category.find(category.id).get_option('seo_title')).to eq('Kept title')
    end

    # camaleon_cms's own forms carry only keys it permits, so a host may raise on unpermitted
    # parameters; the SEO fields must then still be stored and any other value ignored.
    describe 'on a host that raises on unpermitted parameters' do
      around do |example|
        previous = ActionController::Parameters.action_on_unpermitted_parameters
        ActionController::Parameters.action_on_unpermitted_parameters = :raise
        example.run
      ensure
        ActionController::Parameters.action_on_unpermitted_parameters = previous
      end

      it 'stores the SEO options next to an unrelated key' do
        patch "#{categories_path}/#{category.id}",
              params: { category: { name: 'News', slug: 'news' },
                        options: { 'seo_title' => 'SEO title', 'unrelated' => 'x' } }

        expect(response).to redirect_to(categories_path)
        expect(CamaleonCms::Category.find(category.id).get_option('seo_title')).to eq('SEO title')
      end

      it 'stores the SEO options next to a nested value under an SEO key' do
        patch "#{categories_path}/#{category.id}",
              params: { category: { name: 'News', slug: 'news' },
                        options: { 'seo_title' => 'SEO title', 'seo_author' => { 'nested' => ['value'] } } }

        expect(response).to redirect_to(categories_path)
        expect(CamaleonCms::Category.find(category.id).get_option('seo_title')).to eq('SEO title')
      end
    end
  end
end
