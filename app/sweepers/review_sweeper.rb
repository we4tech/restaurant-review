require 'action_controller/caching/sweeping'

class ReviewSweeper < ActiveRecord::Observer

  observe Review, ReviewComment, Checkin

  def after_create(review)
    expire_cache_for(review)
  end
  
  def after_update(review)
    expire_cache_for(review)
  end

  def after_destroy(review)
    expire_cache_for(review)
  end

  private
    def expire_cache_for(review)
      CacheHelper::Util.expire_caches("home", "frontpage")
      if review.restaurant_id.present?
        CacheHelper::Util.expire_caches("restaurants", "show.+_#{review.ref_id}")
      elsif review.topic_event_id.present?
        CacheHelper::Util.expire_caches("topic_events", "show.+_#{review.ref_id}")
      end

      CacheHelper::Util.expire_caches(".", "best_for_box")
      CacheHelper::Util.expire_caches(".", "leader_board")
      CacheHelper::Util.expire_caches(".", "render_news_feed")
      CacheHelper::Util.expire_caches(".", "render_page_side_modules")
    end
end