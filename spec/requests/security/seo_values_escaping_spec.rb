# frozen_string_literal: true

# The plugin copies an object's SEO options into the page head, where the meta-tags gem renders them
# as tag content and attribute values, and the admin forms echo them back through Rails' form helpers.
# Both escape them, so markup an author stores in an SEO field stays text and never becomes an
# element. Nothing needs refusing at save; this pins the escaping, so a change in the gem or in
# camaleon_cms that stopped it fails the suite.
RSpec.describe 'SEO values carrying markup' do
  init_site

  let(:payload) { %("><script>alert(1)</script><meta x=") }
  let(:seo_options) do
    %w[seo_title keywords seo_description seo_author seo_image seo_canonical].index_with { payload }
  end

  def expect_no_injected_elements(node)
    expect(node.css('script').map(&:text).join).not_to include('alert(1)')
    expect(node.css('meta[x]')).to be_empty
  end

  it 'renders them in the frontend head as text' do
    @post.set_options(seo_options)

    get '/sample-post'

    head = Nokogiri::HTML(response.body).at_css('head')
    expect_no_injected_elements(head)
    expect(head.at_css('meta[property="og:title"]')['content']).to eq(payload)
    expect(head.at_css('meta[property="og:image"]')['content']).to eq(payload)
    expect(head.at_css('link[rel="canonical"]')['href']).to eq(payload)
  end

  it 'echoes them back into the admin SEO fields as values' do
    post_type = @post.post_type
    post_type.set_options(seo_options)
    sign_in_as(cama_admin_user, site: @site)

    get "/admin/settings/post_types/#{post_type.id}/edit"

    document = Nokogiri::HTML(response.body)
    expect_no_injected_elements(document)
    expect(document.at_css('input[name="options[seo_title]"]')['value']).to eq(payload)
    # Rails writes a newline after a textarea's opening tag, which a browser drops from the value.
    expect(document.at_css('textarea[name="options[seo_description]"]').text.delete_prefix("\n")).to eq(payload)
  end
end
