ActionController::Routing::Routes.draw do |map|

  map.resources :exclude_lists
  map.resources :leader_board_exclude_lists, :controller => :exclude_lists

  map.resources :checkins

  map.resources :site_policies

  map.resources :resource_importers

  map.resources :events, :controller => 'topic_events'

  map.resources :products, :collection => {:next => :get}, :member => {:slide => :get, :reviews => :get}

  map.resources :premium_service_subscribers


  map.resources :food_items, :has_many => [:food_items], :member => {
      :add_image => :get, :save_image => :post}

  map.resources :messages

  map.resources :pages


  map.root :controller => "home", :action => 'frontpage'

  map.resources :premium_template_elements

  map.resources :premium_templates, :member => {:design => :get, :save_designed => :post}

  map.resources :tag_group_mappings

  map.resources :related_tags

  map.resources :tag_groups, :has_many => :tags, :member => {:associate => :post}

  map.resources :treat_requests, :member => {:accept => :get, :deny => :get}

  map.resources :photo_comments

  map.facebook_resources :tag_mappings

  map.resources :tags, :collection => {:sync => :post, :import => :post}, :member => {:flag_as_section => :get}

  map.resources :translations

  map.facebook_resources :games

  map.resources :users, :member => {:suspend => :put,
                                    :unsuspend => :put,
                                    :purge => :delete }
  map.resource  :session

  map.resources :restaurants, :member => {:edit_tags => :get,
                                          :save_tags => :post,
                                          :premium => :get,
                                          :featured => :get,
                                          :coming_soon => :get,
                                          :test_email_template => :get,
                                          :add_recipient => :get},
                :has_many => [:premium_templates,
                              :pages, :messages,
                              :food_items, :reviews,
                              :products, :checkins]

  map.resources :images, :member => {:show_or_hide => :get, :set_for_section => :get, :unsection => :get}

  map.resources :reviews

  map.resources :contributed_images

  map.resources :topics, :member => {
      :invalidate_cache => :get,
      :export => :get, :import => :get,
      :import_uploaded_file => :post, :skeleton => :get}

  map.resources :review_comments

  map.resources :form_attributes

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.fb_logout '/fb_logout', :controller => 'sessions', :action => 'fb_destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.login_as '/login_as/:user', :controller => 'sessions', :action => 'login_as'
  map.register '/register', :controller => 'users', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate "/activate/:activation_code", :controller => "users",
               :action => "activate", :activation_code => nil
  map.reset_password "/user/reset_password", :controller => "users",
                     :action => "reset_password"
  map.process_reset_password "/user/process/reset_password/",
                             :controller => "users",
                             :action => "process_reset_password"
  map.change_password "/user/change_password/:token", :controller => "users", :action => "change_password", :token => nil
  map.save_new_password "/user/save_new_password/", :controller => "users", :action => "save_new_password"

  map.restaurant_long_route '/t/:topic_name/:name/:id', :controller => 'restaurants',
                            :action => 'show',
                            :requirements => {:topic_name => /[\w\d\.\-]+/}
  map.most_loved_places '/at_most_loved_places', :controller => 'home', :action => 'most_loved_places'
  map.recently_reviewed_places '/at_recently_reviewed_places', :controller => 'home', :action => 'recently_reviewed_places'
  map.most_checkedin_places '/at_most_checkedin_places', :controller => 'home', :action => 'most_checkedin_places'
  map.recent_places '/recent/places', :controller => 'home', :action => 'recent_places'
  map.who_wanna_go_place '/at/:name/and_see_who_havent_been_there_before/:id', :controller => 'home', :action => 'who_havent_been_there_before'
  map.nearby_places '/nearby', :controller => 'home', :action => 'nearby'

  map.facebook_connect '/facebook/connect', :controller => 'users', :action => 'facebook_connect'
  map.facebook_connect_update '/facebook/connect/update', :controller => 'users', :action => 'update_facebook_connect_status'
  map.facebook_publish '/facebook/publish/:story/:id', :controller => 'facebook_connect', :action => 'publish_story'
  map.facebook_account_status_update '/user/facebook_account/update_status', :controller => 'users', :action => 'update_facebook_connect_account_status'
  map.facebook_checkin '/facebook/checkin/:model_name/:id', :controller => 'facebook_connect', :action => 'checkin'
  map.facebook_create_page '/facebook/create/page/for/:id', :controller => 'facebook_connect', :action => 'create_page'

  map.admin '/dashboard', :controller => 'admin', :action => 'index'

  map.user_long_route '/users/:login/:id', :controller => 'users', :action => 'show',
                :requirements => {:login => /[\w\d\.\-]+/}
  map.updates '/activities', :controller => 'stuff_events', :action => 'show'

  map.form_attribute_by_topic 'form_attributes/of/:topic_id', :controller => 'form_attributes', :action => 'edit'
  map.update_your_record '/user/update_record', :controller => 'restaurants', :action => 'update_record'
  map.edit_topic_modules '/topics/:id/modules', :controller => 'topics', :action => 'edit_modules'
  map.update_topic_modules '/topics/:id/modules/save', :controller => 'topics', :action => 'update_modules'
  map.tag_details '/tags/:label/:tag', :controller => 'home', :action => 'tag_details'
  map.import_tags '/import/tags', :controller => 'tags', :action => 'import'
  map.edit_restaurant '/records/:id/edit', :controller => 'restaurants', :action => 'edit'
  map.new_restaurant '/records/new', :controller => 'restaurants', :action => 'new'
  map.search '/search', :controller => 'home', :action => 'search'
  map.photos '/photos', :controller => 'home', :action => 'photos'
  map.display_photo '/photos/:title/:id', :controller => 'home',
                    :action => 'show_photo',
                    :requirements => {:title => /[\w\d\.\-]+/}
  map.recommend '/recommend', :controller => 'home', :action => 'recommend'

  map.treat_me '/games/treat_me', :controller => 'games', :action => 'treat_me'
  map.accept_treat_request '/games/accept_request/:id', :controller => 'games', :action => 'accept_request'
  map.static_page '/static/:page_name', :controller => 'home', :action => 'static_page',
                  :requirements => {:page_name => /[\d\w\.\-\s]/}
  map.product_long '/p/:name/:id', :controller => 'products', :action => 'show'

  map.readable_page '/r/:restaurant_id/pages/:page_name',
                    :controller => 'pages', :action => 'show'
  map.site_reviews '/reviews', :controller => 'reviews', :action => 'index'
  map.site_reviews_on '/reviews/of/:attached_model/:attached_id', :controller => 'reviews', :action => 'reviews_on'
  map.site_messages '/messages', :controller => 'messages', :action => 'index'
  map.site_page '/page/:page_name', :controller => 'pages', :action => 'show'
  map.fragment_for '/fragment_for/:name', :controller => 'ajax_fragment', :action => 'fragment_for'
  map.open_search '/open-search.xml', :controller => 'static_page', :action => 'open_search', :format => :xml
  map.topic_messages '/:topic_name/:restaurant_id/news',
                     :controller => 'messages', :action => 'index',
                     :requirements => {:topic_name => /[\w\d\.\-]+/}
  map.topic_items '/:topic_name/:restaurant_id/items',
                     :controller => 'food_items', :action => 'index',
                     :requirements => {:topic_name => /[\w\d\.\-]+/}

  map.event_long_route '/events/:name/:id', :controller => 'topic_events',
                       :action => 'show',
                       :requirements => {:name => /[\w\d\.\-%]+/}

  map.create_checkin '/:topic_name/checkin/:id', :controller => 'checkins', :action => 'create'
  

  # Feeds related routing
  map.feed_reviews '/feeds/recent_reviews.:format', :controller => 'feeds', :action => 'reviews'

  # Full map
  map.full_map '/full_map', :controller => 'map', :action => 'full_view'

  # Redirect to specific url
  map.generic 'link/:id', :controller => 'restaurants', :action => 'generic_routing'

  # Exposed Services
  map.service_mobile_image_upload '/service/mobile/image_upload', :controller => 'images', :action => 'mobile_upload'

  # Custom url handler
  #map.custom '/ud/:url', :controller => ''

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
