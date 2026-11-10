# frozen_string_literal: true

# The plugin appends its SEO fields (title, keywords, description, author, image, canonical link) to
# the admin forms of posts, categories and post types through camaleon_cms's form hooks. The post
# form only gets them while the post's type manages SEO.
RSpec.describe 'the admin SEO form fields' do
  init_site

  let(:post_type) { @post.post_type }
  let(:seo_keys) { %w[seo_title keywords seo_description seo_author seo_image seo_canonical] }

  before { sign_in_as(cama_admin_user, site: @site) }

  def expect_seo_fields
    expect(response).to have_http_status(:ok)
    seo_keys.each { |key| expect(response.body).to include(%(name="options[#{key}]")) }
  end

  describe 'on the post form' do
    it 'appends the SEO fields while the post type manages SEO' do
      post_type.set_option('has_seo', true)

      get "/admin/post_type/#{post_type.id}/posts/new"

      expect_seo_fields
    end

    it 'leaves them out while the post type does not manage SEO' do
      post_type.set_option('has_seo', false)

      get "/admin/post_type/#{post_type.id}/posts/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('name="options[seo_title]"')
    end
  end

  it 'appends the SEO fields to the category form' do
    category = post_type.categories.create!(name: 'News', slug: 'news')

    get "/admin/post_type/#{post_type.id}/categories/#{category.id}/edit"

    expect_seo_fields
  end

  it 'appends the SEO fields to the post type settings form' do
    get "/admin/settings/post_types/#{post_type.id}/edit"

    expect_seo_fields
  end
end
