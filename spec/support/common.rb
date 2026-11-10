# frozen_string_literal: true

# Spec helpers adapted from camaleon_cms's spec/support/common.rb (user_with_manager_grants from
# camaleon_editor's). Only the helpers the cama_meta_tag specs actually use are ported.

# Expose the suite-wide shared site (spec/support/shared_site.rb) as @site, along with its sample
# post. fresh: true replaces it with a site created inside the example's transaction.
def init_site(fresh: false)
  before do
    if fresh
      CamaleonCms::Site.delete_all
      @site = create(:site).decorate
    else
      @site = (CamaleonCms::Site.first || create(:site)).decorate
    end
    @post = @site.the_post('sample-post').decorate
  end

  after do
    @site = nil
    @post = nil
  end
end

# The site's seeded admin user (username 'admin', see spec/factories/site.rb).
def cama_admin_user(username = 'admin')
  CamaManager.get_user_class_name.constantize.find_by!(username: username)
end

# A user on @site whose role holds exactly the given manager grants (permission meta). An empty grants
# hash leaves the meta unset, which camaleon_cms's Ability reads identically to an empty grant, so no
# needless meta rows are written. The role stores its slug parameterized, and Ability resolves a
# user's role by that stored slug.
def user_with_manager_grants(manager_meta, slug, site: @site)
  raise ArgumentError, 'user_with_manager_grants needs a site: call it from an example under init_site' if site.nil?

  role = site.user_roles.create!(name: slug, slug: slug)
  role.set_meta("_manager_#{site.id}", manager_meta) if manager_meta.present?
  create(:user, role: role.slug, site: site)
end
