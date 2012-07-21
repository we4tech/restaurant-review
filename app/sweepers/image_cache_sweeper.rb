require 'action_controller/caching/sweeping'

class ImageCacheSweeper < ActiveRecord::Observer

  observe Image, PhotoComment

  def after_create(img)
    expire_cache_for(img)
  end

  def after_update(img)
    expire_cache_for(img)
  end

  def after_destroy(img)
    expire_cache_for(img)
  end

  private
  def expire_cache_for(ic)
    CacheHelper::Util.expire_caches("home", "frontpage")
    CacheHelper::Util.expire_caches("images", "show.+#{ic.is_a?(Image) ? ic.id : ic.image_id}")
    CacheHelper::Util.expire_caches(".", "best_for_box")
    CacheHelper::Util.expire_caches(".", "render_news_feed")
    CacheHelper::Util.expire_caches(".", "render_top_menu_restaurant")
    CacheHelper::Util.expire_caches(".", "render_page_side_modules")
  end
end