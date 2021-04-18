module Plugins::CamaMetaTag::MainHelper

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
    if is_page? || is_category? || is_post_type?
      page = args[:object].present? ? args[:object] : @cama_visited_post
      tmp = {
          title: page.get_option('seo_title').to_s.translate,
          keywords: page.get_option('keywords').to_s.translate,
          descr: page.get_option('seo_description').to_s.translate,
          author: page.get_option('seo_author').to_s.translate,
          image: page.get_option('seo_image').to_s.translate,
          canonical: page.get_option('seo_canonical').to_s.translate
      }
      args[:seo_data][:keywords] = tmp[:keywords] if tmp[:keywords].present?
      args[:seo_data][:author] = tmp[:author] if tmp[:author].present?
      args[:seo_data][:canonical] = tmp[:canonical] if tmp[:canonical].present?
      if tmp[:title].present?
        args[:seo_data][:title] = tmp[:title]
        args[:seo_data][:og][:title] = tmp[:title]
        args[:seo_data][:twitter][:title] = tmp[:title]
      end
      if tmp[:descr].present?
        args[:seo_data][:description] = tmp[:descr]
        args[:seo_data][:og][:description] = tmp[:descr]
        args[:seo_data][:twitter][:description] = tmp[:descr]
      end
      if tmp[:image].present?
        args[:seo_data][:image] = tmp[:image]
        args[:seo_data][:twitter][:image] = tmp[:image]
        args[:seo_data][:og][:image] = tmp[:image]
      end
    end
  end

  # fix for old versions of camaleon cms
  def cama_meta_tag_post_saved(args)
    if cama_meta_tag_post_is_for_old_version?(args[:post])
      args[:post].set_multiple_options(params[:options].permit!.to_h)
    end
  end

  # check if seo plugin is running for Camaleon CMS <= 2.3.6
  def cama_meta_tag_post_is_for_old_version?(post)
    !post.respond_to?(:manage_seo?)
  end

  def cama_meta_tag_post_type_saved(args)
    args[:post_type].set_multiple_options(params[:options].permit!.to_h)
  end

  def cama_meta_tag_category_saved(args)
    args[:category].set_multiple_options(params[:options].permit!.to_h)
  end

  def cama_meta_tag_post_type_form_custom_html(args)
    args[:html] << render(partial: plugin_view('admin/meta_tag_fields', 'cama_meta_tag'), locals: {post: args[:post_type]})
  end

  def cama_meta_tag_category_form_custom_html(args)
    args[:html] << render(partial: plugin_view('admin/meta_tag_fields', 'cama_meta_tag'), locals: {post: args[:category], post_type: args[:category].post_type})
  end

  def cama_meta_tag_post_form_custom_html(args)
    unless cama_meta_tag_post_is_for_old_version?(args[:post])
      manage_seo = args[:post].manage_seo?
    else
      manage_seo = args[:post].manage_keywords?(args[:post_type]) # support for old Camaleon CMS versions (use keywords setting instead of seo setting)
    end
    args[:html] << render(partial: plugin_view('admin/meta_tag_fields'), locals: {post: args[:post], post_type: args[:post_type]}) if manage_seo
  end
end
