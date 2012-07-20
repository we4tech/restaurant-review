require 'action_controller/caching/sweeping'

class RestaurantSweeper < ActiveRecord::Observer

  observe Restaurant

  def after_create(restaurant)
    expire_cache_for(restaurant)
  end

  def after_update(restaurant)
    expire_cache_for(restaurant)
  end

  def after_destroy(restaurant)
    expire_cache_for(restaurant)
  end

  private
    def expire_cache_for(restaurant)
      CacheHelper::Util.expire_caches("home", "frontpage")   
      CacheHelper::Util.expire_caches("restaurants", "show.+_#{restaurant.id}")
      CacheHelper::Util.expire_caches(".", "best_for_box")
    end
end