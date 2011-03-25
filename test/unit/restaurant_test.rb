require 'test_helper'

class RestaurantTest < ActiveSupport::TestCase

  test 'show verify whether new tags are stored or not' do
    tags_count = Tag.count
    restaurants_count = Restaurant.count
    params     = {"restaurant"         => {"name"       =>"Ekta new",
                                           "address"    =>"3/23ada adfa",
                                           "string1"    =>"lk3lk l2k3 ",
                                           "new_tags"   =>{"short_array"=>["bashundara",
                                                                          "holapur"],
                                                          "long_array" =>["ekta chair",
                                                                          "khulcha"]},
                                           "lng"        =>"",
                                           "description"=>"",
                                           "lat"        =>""},
                  "l"                  =>  "furniture_store_en",
                  "commit"             =>  "Create",
                  "authenticity_token" =>  "Nn66nq+7Pix4VghEO7tD9IvqZlgOS+Et6w8nMZBd9ms=",
                  "tag_search_keywords"=>  ""}

    restaurant = Restaurant.new(params['restaurant'])
    puts restaurant.errors.inspect
    assert_equal true, restaurant.save
    assert_equal restaurants_count + 1, Restaurant.count
    assert_equal tags_count + 4, Tag.count 
  end
end
