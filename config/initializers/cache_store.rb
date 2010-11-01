if defined?(ActionController)
  ActionController::Base.cache_store = :file_store, File.join(RAILS_ROOT, 'tmp', 'cache')
end