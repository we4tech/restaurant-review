require 'action_controller/caching/sweeping'

class ImageSweeper < ActiveRecord::Observer

  observe RelatedImage, ContributedImage

  def after_create(image)
    expire_cache_for(image)
  end

  def after_update(image)
    expire_cache_for(image)
  end

  def after_destroy(image)
    expire_cache_for(image)
  end

  private
  def expire_cache_for(image)
    CacheHelper::Util.expire_caches("home", "frontpage")
    if image.restaurant_id.present?
      CacheHelper::Util.expire_caches("restaurants", "show.+_#{image.restaurant_id}")
    elsif image.topic_event_id.present?
      CacheHelper::Util.expire_caches("topic_events", "show.+_#{image.topic_event_id}")
    end
    CacheHelper::Util.expire_caches(".", "best_for_box")
    CacheHelper::Util.expire_caches(".", "leader_board")
    CacheHelper::Util.expire_caches(".", "render_news_feed")
    CacheHelper::Util.expire_caches(".", "render_top_menu_restaurant")
    CacheHelper::Util.expire_caches(".", "render_page_side_modules")
  end
end