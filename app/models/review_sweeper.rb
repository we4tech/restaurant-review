require 'action_controller/caching/sweeping'

class ReviewSweeper < ActiveRecord::Observer

  observe Review, ReviewComment

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
      CacheHelper::Util.expire_caches("restaurants", "show.+_#{review.restaurant_id}")
      CacheHelper::Util.expire_caches(".", "best_for_box")
    end
end