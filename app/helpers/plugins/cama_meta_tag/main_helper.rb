# frozen_string_literal: true

# Hook handlers for the cama_meta_tag plugin, named in config/camaleon_plugin.json. They add the SEO
# fields to the admin post, category and post type forms, store the ones submitted for a category or
# a post type (camaleon_cms stores a post's own), and override the frontend meta tags with the options
# saved on the visited object.
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

  def cama_meta_tag_post_type_saved(args)
    args[:post_type].set_multiple_options(cama_meta_tag_submitted_options)
  end

  def cama_meta_tag_category_saved(args)
    args[:category].set_multiple_options(cama_meta_tag_submitted_options)
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
    return unless args[:post].manage_seo?

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

  # The submitted SEO fields, as text values. Nothing else under `options` is stored: on a post type
  # it would bypass camaleon_cms's own allowlist of post type options. The values are picked directly
  # rather than through `permit`, which reports a nested value under an SEO key as unpermitted and,
  # on a host that raises for those, would fail the save after the record was stored.
  def cama_meta_tag_submitted_options
    options = params[:options]
    return {} unless options.is_a?(ActionController::Parameters)

    options.to_unsafe_h.slice(*META_TAG_OPTIONS.values).select { |_key, value| value.is_a?(String) }
  end
end
