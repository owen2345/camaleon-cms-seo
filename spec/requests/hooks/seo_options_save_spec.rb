# frozen_string_literal: true

# Saving a category or a post type stores the submitted SEO options on the record through the
# plugin's created_/updated_ hooks. A post's options are stored by camaleon_cms itself; the post
# example pins that the fields the plugin adds to the post form still land on the post.
RSpec.describe 'saving the SEO options' do
  init_site

  let(:post_type) { @post.post_type }
  let(:seo_options) do
    { 'seo_title' => 'SEO title', 'keywords' => 'alpha, beta', 'seo_description' => 'SEO description',
      'seo_author' => 'Jane Doe', 'seo_image' => 'https://example.com/seo.png',
      'seo_canonical' => 'https://example.com/canonical' }
  end

  before { sign_in_as(cama_admin_user, site: @site) }

  def expect_seo_options(record)
    seo_options.each { |key, value| expect(record.get_option(key)).to eq(value) }
  end

  it 'stores them on a created category' do
    post "/admin/post_type/#{post_type.id}/categories",
         params: { category: { name: 'Events', slug: 'events' }, options: seo_options }

    expect_seo_options(post_type.categories.find_by!(slug: 'events'))
  end

  it 'stores them on an updated category' do
    category = post_type.categories.create!(name: 'News', slug: 'news')

    patch "/admin/post_type/#{post_type.id}/categories/#{category.id}",
          params: { category: { name: 'News', slug: 'news' }, options: seo_options }

    expect_seo_options(category.reload)
  end

  it 'stores them on an updated post type' do
    patch "/admin/settings/post_types/#{post_type.id}",
          params: { post_type: { name: post_type.name, slug: post_type.slug }, options: seo_options }

    # A fresh record: `reload` keeps the post type's memoized options.
    expect_seo_options(CamaleonCms::PostType.find(post_type.id))
  end

  it 'stores them on an updated post' do
    patch "/admin/post_type/#{post_type.id}/posts/#{@post.id}",
          params: { post: { title: @post.title, content: @post.content, status: 'published' },
                    options: seo_options }

    expect_seo_options(CamaleonCms::Post.find(@post.id))
  end
end
