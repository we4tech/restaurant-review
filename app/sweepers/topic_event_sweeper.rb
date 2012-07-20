require 'action_controller/caching/sweeping'

class TopicEventSweeper < ActiveRecord::Observer

  observe TopicEvent

  def after_create(topic_event)
    expire_cache_for(topic_event)
  end

  def after_update(te)
    expire_cache_for(te)
  end

  def after_destroy(te)
    expire_cache_for(te)
  end

  private
    def expire_cache_for(te)
      CacheHelper::Util.expire_caches("home", "frontpage")   
      CacheHelper::Util.expire_caches("topic_events", "show.+_#{te.id}")
      CacheHelper::Util.expire_caches(".", "best_for_box")
      CacheHelper::Util.expire_caches(".", "leader_board")
      CacheHelper::Util.expire_caches(".", "render_news_feed")
      CacheHelper::Util.expire_caches(".", "render_top_menu_restaurant")
      CacheHelper::Util.expire_caches(".", "render_page_side_modules")
    end
end