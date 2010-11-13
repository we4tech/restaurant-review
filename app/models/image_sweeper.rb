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
      if image.restaurant_id
        CacheHelper::Util.expire_caches("home", "frontpage")
        CacheHelper::Util.expire_caches("restaurants", "show.+_#{image.restaurant_id}")
        CacheHelper::Util.expire_caches(".", "best_for_box")
      end
    end
end