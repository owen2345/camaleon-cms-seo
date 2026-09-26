# frozen_string_literal: true

# On a visited post, the plugin's seo hook overrides camaleon_cms's default meta tags with the SEO
# options saved on the post: the title and description (with their Open Graph and Twitter copies),
# keywords, author, image and canonical link. Without those options, or with the plugin inactive,
# the defaults stand.
RSpec.describe 'the frontend SEO meta tags' do
  init_site

  let(:seo_options) do
    { 'seo_title' => 'Custom SEO title', 'keywords' => 'alpha, beta',
      'seo_description' => 'Custom SEO description', 'seo_author' => 'Jane Doe',
      'seo_image' => 'https://example.com/seo.png', 'seo_canonical' => 'https://example.com/canonical' }
  end

  def visit_sample_post
    get '/sample-post'

    expect(response).to have_http_status(:ok)
    Nokogiri::HTML(response.body)
  end

  def meta_content(document, attribute, value)
    document.at_css(%(meta[#{attribute}="#{value}"]))&.[]('content')
  end

  # camaleon_cms's default page title. the_title is HTML-escaped at the source, while the parsed
  # <title> text is decoded, so the expectation is decoded too: the site is named with an apostrophe
  # (below) to hold the two apart, as a Faker name with one did by chance.
  def default_title
    CGI.unescapeHTML("#{@site.the_title} | #{@post.the_title}")
  end

  context 'with SEO options saved on the post' do
    before { @post.set_options(seo_options) }

    it 'uses the SEO title for the page title and its social copies' do
      document = visit_sample_post

      expect(document.at_css('title').text).to eq('Custom SEO title')
      expect(meta_content(document, 'property', 'og:title')).to eq('Custom SEO title')
      expect(meta_content(document, 'name', 'twitter:title')).to eq('Custom SEO title')
    end

    it 'uses the SEO description, keywords and author' do
      document = visit_sample_post

      expect(meta_content(document, 'name', 'description')).to eq('Custom SEO description')
      expect(meta_content(document, 'property', 'og:description')).to eq('Custom SEO description')
      expect(meta_content(document, 'name', 'twitter:description')).to eq('Custom SEO description')
      expect(meta_content(document, 'name', 'keywords')).to eq('alpha, beta')
      expect(meta_content(document, 'name', 'author')).to eq('Jane Doe')
    end

    it 'uses the SEO image and canonical link' do
      document = visit_sample_post

      expect(meta_content(document, 'property', 'og:image')).to eq('https://example.com/seo.png')
      expect(meta_content(document, 'name', 'twitter:image')).to eq('https://example.com/seo.png')
      expect(document.at_css('link[rel="canonical"]')&.[]('href')).to eq('https://example.com/canonical')
    end
  end

  context 'without SEO options on the post' do
    before { @site.update!(name: "The Editor's Site") }

    it "keeps camaleon_cms's default title" do
      document = visit_sample_post

      expect(document.at_css('title').text).to eq(default_title)
    end
  end

  context 'with the plugin inactive' do
    before do
      @site.update!(name: "The Editor's Site")
      @post.set_options(seo_options)
      store_current_site(@site)
      plugin_uninstall('cama_meta_tag')
    end

    it "ignores the post's SEO options" do
      document = visit_sample_post

      expect(document.at_css('title').text).to eq(default_title)
    end
  end
end
