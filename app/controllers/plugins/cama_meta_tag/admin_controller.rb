class Plugins::CamaMetaTag::AdminController < CamaleonCms::Apps::PluginsAdminController
  include Plugins::CamaMetaTag::MainHelper
  def settings
    # actions for admin panel
  end

  def save_settings
    current_plugin.set_option('enabled_for_post_types', params[:enabled_for_post_types])
    redirect_to(url_for(action: :settings), notice: t('.settings_saved'))
  end
end
