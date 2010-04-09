class CacheSweeper <  ActionController::Caching::Sweeper
  
  observe Restaurant

  def after_create(restaurant)
    expires_restaurant_caches
  end

  def after_update(restaurant)
    expires_restaurant_caches
  end

  def after_destroy(restaurant)
    expires_restaurant_caches
  end

  private
    def expires_restaurant_caches
      expire_action(:action => 'index')
    end
end