module Plugins::CamaMetaTag::MainHelper
  def self.included(klass)
    # klass.helper_method [:my_helper_method] rescue "" # here your methods accessible from views
  end

  # here all actions on going to active
  # you can run sql commands like this:
  # results = ActiveRecord::Base.connection.execute(query);
  # plugin: plugin model
  def cama_meta_tag_on_active(plugin)
  end

  # here all actions on going to inactive
  # plugin: plugin model
  def cama_meta_tag_on_inactive(plugin)
  end

  def cama_meta_tag_on_seo(args)
    if is_page?
      tmp = {
          title: args[:object].get_option('seo_title').to_s.translate,
          keywords: args[:object].get_option('keywords').to_s.translate,
          descr: args[:object].get_option('seo_description').to_s.translate,
          author: args[:object].get_option('seo_author').to_s.translate,
          image: args[:object].get_option('seo_image').to_s.translate
      }
      args[:seo_data][:title] = tmp[:title] if tmp[:title].present?
      args[:seo_data][:keywords] = tmp[:keywords] if tmp[:keywords].present?
      args[:seo_data][:description] = tmp[:descr] if tmp[:descr].present?
      args[:seo_data][:author] = tmp[:author] if tmp[:author].present?
      if tmp[:image].present?
        args[:seo_data][:image] = tmp[:image]
        args[:seo_data][:twitter][:image] = tmp[:image]
        args[:seo_data][:og][:image] = tmp[:image]
      end
    end
  end

  # def cama_meta_tags_plugin_links(args)
  #   # args[:links] << link_to(cama_t('plugins.cama_meta_tag.admin.settings_label'), admin_plugins_cama_meta_tag_settings_path)
  # end

  def cama_meta_tag_post_form_custom_html(args)
    args[:html] << render(partial: plugin_view('admin/meta_tag_fields'), locals: {post: args[:post], post_type: args[:post_type]}) if args[:post].manage_seo?
  end
end
