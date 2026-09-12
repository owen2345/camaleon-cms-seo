# frozen_string_literal: true

# Hook handlers for the cama_meta_tag plugin, named in config/camaleon_plugin.json. They add the SEO
# fields to the admin post, category and post type forms, store the submitted options, and override
# the frontend meta tags with the options saved on the visited object.
module Plugins::CamaMetaTag::MainHelper
  # The SEO attributes the plugin manages, keyed by meta tag, with the option each is stored under.
  META_TAG_OPTIONS = { title: 'seo_title', keywords: 'keywords', description: 'seo_description',
                       author: 'seo_author', image: 'seo_image', canonical: 'seo_canonical' }.freeze

  # here all actions on going to active
  # you can run sql commands like this:
  # results = ActiveRecord::Base.connection.execute(query);
  # plugin: plugin model
  def cama_meta_tag_on_active(plugin); end

  # here all actions on going to inactive
  # plugin: plugin model
  def cama_meta_tag_on_inactive(plugin); end

  # Overrides camaleon_cms's default meta tags on a visited post, post type or category with the SEO
  # options saved on it.
  def cama_meta_tag_on_seo(args)
    return unless is_page? || is_category? || is_post_type?

    # camaleon_cms passes the visited object; the controller ivar is the fallback when it does not.
    page = args[:object].presence || @cama_visited_post # rubocop:disable Rails/HelperInstanceVariable
    seo = META_TAG_OPTIONS.transform_values { |option| page.get_option(option).to_s.translate }
    cama_meta_tag_apply_seo(args[:seo_data], seo)
  end

  # fix for old versions of camaleon cms
  def cama_meta_tag_post_saved(args)
    return unless cama_meta_tag_post_is_for_old_version?(args[:post])

    args[:post].set_multiple_options(params[:options].permit!.to_h)
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
    args[:html] << render(partial: plugin_view('admin/meta_tag_fields', 'cama_meta_tag'),
                          locals: { post: args[:post_type] })
  end

  def cama_meta_tag_category_form_custom_html(args)
    args[:html] << render(partial: plugin_view('admin/meta_tag_fields', 'cama_meta_tag'),
                          locals: { post: args[:category],
                                    post_type: args[:category].post_type })
  end

  def cama_meta_tag_post_form_custom_html(args)
    manage_seo = if cama_meta_tag_post_is_for_old_version?(args[:post])
                   # Camaleon CMS <= 2.3.6 has no seo setting, so its keywords setting stands in for it.
                   args[:post].manage_keywords?(args[:post_type])
                 else
                   args[:post].manage_seo?
                 end
    return unless manage_seo

    args[:html] << render(partial: plugin_view('admin/meta_tag_fields'),
                          locals: { post: args[:post],
                                    post_type: args[:post_type] })
  end

  private

  # Writes each non-blank SEO value over its default; the title, description and image also replace
  # their Open Graph and Twitter copies.
  def cama_meta_tag_apply_seo(seo_data, seo)
    %i[keywords author canonical].each { |key| seo_data[key] = seo[key] if seo[key].present? }
    %i[title description image].each do |key|
      next if seo[key].blank?

      [seo_data, seo_data[:og], seo_data[:twitter]].each { |data| data[key] = seo[key] }
    end
  end
end
