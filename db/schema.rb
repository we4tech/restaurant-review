# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111128044721) do

  create_table "checkins", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "restaurant_id"
    t.integer  "topic_event_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fb_checkin_id"
    t.string   "fb_checkin"
    t.integer  "status"
  end

  add_index "checkins", ["restaurant_id"], :name => "index_checkins_on_restaurant_id"
  add_index "checkins", ["topic_event_id"], :name => "index_checkins_on_topic_event_id"
  add_index "checkins", ["topic_id"], :name => "index_checkins_on_topic_id"
  add_index "checkins", ["user_id", "topic_id"], :name => "index_checkins_on_user_id_and_topic_id"

  create_table "contributed_images", :force => true do |t|
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.integer  "image_id"
    t.string   "model"
    t.string   "group"
    t.integer  "status",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_id",      :default => 1
  end

  add_index "contributed_images", ["image_id"], :name => "index_contributed_images_on_image_id"
  add_index "contributed_images", ["restaurant_id"], :name => "index_contributed_images_on_restaurant_id"
  add_index "contributed_images", ["topic_id", "image_id"], :name => "index_contributed_images_on_topic_id_and_image_id"
  add_index "contributed_images", ["topic_id", "restaurant_id"], :name => "index_contributed_images_on_topic_id_and_restaurant_id"

  create_table "exclude_lists", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "ref_id"
    t.string   "list_name"
    t.string   "object_type"
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exclude_lists", ["object_type", "list_name"], :name => "index_exclude_lists_on_object_type_and_list_name"
  add_index "exclude_lists", ["topic_id", "object_type"], :name => "index_exclude_lists_on_topic_id_and_object_type"

  create_table "food_items", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.integer  "food_item_id"
    t.text     "description"
    t.text     "related_objects"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "form_attributes", :force => true do |t|
    t.integer  "topic_id"
    t.text     "fields"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "record_insert_type",             :default => 0
    t.boolean  "allow_image_upload",             :default => true
    t.boolean  "allow_contributed_image_upload", :default => true
  end

  add_index "form_attributes", ["topic_id"], :name => "index_form_attributes_on_topic_id"

  create_table "images", :force => true do |t|
    t.integer  "size"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "caption",              :default => ""
    t.integer  "topic_id",             :default => 1
    t.integer  "photo_comments_count", :default => 0
    t.text     "description"
    t.string   "link"
    t.boolean  "display",              :default => true
  end

  add_index "images", ["parent_id", "thumbnail"], :name => "index_images_on_parent_id_and_thumbnail"
  add_index "images", ["user_id"], :name => "index_images_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "restaurant_id"
    t.integer  "user_id"
    t.integer  "type_id"
    t.string   "title"
    t.text     "content"
    t.text     "related_objects"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.integer  "restaurant_id"
    t.integer  "user_id"
    t.string   "url"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_comments", :force => true do |t|
    t.integer  "image_id"
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_event_id"
  end

  add_index "photo_comments", ["image_id"], :name => "index_photo_comments_on_image_id"

  create_table "premium_service_subscribers", :force => true do |t|
    t.string   "email"
    t.integer  "restaurant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "premium_template_elements", :force => true do |t|
    t.integer  "premium_template_id"
    t.integer  "restaurant_id"
    t.integer  "user_id"
    t.string   "element_type"
    t.string   "element_key"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "premium_templates", :force => true do |t|
    t.integer  "restaurant_id"
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "published",                   :default => false
    t.string   "site_title"
    t.string   "template",                                       :null => false
    t.text     "meta_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hosts"
    t.boolean  "activate_coming_soon"
    t.boolean  "activate_under_construction"
    t.boolean  "activate_no_reference_url"
    t.string   "test_host"
  end

  add_index "premium_templates", ["hosts"], :name => "index_premium_templates_on_hosts"

  create_table "products", :force => true do |t|
    t.integer  "restaurant_id"
    t.integer  "user_id"
    t.integer  "topic_id"
    t.string   "name"
    t.text     "description"
    t.float    "price"
    t.text     "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "related_images", :force => true do |t|
    t.integer  "image_id"
    t.integer  "restaurant_id"
    t.string   "model"
    t.string   "group"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "topic_id",       :default => 1
    t.integer  "food_item_id"
    t.integer  "message_id"
    t.integer  "product_id"
    t.integer  "topic_event_id"
  end

  add_index "related_images", ["image_id"], :name => "index_related_images_on_image_id"
  add_index "related_images", ["restaurant_id"], :name => "index_related_images_on_restaurant_id"
  add_index "related_images", ["topic_event_id"], :name => "index_related_images_on_topic_event_id"
  add_index "related_images", ["topic_id", "image_id"], :name => "index_related_images_on_topic_id_and_image_id"
  add_index "related_images", ["topic_id", "restaurant_id"], :name => "index_related_images_on_topic_id_and_restaurant_id"
  add_index "related_images", ["topic_id", "user_id"], :name => "index_related_images_on_topic_id_and_user_id"
  add_index "related_images", ["user_id"], :name => "index_related_images_on_user_id"

  create_table "related_tags", :force => true do |t|
    t.integer  "group_id"
    t.integer  "tag_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_importers", :force => true do |t|
    t.string   "model"
    t.string   "import_status"
    t.text     "error"
    t.integer  "imported_items"
    t.integer  "failure_items"
    t.text     "failure_items_inspection"
    t.integer  "topic_id"
    t.integer  "user_id"
    t.text     "imported_item_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "restaurants", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.integer  "topic_id",                      :default => 1
    t.string   "string1",                       :default => ""
    t.string   "string2",                       :default => ""
    t.string   "string3",                       :default => ""
    t.boolean  "boolean1",                      :default => false
    t.boolean  "boolean2",                      :default => false
    t.boolean  "boolean3",                      :default => false
    t.text     "short_array"
    t.text     "long_array"
    t.text     "short_map"
    t.text     "long_map"
    t.boolean  "premium"
    t.boolean  "featured"
    t.text     "extra_notification_recipients"
    t.integer  "fb_page_id"
    t.integer  "checkins_count"
  end

  add_index "restaurants", ["boolean1"], :name => "index_restaurants_on_boolean1"
  add_index "restaurants", ["boolean2"], :name => "index_restaurants_on_boolean2"
  add_index "restaurants", ["boolean3"], :name => "index_restaurants_on_boolean3"
  add_index "restaurants", ["featured"], :name => "index_restaurants_on_featured"
  add_index "restaurants", ["string1"], :name => "index_restaurants_on_string1"
  add_index "restaurants", ["string2"], :name => "index_restaurants_on_string2"
  add_index "restaurants", ["string3"], :name => "index_restaurants_on_string3"
  add_index "restaurants", ["topic_id"], :name => "index_restaurants_on_topic_id"

  create_table "review_comments", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "review_id"
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.integer  "loved",          :default => 1
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_event_id"
  end

  add_index "review_comments", ["review_id"], :name => "index_review_comments_on_review_id"
  add_index "review_comments", ["topic_id", "user_id"], :name => "index_review_comments_on_topic_id_and_user_id"

  create_table "reviews", :force => true do |t|
    t.integer  "restaurant_id"
    t.integer  "user_id"
    t.integer  "loved",          :default => 1
    t.text     "comment"
    t.integer  "status",         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_id",       :default => 1
    t.string   "attached_model"
    t.integer  "attached_id"
    t.integer  "topic_event_id"
  end

  add_index "reviews", ["loved"], :name => "index_reviews_on_loved"
  add_index "reviews", ["restaurant_id", "attached_model", "attached_id"], :name => "index_reviews_on_rid_am_ai"
  add_index "reviews", ["restaurant_id"], :name => "index_reviews_on_restaurant_id"
  add_index "reviews", ["topic_event_id"], :name => "index_reviews_on_topic_event_id"
  add_index "reviews", ["topic_id", "loved"], :name => "index_reviews_on_topic_id_and_loved"
  add_index "reviews", ["topic_id", "restaurant_id"], :name => "index_reviews_on_topic_id_and_restaurant_id"
  add_index "reviews", ["topic_id", "user_id"], :name => "index_reviews_on_topic_id_and_user_id"
  add_index "reviews", ["user_id"], :name => "index_reviews_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_policies", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.string   "name"
    t.text     "policy"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_policies", ["name"], :name => "index_site_policies_on_name"

  create_table "stuff_events", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "restaurant_id",     :default => 0
    t.integer  "image_id",          :default => 0
    t.integer  "user_id",           :default => 0
    t.integer  "review_id",         :default => 0
    t.integer  "review_comment_id", :default => 0
    t.integer  "event_type",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_event_id"
  end

  add_index "stuff_events", ["topic_id", "restaurant_id", "event_type", "user_id"], :name => "by_topic_rest_evt_type_user"
  add_index "stuff_events", ["topic_id", "restaurant_id", "event_type"], :name => "by_topic_res_evt_type"

  create_table "tag_group_mappings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "tag_group_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_group_mappings", ["tag_group_id", "tag_id"], :name => "index_tag_group_mappings_on_tag_group_id_and_tag_id"

  create_table "tag_groups", :force => true do |t|
    t.integer  "topic_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_groups", ["name"], :name => "index_tag_groups_on_name"
  add_index "tag_groups", ["topic_id", "name"], :name => "index_tag_groups_on_topic_id_and_name"

  create_table "tag_mappings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "topic_id"
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_mappings", ["tag_id", "restaurant_id", "topic_id"], :name => "index_tag_mappings_on_tag_id_and_restaurant_id_and_topic_id"
  add_index "tag_mappings", ["tag_id", "restaurant_id"], :name => "index_tag_mappings_on_tag_id_and_restaurant_id"
  add_index "tag_mappings", ["topic_id", "tag_id"], :name => "index_tag_mappings_on_topic_id_and_tag_id"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "usages_count",       :default => 0
    t.integer  "tag_mappings_count", :default => 0
    t.boolean  "feature_enlist",     :default => false
    t.boolean  "as_section"
    t.text     "section_data"
    t.integer  "section_index"
  end

  add_index "tags", ["as_section"], :name => "index_tags_on_as_section"
  add_index "tags", ["name", "topic_id"], :name => "index_tags_on_name_and_topic_id"

  create_table "topic_events", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "user_id"
    t.integer  "event_type"
    t.integer  "parent_event_id"
    t.string   "name"
    t.text     "description"
    t.text     "description_fields"
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "daily_schedule_map"
    t.boolean  "suspended",          :default => false
    t.boolean  "completed",          :default => false
    t.text     "suspending_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "custom_css"
    t.integer  "checkins_count"
  end

  add_index "topic_events", ["topic_id", "start_at", "end_at"], :name => "index_topic_events_on_topic_id_and_start_at_and_end_at"
  add_index "topic_events", ["topic_id"], :name => "index_topic_events_on_topic_id"

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.string   "label"
    t.text     "properties"
    t.string   "theme",                  :default => ""
    t.boolean  "default",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site_title"
    t.text     "site_labels"
    t.text     "description"
    t.string   "banner_image_path"
    t.text     "modules"
    t.text     "css"
    t.text     "email_footer"
    t.text     "meta_tags_html"
    t.boolean  "enabled",                :default => true
    t.string   "hosts"
    t.text     "gmap_key"
    t.text     "fb_connect_key"
    t.text     "fb_connect_secret"
    t.boolean  "user_subdomain"
    t.integer  "subdomain_content_type"
    t.string   "fb_id"
    t.string   "fb_admins"
    t.string   "og_type"
  end

  add_index "topics", ["default"], :name => "index_topics_on_default"
  add_index "topics", ["enabled"], :name => "index_topics_on_enabled"
  add_index "topics", ["hosts"], :name => "index_topics_on_hosts"
  add_index "topics", ["name"], :name => "index_topics_on_name"

  create_table "treat_requests", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "restaurant_id"
    t.integer  "uid"
    t.integer  "requested_uid"
    t.boolean  "accepted"
    t.boolean  "denied"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_logs", ["user_id", "topic_id"], :name => "index_user_logs_on_user_id_and_topic_id"

  create_table "users", :force => true do |t|
    t.string   "login",                      :limit => 40
    t.string   "name",                       :limit => 100, :default => ""
    t.string   "email",                      :limit => 100
    t.string   "crypted_password",           :limit => 40
    t.string   "salt",                       :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",             :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",            :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                     :default => "passive"
    t.datetime "deleted_at"
    t.string   "facebook_uid"
    t.string   "facebook_sid"
    t.integer  "facebook_connect_enabled",                  :default => 1
    t.boolean  "admin",                                     :default => false
    t.boolean  "email_comment_notification",                :default => true
    t.string   "domain_name"
    t.string   "last_logged_in_ip"
    t.datetime "last_logged_in_at"
    t.integer  "checkins_count"
  end

  add_index "users", ["domain_name"], :name => "index_users_on_domain_name"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
