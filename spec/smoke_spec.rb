# frozen_string_literal: true

# End-to-end smoke test: boots a camaleon_cms-backed dummy app with this plugin loaded (the test env
# eager-loads, so a plugin class referencing a missing constant fails the whole boot) and asserts the
# cama_meta_tag plugin is wired up -- discovered by the CMS as a gem-mode plugin, every hook its
# camaleon_plugin.json names defined on the plugin helper, and its admin routes drawn.
RSpec.describe 'cama_meta_tag plugin', type: :model do
  it 'loads the engine and top-level constant' do
    expect(defined?(CamaMetaTag)).to eq('constant')
    expect(CamaMetaTag::VERSION).to be_a(String)
    expect(CamaMetaTag::Engine.ancestors).to include(Rails::Engine)
  end

  it 'is discovered by Camaleon as a gem-mode plugin' do
    info = PluginRoutes.plugin_info('cama_meta_tag')
    expect(info).to be_present
    expect(info['key']).to eq('cama_meta_tag')
    expect(info['gem_mode']).to be(true)
  end

  it 'defines every hook method camaleon_plugin.json names on the plugin helper' do
    hook_methods = PluginRoutes.plugin_info('cama_meta_tag')['hooks'].values.flatten.uniq.map(&:to_sym)

    expect(hook_methods).not_to be_empty
    expect(Plugins::CamaMetaTag::MainHelper.instance_methods).to include(*hook_methods)
  end

  it 'draws its admin settings routes on the host application' do
    helpers = Rails.application.routes.url_helpers

    expect(helpers).to respond_to(:admin_plugins_cama_meta_tag_settings_path)
    expect(helpers).to respond_to(:admin_plugins_cama_meta_tag_save_settings_path)
  end

  # cama_meta_tag is one of camaleon_cms's default plugins, so every site gets it on install.
  it 'is installed and active on a new site' do
    expect(CamaleonCms::Site.first.plugins.active.pluck(:slug)).to include('cama_meta_tag')
  end
end
