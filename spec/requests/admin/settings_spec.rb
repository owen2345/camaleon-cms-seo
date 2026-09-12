# frozen_string_literal: true

# The plugin's admin settings page lists the site's post types, and saving it stores the selected
# post type ids on the site's plugin record.
RSpec.describe 'the cama_meta_tag admin settings' do
  init_site

  let(:settings_path) { '/admin/plugins/cama_meta_tag/settings' }
  let(:post_type) { @site.post_types.first }
  let(:plugin) { @site.plugins.find_by!(slug: 'cama_meta_tag') }

  before { sign_in_as(cama_admin_user, site: @site) }

  it 'lists every post type of the site' do
    get settings_path

    expect(response).to have_http_status(:ok)
    @site.post_types.each do |each_post_type|
      expect(response.body).to include(%(name="enabled_for_post_types[]" value="#{each_post_type.id}"))
    end
  end

  it 'stores the selected post types and redirects back to the settings page' do
    post '/admin/plugins/cama_meta_tag/save_settings', params: { enabled_for_post_types: [post_type.id.to_s] }

    expect(response).to redirect_to(settings_path)
    expect(plugin.get_option('enabled_for_post_types')).to eq([post_type.id.to_s])
  end

  it 'checks the saved post types when the page is shown again' do
    plugin.set_option('enabled_for_post_types', [post_type.id.to_s])

    get settings_path

    expect(response.body).to include(%(value="#{post_type.id}" checked))
  end
end
